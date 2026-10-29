import SwiftData
import XCTest
@testable import TrackBoth

@MainActor
final class BackupServiceTests: XCTestCase {
    private var harness: TestHarness!
    private var store: RecoveryStore! { harness.store }

    override func setUp() async throws {
        harness = try TestHarness()
    }

    func testV5RoundTrip() throws {
        let metric = try store.addMetric(
            name: "Alcohol",
            habitType: .vice,
            iconName: "wineglass",
            startedAt: date(2026, 10, 1, 9),
            costPerDay: 8,
            firstReason: "For my health"
        )
        try store.logSlip(metric, occurredAt: date(2026, 10, 5, 20), triggers: [.tired, .routine], note: "After dinner")
        let urge = try store.startUrge(for: metric, intensity: 4, now: date(2026, 10, 6, 18))
        try store.finishUrge(urge, outcome: .resisted, triggers: [.stressed], note: nil, now: date(2026, 10, 6, 18, 10))

        let data = try BackupService.exportData(from: store.context, now: date(2026, 10, 28, 16))
        try store.addMetric(name: "Extra", habitType: .positive, iconName: "star", startedAt: date(2026, 10, 2), costPerDay: nil, firstReason: nil)
        try BackupService.importData(data, into: store)

        let metrics = try store.context.fetch(FetchDescriptor<Metric>())
        XCTAssertEqual(metrics.map(\.name), ["Alcohol"])
        XCTAssertEqual(metrics.first?.costPerDay, 8)
        let entries = try store.context.fetch(FetchDescriptor<MetricEntry>())
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.status, .slipped)
        XCTAssertEqual(entries.first?.triggers, [.tired, .routine])
        let urges = try store.context.fetch(FetchDescriptor<UrgeEvent>())
        XCTAssertEqual(urges.first?.outcome, .resisted)
        let reasons = try store.context.fetch(FetchDescriptor<Reason>())
        XCTAssertEqual(reasons.first?.text, "For my health")
    }

    func testLegacyFixtures() throws {
        try importFixture("legacy-v1")
        var metrics = try store.context.fetch(FetchDescriptor<Metric>())
        XCTAssertEqual(Set(metrics.map(\.name)), ["Alcohol", "Go for a walk"])
        XCTAssertEqual(metrics.first { $0.name == "Alcohol" }?.iconName, "wineglass")
        XCTAssertEqual(metrics.first { $0.name == "Go for a walk" }?.iconName, "figure.walk")
        XCTAssertNil(metrics.first { $0.name == "Alcohol" }?.costPerDay)
        XCTAssertEqual(try store.context.fetch(FetchDescriptor<MetricEntry>()).count, 5)
        XCTAssertTrue(try store.context.fetch(FetchDescriptor<Reason>()).isEmpty)

        try importFixture("legacy-v3")
        let reasons = try store.context.fetch(FetchDescriptor<Reason>()).sorted { $0.sortOrder < $1.sortOrder }
        XCTAssertEqual(reasons.map(\.text), ["For my health", "Remember my kids", "I want to feel clear"])
        let entries = try store.context.fetch(FetchDescriptor<MetricEntry>())
        XCTAssertTrue(entries.contains { $0.note == "Stayed in" && $0.status == .free })
        XCTAssertTrue(entries.contains { $0.note == "After dinner" && $0.status == .slipped })
        XCTAssertNil(metrics.first { $0.name == "Alcohol" }?.costPerDay)

        try importFixture("legacy-v4")
        metrics = try store.context.fetch(FetchDescriptor<Metric>())
        XCTAssertEqual(metrics.first { $0.name == "Alcohol" }?.costPerDayRaw, "8")
        let v4Entries = try store.context.fetch(FetchDescriptor<MetricEntry>())
        XCTAssertEqual(v4Entries.count, 5)
        XCTAssertFalse(v4Entries.contains { $0.note == "Skipped" })
        XCTAssertTrue(try store.context.fetch(FetchDescriptor<Reason>()).count == 3)
    }

    func testNewerSchemaLeavesTheStoreUntouched() throws {
        _ = try store.addMetric(name: "Alcohol", habitType: .vice, iconName: "wineglass", startedAt: date(2026, 10, 1), costPerDay: nil, firstReason: nil)
        let data = Data(#"{"schemaVersion":6,"metrics":[]}"#.utf8)
        XCTAssertThrowsError(try BackupService.importData(data, into: store)) { error in
            XCTAssertEqual(error as? BackupError, .newerVersion)
        }
        XCTAssertEqual(try store.context.fetch(FetchDescriptor<Metric>()).count, 1)
    }

    func testInvalidJSONLeavesTheStoreUntouched() throws {
        _ = try store.addMetric(name: "Alcohol", habitType: .vice, iconName: "wineglass", startedAt: date(2026, 10, 1), costPerDay: nil, firstReason: nil)
        XCTAssertThrowsError(try BackupService.importData(Data("not json".utf8), into: store))
        XCTAssertEqual(try store.context.fetch(FetchDescriptor<Metric>()).count, 1)
    }

    func testNumericLegacyDatesStillImport() throws {
        let metricID = UUID()
        let entryID = UUID()
        let payload = LegacyExportV4.Payload(
            schemaVersion: 1,
            metrics: [
                LegacyExportV4.MetricRecord(
                    id: metricID.uuidString,
                    name: "Read",
                    createdAt: date(2026, 10, 1, 9),
                    habitType: "positive",
                    hasBeenLogged: true,
                    primaryMotivation: nil,
                    costPerUnit: nil
                )
            ],
            entries: [
                LegacyExportV4.EntryRecord(
                    id: entryID.uuidString,
                    metricID: metricID.uuidString,
                    date: date(2026, 10, 2, 15),
                    value: true,
                    details: nil,
                    motivation: nil,
                    starred: nil,
                    quantity: nil,
                    unit: nil,
                    mood: nil,
                    hasBeenLogged: true
                )
            ],
            goals: nil,
            exportDate: date(2026, 10, 3)
        )
        let data = try JSONEncoder().encode(payload)
        try BackupService.importData(data, into: store)
        let entries = try store.context.fetch(FetchDescriptor<MetricEntry>())
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.status, .done)
    }

    private func importFixture(_ name: String) throws {
        let url = Bundle(for: BackupServiceTests.self).url(forResource: name, withExtension: "json")
        let data = try Data(contentsOf: try XCTUnwrap(url))
        try BackupService.importData(data, into: store)
    }
}
