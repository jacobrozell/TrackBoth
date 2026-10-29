import SwiftData
import XCTest
@testable import TrackBoth

@MainActor
final class RecoveryStoreTests: XCTestCase {
    private var harness: TestHarness!
    private var store: RecoveryStore! { harness.store }
    private let calendar = Calendar.testNY

    override func setUp() async throws {
        harness = try TestHarness(calendar: calendar)
    }

    func testUpsertKeepsOneEntryPerDay() throws {
        let metric = try vice()
        let day = date(2026, 10, 10, 9)
        try store.markFree(metric, on: day, now: day)
        try store.markFree(metric, on: date(2026, 10, 10, 18), now: date(2026, 10, 10, 18))
        let entries = try store.entries(for: metric.id)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.status, .free)
    }

    func testMarkFreeDoesNotOverrideASlip() throws {
        let metric = try vice()
        let when = date(2026, 10, 10, 20)
        try store.logSlip(metric, occurredAt: when, triggers: [.tired], note: "After dinner")
        try store.markFree(metric, on: when, now: date(2026, 10, 10, 21))
        let entry = try store.entry(for: metric.id, on: when)
        XCTAssertEqual(entry?.status, .slipped)
        XCTAssertEqual(entry?.note, "After dinner")
    }

    func testLogSlipRejectsATimeBeforeTheQuitDay() throws {
        let metric = try vice(started: date(2026, 10, 10, 9))
        XCTAssertThrowsError(try store.logSlip(metric, occurredAt: date(2026, 10, 9, 23), triggers: [], note: nil)) { error in
            XCTAssertEqual(error as? RecoveryStoreError, .slipBeforeStart)
        }
        XCTAssertTrue(try store.entries(for: metric.id).isEmpty)
    }

    func testSetHabitDoneFalseDeletesTheEntry() throws {
        let habit = try habit()
        let day = date(2026, 10, 12)
        try store.setHabitDone(habit, on: day, done: true, now: day)
        try store.setHabitDone(habit, on: day, done: false, now: day)
        XCTAssertNil(try store.entry(for: habit.id, on: day))
    }

    func testDeleteCascadesEntriesUrgesAndReasons() throws {
        let metric = try vice()
        try store.addReason("For my health", to: metric)
        try store.logSlip(metric, occurredAt: date(2026, 10, 12, 20), triggers: [.bored], note: nil)
        _ = try store.startUrge(for: metric, intensity: 4, now: date(2026, 10, 11, 18))
        MilestoneLedger.record(7, for: metric.id)
        try store.delete(metric)
        XCTAssertEqual(try store.context.fetchCount(FetchDescriptor<Metric>()), 0)
        XCTAssertEqual(try store.context.fetchCount(FetchDescriptor<MetricEntry>()), 0)
        XCTAssertEqual(try store.context.fetchCount(FetchDescriptor<UrgeEvent>()), 0)
        XCTAssertEqual(try store.context.fetchCount(FetchDescriptor<Reason>()), 0)
        XCTAssertEqual(MilestoneLedger.highestCelebrated(for: metric.id), 0)
    }

    func testDeleteAllClearsModelsPreferencesAndTheLedger() throws {
        let metric = try vice()
        Preferences.hasCompletedOnboarding = true
        MilestoneLedger.record(3, for: metric.id)
        try store.deleteAllData()
        XCTAssertEqual(try store.context.fetchCount(FetchDescriptor<Metric>()), 0)
        XCTAssertFalse(Preferences.hasCompletedOnboarding)
        XCTAssertEqual(MilestoneLedger.highestCelebrated(for: metric.id), 0)
    }

    func testReorderRewritesSortOrder() throws {
        let first = try vice(name: "Alcohol")
        let second = try habit(name: "Walk")
        try store.reorder([second, first])
        XCTAssertEqual(second.sortOrder, 0)
        XCTAssertEqual(first.sortOrder, 1)
    }

    func testSuccessfulSavePostsRecoveryDataChanged() throws {
        let expectation = expectation(forNotification: .recoveryDataChanged, object: nil)
        _ = try vice()
        wait(for: [expectation], timeout: 1)
    }

    private func vice(name: String = "Alcohol", started: Date = date(2026, 10, 1, 9)) throws -> Metric {
        try store.addMetric(name: name, habitType: .vice, iconName: "wineglass", startedAt: started, costPerDay: 8, firstReason: nil)
    }

    private func habit(name: String = "Go for a walk") throws -> Metric {
        try store.addMetric(name: name, habitType: .positive, iconName: "figure.walk", startedAt: date(2026, 10, 1, 9), costPerDay: nil, firstReason: nil)
    }
}
