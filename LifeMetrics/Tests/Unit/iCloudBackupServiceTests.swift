import XCTest
import SwiftData
@testable import TrackBoth

final class iCloudBackupServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var service: iCloudBackupService!

    override func setUp() {
        super.setUp()
        container = try! ModelContainer(
            for: Schema([Metric.self, MetricEntry.self, Goal.self]),
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        context = ModelContext(container)
        service = iCloudBackupService()
    }

    func testCreateBackupIncludesGoalsAndEntries() async throws {
        let metric = Metric(name: "Run", habitType: .positive)
        let goal = Goal(goalType: .boolean, period: .weekly, target: 3)
        goal.metric = metric
        metric.goals = [goal]
        context.insert(metric)
        context.insert(goal)

        let day = Calendar.current.startOfDay(for: Date())
        let entry = MetricEntry(metricID: metric.id, date: day, value: true, hasBeenLogged: true)
        context.insert(entry)
        try context.save()

        let backup = try await service.createBackup(metrics: [metric], entries: [entry])

        XCTAssertEqual(backup.metrics.count, 1)
        XCTAssertEqual(backup.metrics.first?.goals.count, 1)
        XCTAssertEqual(backup.entries.count, 1)
        XCTAssertEqual(backup.entries.first?.quantity, nil)
    }

    func testBackupJSONRoundTrip() async throws {
        let metric = Metric(name: "Water", habitType: .positive)
        metric.hasBeenLogged = true
        context.insert(metric)

        let entry = MetricEntry(
            metricID: metric.id,
            date: Date(),
            value: true,
            quantity: 8,
            unit: "glasses",
            hasBeenLogged: true
        )
        context.insert(entry)
        try context.save()

        let backup = try await service.createBackup(metrics: [metric], entries: [entry])
        let data = try JSONEncoder().encode(backup)
        let decoded = try JSONDecoder().decode(iCloudBackupService.BackupData.self, from: data)

        XCTAssertEqual(decoded.metrics.first?.name, "Water")
        XCTAssertEqual(decoded.entries.first?.quantity, 8)
    }

    func testRestoreReplacesExistingData() async throws {
        let oldMetric = Metric(name: "Old", habitType: .vice)
        context.insert(oldMetric)
        try context.save()

        let metric = Metric(name: "Meditate", habitType: .positive)
        let entry = MetricEntry(metricID: metric.id, date: Date(), value: true, hasBeenLogged: true)
        let backup = try await service.createBackup(metrics: [metric], entries: [entry])

        try service.restoreFromBackup(backup, context: context)

        let metrics = try context.fetch(FetchDescriptor<Metric>())
        let entries = try context.fetch(FetchDescriptor<MetricEntry>())
        XCTAssertEqual(metrics.count, 1)
        XCTAssertEqual(metrics.first?.name, "Meditate")
        XCTAssertEqual(entries.count, 1)
        XCTAssertTrue(entries.first?.hasBeenLogged == true)
        XCTAssertTrue(metrics.first?.hasBeenLogged == true)
    }
}
