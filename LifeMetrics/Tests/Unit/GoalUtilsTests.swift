import XCTest
@testable import TrackBoth

final class GoalUtilsTests: XCTestCase {

    private var calendar: Calendar!
    private var today: Date!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
        today = calendar.startOfDay(for: Date())
    }

    private func makeMetric(type: HabitType) -> Metric {
        Metric(name: "Test", habitType: type)
    }

    private func makeGoal(type: GoalType, period: GoalPeriod, target: Int) -> Goal {
        Goal(goalType: type, period: period, target: target)
    }

    private func makeEntry(metricID: UUID, date: Date, value: Bool, logged: Bool = true) -> MetricEntry {
        MetricEntry(
            metricID: metricID,
            date: calendar.startOfDay(for: date),
            value: value,
            hasBeenLogged: logged
        )
    }

    func testHabitBooleanGoalCountsSuccessfulDays() {
        let metric = makeMetric(type: .positive)
        let goal = makeGoal(type: .boolean, period: .weekly, target: 3)
        let weekStart = CalendarHelper.startOfWeek(for: today)
        let entries = [
            makeEntry(metricID: metric.id, date: weekStart, value: true),
            makeEntry(metricID: metric.id, date: calendar.date(byAdding: .day, value: 1, to: weekStart)!, value: true),
            makeEntry(metricID: metric.id, date: calendar.date(byAdding: .day, value: 2, to: weekStart)!, value: false)
        ]

        let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(progress.current, 2)
        XCTAssertEqual(progress.target, 3)
    }

    func testViceBooleanGoalCountsAvoidedDays() {
        let metric = makeMetric(type: .vice)
        let goal = makeGoal(type: .boolean, period: .weekly, target: 2)
        let weekStart = CalendarHelper.startOfWeek(for: today)
        let entries = [
            makeEntry(metricID: metric.id, date: weekStart, value: false),
            makeEntry(metricID: metric.id, date: calendar.date(byAdding: .day, value: 1, to: weekStart)!, value: true),
            makeEntry(metricID: metric.id, date: calendar.date(byAdding: .day, value: 2, to: weekStart)!, value: false)
        ]

        let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(progress.current, 2)
    }

    func testUnloggedEntriesExcludedFromGoalProgress() {
        let metric = makeMetric(type: .positive)
        let goal = makeGoal(type: .boolean, period: .weekly, target: 1)
        let entries = [makeEntry(metricID: metric.id, date: today, value: true, logged: false)]

        let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(progress.current, 0)
    }

    func testHistoricalGoalWasAchieved() {
        let metric = makeMetric(type: .positive)
        let goal = makeGoal(type: .boolean, period: .weekly, target: 1)
        let start = CalendarHelper.startOfWeek(for: today)
        let end = CalendarHelper.endOfWeek(for: today)
        let entries = [makeEntry(metricID: metric.id, date: today, value: true)]

        let progress = GoalUtils.calculateHistoricalGoalProgress(
            for: goal,
            metric: metric,
            entries: entries,
            periodStart: start,
            periodEnd: end
        )
        XCTAssertTrue(progress.wasAchieved)
    }
}
