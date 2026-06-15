import XCTest
@testable import TrackBoth

final class TrackingSemanticsTests: XCTestCase {

    func testHabitSuccessWhenValueTrue() {
        XCTAssertTrue(TrackingSemantics.isSuccessful(habitType: .positive, value: true))
        XCTAssertFalse(TrackingSemantics.isSuccessful(habitType: .positive, value: false))
    }

    func testViceSuccessWhenValueFalse() {
        XCTAssertTrue(TrackingSemantics.isSuccessful(habitType: .vice, value: false))
        XCTAssertFalse(TrackingSemantics.isSuccessful(habitType: .vice, value: true))
    }

    func testUnloggedEntryDoesNotCountAsCompleted() {
        let entry = MetricEntry(metricID: UUID(), date: Date(), value: false, hasBeenLogged: false)
        XCTAssertFalse(TrackingSemantics.countsTowardTodayCompleted(habitType: .vice, entry: entry))
        XCTAssertFalse(TrackingSemantics.countsTowardTodayCompleted(habitType: .positive, entry: entry))
    }

    func testViceAvoidedCountsWhenLogged() {
        let entry = MetricEntry(metricID: UUID(), date: Date(), value: false, hasBeenLogged: true)
        XCTAssertTrue(TrackingSemantics.countsTowardTodayCompleted(habitType: .vice, entry: entry))
    }

    func testFirstQuickToggleSetsSuccessValue() {
        XCTAssertTrue(TrackingSemantics.valueAfterQuickToggle(habitType: .positive, existingEntry: nil))
        XCTAssertFalse(TrackingSemantics.valueAfterQuickToggle(habitType: .vice, existingEntry: nil))
    }

    func testQuickToggleFlipsLoggedEntry() {
        let habitEntry = MetricEntry(metricID: UUID(), date: Date(), value: true, hasBeenLogged: true)
        XCTAssertFalse(TrackingSemantics.valueAfterQuickToggle(habitType: .positive, existingEntry: habitEntry))

        let viceEntry = MetricEntry(metricID: UUID(), date: Date(), value: false, hasBeenLogged: true)
        XCTAssertTrue(TrackingSemantics.valueAfterQuickToggle(habitType: .vice, existingEntry: viceEntry))
    }

    func testViceToggleBindingInvertsValue() {
        XCTAssertTrue(TrackingSemantics.toggleIsOn(habitType: .vice, value: false))
        XCTAssertFalse(TrackingSemantics.toggleIsOn(habitType: .vice, value: true))
        XCTAssertFalse(TrackingSemantics.value(fromToggleIsOn: true, habitType: .vice))
        XCTAssertTrue(TrackingSemantics.value(fromToggleIsOn: false, habitType: .vice))
    }
}
