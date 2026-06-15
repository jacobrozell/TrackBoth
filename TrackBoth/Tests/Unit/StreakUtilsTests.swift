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

    func testUnloggedTodayPreservesStreakFromYesterday() {
        let metric = makeMetric(type: .positive, logged: true)
        let entries = (-2...(-1)).map { makeEntry(metricID: metric.id, dayOffset: $0, value: true) }
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(streak, 2)
    }

    func testFailedLogTodayBreaksStreak() {
        let metric = makeMetric(type: .positive, logged: true)
        let entries = [
            makeEntry(metricID: metric.id, dayOffset: -1, value: true),
            makeEntry(metricID: metric.id, dayOffset: 0, value: false)
        ]
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(streak, 0)
    }

    func testMissingEntryOnPastDateBreaksStreakWithoutGrace() {
        let metric = makeMetric(type: .positive, logged: true)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let entries = [makeEntry(metricID: metric.id, dayOffset: -2, value: true)]
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: yesterday)
        XCTAssertEqual(streak, 0)
    }

    func testLongestStreakCountsContiguousSuccessfulDays() {
        let metric = makeMetric(type: .positive, logged: true)
        let entries = (-4...0).map { makeEntry(metricID: metric.id, dayOffset: $0, value: true) }
        let longest = StreakUtils.calculateLongestStreak(for: metric, entries: entries)
        XCTAssertEqual(longest, 5)
    }

    func testLongestStreakResetsAfterGap() {
        let metric = makeMetric(type: .positive, logged: true)
        let entries = [
            makeEntry(metricID: metric.id, dayOffset: -5, value: true),
            makeEntry(metricID: metric.id, dayOffset: -4, value: true),
            makeEntry(metricID: metric.id, dayOffset: -2, value: true),
            makeEntry(metricID: metric.id, dayOffset: -1, value: true),
            makeEntry(metricID: metric.id, dayOffset: 0, value: true)
        ]
        let longest = StreakUtils.calculateLongestStreak(for: metric, entries: entries)
        XCTAssertEqual(longest, 3)
    }

    func testLongestStreakDeduplicatesSameDay() {
        let metric = makeMetric(type: .positive, logged: true)
        let entries = [
            makeEntry(metricID: metric.id, dayOffset: 0, value: true),
            makeEntry(metricID: metric.id, dayOffset: 0, value: true),
            makeEntry(metricID: metric.id, dayOffset: -1, value: true)
        ]
        let longest = StreakUtils.calculateLongestStreak(for: metric, entries: entries)
        XCTAssertEqual(longest, 2)
    }

    func testNeverLoggedMetricHasZeroLongestStreak() {
        let metric = makeMetric(type: .positive, logged: false)
        let entries = (-2...0).map { makeEntry(metricID: metric.id, dayOffset: $0, value: true) }
        XCTAssertEqual(StreakUtils.calculateLongestStreak(for: metric, entries: entries), 0)
    }

    func testAggregateCurrentStreakCountsDaysWithAnyMetricSuccess() {
        let habit = makeMetric(type: .positive, logged: true)
        let vice = makeMetric(type: .vice, logged: true)
        let entries = [
            makeEntry(metricID: habit.id, dayOffset: -1, value: true),
            makeEntry(metricID: vice.id, dayOffset: 0, value: false)
        ]
        let streak = StreakUtils.calculateAggregateCurrentStreak(
            metrics: [habit, vice],
            entries: entries,
            selectedDate: today
        )
        XCTAssertEqual(streak, 2)
    }

    func testAggregateStreakIgnoresUnloggedViceStub() {
        let vice = makeMetric(type: .vice, logged: true)
        let entries = [makeEntry(metricID: vice.id, dayOffset: 0, value: false, logged: false)]
        let streak = StreakUtils.calculateFilterCurrentStreak(
            filter: .specific(vice),
            metrics: [vice],
            entries: entries,
            selectedDate: today
        )
        XCTAssertEqual(streak, 0)
    }

    func testFilterCurrentStreakDelegatesToPerMetricForSpecificFilter() {
        let metric = makeMetric(type: .positive, logged: true)
        let entries = (0...1).map { makeEntry(metricID: metric.id, dayOffset: -$0, value: true) }
        let streak = StreakUtils.calculateFilterCurrentStreak(
            filter: .specific(metric),
            metrics: [metric],
            entries: entries,
            selectedDate: today
        )
        XCTAssertEqual(streak, 2)
    }
}
