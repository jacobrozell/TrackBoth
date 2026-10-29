import SwiftData
import XCTest
@testable import TrackBoth

@MainActor
final class BackupServiceTests: XCTestCase {
    func testRoundTripKeepsTheVice() throws {
        let harness = try TestHarness()
        let alcohol = try harness.store.addMetric(
            name: "Alcohol",
            habitType: .vice,
            iconName: "wineglass",
            startedAt: date(2026, 10, 1, 9),
            costPerDay: 8,
            firstReason: "For my health"
        )
        let data = try BackupService.exportData(from: harness.store.context, now: date(2026, 10, 28, 12))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(BackupService.fileName(for: date(2026, 10, 28, 12), calendar: .testNY))
        try data.write(to: url)
        try harness.store.delete(alcohol)
        try BackupService.importData(try Data(contentsOf: url), into: harness.store)
        let metrics = try harness.store.context.fetch(FetchDescriptor<Metric>())
        XCTAssertEqual(metrics.map(\.name), ["Alcohol"])
        XCTAssertEqual(metrics.first?.costPerDay, 8)
        let reasons = try harness.store.context.fetch(FetchDescriptor<Reason>())
        XCTAssertEqual(reasons.map(\.text), ["For my health"])
        XCTAssertTrue(Preferences.hasCompletedOnboarding)
    }

    func testNewerBackupIsRejectedAndLeavesData() throws {
        let harness = try TestHarness()
        _ = try harness.store.addMetric(name: "Walk", habitType: .positive, iconName: "figure.walk", startedAt: date(2026, 10, 1), costPerDay: nil, firstReason: nil)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("newer-backup.json")
        try Data("{\"schemaVersion\":6,\"exportDate\":\"2026-10-28T12:00:00Z\",\"metrics\":[],\"entries\":[],\"urges\":[],\"reasons\":[]}".utf8).write(to: url)
        XCTAssertThrowsError(try BackupService.importData(try Data(contentsOf: url), into: harness.store)) { error in
            XCTAssertEqual(error as? BackupError, .newerVersion)
        }
        let metrics = try harness.store.context.fetch(FetchDescriptor<Metric>())
        XCTAssertEqual(metrics.map(\.name), ["Walk"])
    }
}
