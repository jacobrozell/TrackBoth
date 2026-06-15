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

    func testStatusLabelsForHabitsAndVices() {
        let unlogged = MetricEntry(metricID: UUID(), date: Date(), value: false, hasBeenLogged: false)
        XCTAssertEqual(TrackingSemantics.statusLabel(habitType: .positive, entry: unlogged).text, "Incomplete")
        XCTAssertEqual(TrackingSemantics.statusLabel(habitType: .vice, entry: unlogged).text, "Not Avoided")

        let habitDone = MetricEntry(metricID: UUID(), date: Date(), value: true, hasBeenLogged: true)
        XCTAssertEqual(TrackingSemantics.statusLabel(habitType: .positive, entry: habitDone).text, "Completed")
        XCTAssertTrue(TrackingSemantics.statusLabel(habitType: .positive, entry: habitDone).isSuccess)

        let viceAvoided = MetricEntry(metricID: UUID(), date: Date(), value: false, hasBeenLogged: true)
        XCTAssertEqual(TrackingSemantics.statusLabel(habitType: .vice, entry: viceAvoided).text, "Avoided")
    }

    func testSuccessAndFailureValues() {
        XCTAssertTrue(TrackingSemantics.successValue(habitType: .positive))
        XCTAssertFalse(TrackingSemantics.successValue(habitType: .vice))
        XCTAssertFalse(TrackingSemantics.failureValue(habitType: .positive))
        XCTAssertTrue(TrackingSemantics.failureValue(habitType: .vice))
    }

    func testStreakEligibleRequiresMetricLogged() {
        let metric = Metric(name: "Read", habitType: .positive)
        XCTAssertFalse(TrackingSemantics.streakEligible(metric: metric))
        metric.hasBeenLogged = true
        XCTAssertTrue(TrackingSemantics.streakEligible(metric: metric))
    }

    func testShouldMarkLoggedOnSaveRequiresSuccessOrDetails() {
        let existing = MetricEntry(metricID: UUID(), date: Date(), value: false, hasBeenLogged: true)

        XCTAssertFalse(
            TrackingSemantics.shouldMarkLoggedOnSave(
                habitType: .positive,
                value: false,
                details: "",
                quantity: nil,
                existingEntry: nil
            )
        )
        XCTAssertTrue(
            TrackingSemantics.shouldMarkLoggedOnSave(
                habitType: .positive,
                value: true,
                details: "",
                quantity: nil,
                existingEntry: nil
            )
        )
        XCTAssertTrue(
            TrackingSemantics.shouldMarkLoggedOnSave(
                habitType: .positive,
                value: false,
                details: "Notes",
                quantity: nil,
                existingEntry: nil
            )
        )
        XCTAssertTrue(
            TrackingSemantics.shouldMarkLoggedOnSave(
                habitType: .positive,
                value: false,
                details: "",
                quantity: nil,
                existingEntry: existing
            )
        )
    }

    func testIsLoggedSuccessRequiresLoggedEntry() {
        let viceEntry = MetricEntry(metricID: UUID(), date: Date(), value: false, hasBeenLogged: false)
        XCTAssertFalse(TrackingSemantics.isLoggedSuccess(habitType: .vice, entry: viceEntry))

        viceEntry.hasBeenLogged = true
        XCTAssertTrue(TrackingSemantics.isLoggedSuccess(habitType: .vice, entry: viceEntry))
    }
}
