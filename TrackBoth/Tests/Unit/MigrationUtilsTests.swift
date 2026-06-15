import XCTest
import SwiftData
@testable import TrackBoth

final class MigrationUtilsTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        let schema = Schema([Metric.self, MetricEntry.self, Goal.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    func testNeedsMigrationWhenEntryHasContentButNotLoggedFlag() {
        let metric = Metric(name: "Read", habitType: .positive)
        context.insert(metric)

        let entry = MetricEntry(metricID: metric.id, date: Date(), value: true, details: "Done")
        context.insert(entry)
        try! context.save()

        XCTAssertTrue(MigrationUtils.needsMigration(in: context))
    }

    func testMigrateLoggedStatusUpdatesMetricAndEntry() {
        let metric = Metric(name: "Read", habitType: .positive)
        metric.hasBeenLogged = false
        context.insert(metric)

        let entry = MetricEntry(metricID: metric.id, date: Date(), value: true, details: "Done")
        entry.hasBeenLogged = false
        context.insert(entry)
        try! context.save()

        MigrationUtils.migrateLoggedStatus(in: context)

        XCTAssertTrue(metric.hasBeenLogged)
        XCTAssertTrue(entry.hasBeenLogged)
    }

    func testRunMigrationIfNeededSkipsWhenNotRequired() {
        let metric = Metric(name: "Read", habitType: .positive)
        metric.hasBeenLogged = true
        context.insert(metric)
        try! context.save()

        MigrationUtils.runMigrationIfNeeded(in: context)
        XCTAssertTrue(metric.hasBeenLogged)
    }

    func testMotivationOnlyEntryIsNotMigratedToLogged() {
        let metric = Metric(name: "Coffee", habitType: .vice)
        context.insert(metric)

        let entry = MetricEntry(
            metricID: metric.id,
            date: Date(),
            value: false,
            motivation: "Stay strong"
        )
        context.insert(entry)
        try! context.save()

        XCTAssertFalse(MigrationUtils.shouldMigrateEntryToLogged(entry))

        MigrationUtils.migrateLoggedStatus(in: context)

        XCTAssertFalse(entry.hasBeenLogged)
        XCTAssertFalse(metric.hasBeenLogged)
    }

    func testLegacyValueOnlyEntryIsMigratedToLogged() {
        let metric = Metric(name: "Read", habitType: .positive)
        context.insert(metric)

        let entry = MetricEntry(metricID: metric.id, date: Date(), value: true)
        context.insert(entry)
        try! context.save()

        MigrationUtils.migrateLoggedStatus(in: context)

        XCTAssertTrue(entry.hasBeenLogged)
        XCTAssertTrue(metric.hasBeenLogged)
    }
}
