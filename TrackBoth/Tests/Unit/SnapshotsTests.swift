import SwiftData
import XCTest
@testable import TrackBoth

@MainActor
final class SnapshotsTests: XCTestCase {
    func testMapsStatusesOntoDomainHistories() throws {
        let harness = try TestHarness()
        let store = harness.store
        let calendar = Calendar.testNY
        let vice = try store.addMetric(name: "Alcohol", habitType: .vice, iconName: "wineglass", startedAt: date(2026, 10, 1, 9), costPerDay: nil, firstReason: nil)
        let habit = try store.addMetric(name: "Walk", habitType: .positive, iconName: "figure.walk", startedAt: date(2026, 10, 1, 9), costPerDay: nil, firstReason: nil)
        try store.markFree(vice, on: date(2026, 10, 2), now: date(2026, 10, 2, 18))
        try store.logSlip(vice, occurredAt: date(2026, 10, 5, 20), triggers: [.tired], note: nil)
        try store.setHabitDone(habit, on: date(2026, 10, 3), done: true, now: date(2026, 10, 3, 8))

        let entries = try store.context.fetch(FetchDescriptor<MetricEntry>())
        let viceHistory = Snapshots.viceHistory(for: vice, entries: entries, calendar: calendar)
        XCTAssertEqual(viceHistory.slips, [date(2026, 10, 5, 20)])
        XCTAssertTrue(viceHistory.confirmedFreeDays.contains(calendar.startOfDay(for: date(2026, 10, 2))))
        XCTAssertFalse(viceHistory.confirmedFreeDays.contains(calendar.startOfDay(for: date(2026, 10, 5))))

        let habitHistory = Snapshots.habitHistory(for: habit, entries: entries, calendar: calendar)
        XCTAssertEqual(habitHistory.doneDays, [calendar.startOfDay(for: date(2026, 10, 3))])
    }
}
