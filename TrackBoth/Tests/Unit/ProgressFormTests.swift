import SwiftData
import XCTest
@testable import TrackBoth

@MainActor
final class ProgressViewModelTests: XCTestCase {
    func testCardsMatchDomainForTheFixture() throws {
        let harness = try TestHarness()
        let store = harness.store
        let alcohol = try store.addMetric(name: "Alcohol", habitType: .vice, iconName: "wineglass", startedAt: date(2026, 10, 1, 9), costPerDay: 8, firstReason: nil)
        try store.logSlip(alcohol, occurredAt: date(2026, 10, 5, 20), triggers: [], note: nil)
        let entries = try store.context.fetch(FetchDescriptor<MetricEntry>())
        let model = ProgressViewModel(calendar: .testNY, locale: Locale(identifier: "en_US"))
        model.update(metrics: [alcohol], entries: entries, urges: [], now: date(2026, 10, 13, 10))
        XCTAssertEqual(model.active.first?.line, RecoveryCopy.viceProgress(days: 7, longest: 7, free: 11, counted: 12))
        XCTAssertEqual(model.summary.savedText, "$88.00 saved")
        XCTAssertEqual(model.summary.urgesBeaten, 0)
    }
}

@MainActor
final class MetricFormViewModelTests: XCTestCase {
    func testNameIsRequiredAndCapped() {
        let model = MetricFormViewModel(metric: nil)
        XCTAssertFalse(model.canSave)
        model.name = String(repeating: "a", count: 41)
        XCTAssertEqual(model.nameError, RecoveryCopy.nameTooLong)
        model.name = "Alcohol"
        XCTAssertTrue(model.canSave)
        XCTAssertTrue(model.showsTypePicker)
    }

    func testNewHabitStartsNow() throws {
        let harness = try TestHarness()
        let model = MetricFormViewModel(metric: nil)
        model.habitType = .positive
        model.name = "Walk"
        model.startedAt = date(2020, 1, 1)
        let now = date(2026, 10, 13, 10)
        let saved = try model.save(metric: nil, store: harness.store, now: now)
        XCTAssertEqual(saved.startedAt, now)
        XCTAssertNil(saved.costPerDay)
    }
}
