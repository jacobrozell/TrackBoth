import XCTest
@testable import TrackBoth

final class StreakUtilsTests: XCTestCase {

    private var calendar: Calendar!
    private var today: Date!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
        today = calendar.startOfDay(for: Date())
    }

    private func makeMetric(type: HabitType, logged: Bool = true) -> Metric {
        let metric = Metric(name: "Test", habitType: type)
        metric.hasBeenLogged = logged
        return metric
    }

    private func makeEntry(metricID: UUID, dayOffset: Int, value: Bool, logged: Bool = true) -> MetricEntry {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return MetricEntry(
            metricID: metricID,
            date: calendar.startOfDay(for: date),
            value: value,
            hasBeenLogged: logged
        )
    }

    func testNeverLoggedMetricHasZeroStreak() {
        let metric = makeMetric(type: .vice, logged: false)
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: [], selectedDate: today)
        XCTAssertEqual(streak, 0)
    }

    func testNewViceWithoutEntriesHasZeroStreak() {
        let metric = makeMetric(type: .vice, logged: false)
        let entries = [makeEntry(metricID: metric.id, dayOffset: 0, value: false, logged: true)]
        // Metric not marked logged — streak should still be 0
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(streak, 0)
    }

    func testViceAvoidedTodayStreakIsOne() {
        let metric = makeMetric(type: .vice, logged: true)
        let entries = [makeEntry(metricID: metric.id, dayOffset: 0, value: false)]
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(streak, 1)
    }

    func testHabitDoneThreeDayStreak() {
        let metric = makeMetric(type: .positive, logged: true)
        let entries = (-2...0).map { makeEntry(metricID: metric.id, dayOffset: $0, value: true) }
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(streak, 3)
    }

    func testGapBreaksStreak() {
        let metric = makeMetric(type: .positive, logged: true)
        let entries = [
            makeEntry(metricID: metric.id, dayOffset: 0, value: true),
            makeEntry(metricID: metric.id, dayOffset: -2, value: true)
        ]
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(streak, 1)
    }

    func testUnloggedEntryDoesNotExtendStreak() {
        let metric = makeMetric(type: .vice, logged: true)
        let entries = [makeEntry(metricID: metric.id, dayOffset: 0, value: false, logged: false)]
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(streak, 0)
    }
}
