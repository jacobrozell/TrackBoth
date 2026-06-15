import XCTest
@testable import TrackBoth

final class GoalsViewModelTests: XCTestCase {

    private var calendar: Calendar!
    private var today: Date!
    private var viewModel: GoalsViewModel!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
        today = calendar.startOfDay(for: Date())
        viewModel = GoalsViewModel()
    }

    private func makeMetric(type: HabitType, target: Int = 3) -> Metric {
        let metric = Metric(name: "Test", habitType: type)
        let goal = Goal(goalType: .boolean, period: .weekly, target: target)
        goal.metric = metric
        metric.goals = [goal]
        return metric
    }

    private func makeEntry(metricID: UUID, dayOffset: Int, value: Bool) -> MetricEntry {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return MetricEntry(
            metricID: metricID,
            date: calendar.startOfDay(for: date),
            value: value,
            hasBeenLogged: true
        )
    }

    func testMetricsWithGoalsFiltersCorrectly() {
        let withGoal = makeMetric(type: .positive)
        let withoutGoal = Metric(name: "Plain", habitType: .positive)
        let result = viewModel.metricsWithGoals([withGoal, withoutGoal])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, withGoal.id)
    }

    func testGoalProgressAndAchievement() {
        let metric = makeMetric(type: .positive, target: 2)
        let entries = [
            makeEntry(metricID: metric.id, dayOffset: 0, value: true),
            makeEntry(metricID: metric.id, dayOffset: -1, value: true)
        ]

        let progress = viewModel.goalProgress(for: metric, entries: entries, selectedDate: today)
        XCTAssertEqual(progress.target, 2)
        XCTAssertGreaterThanOrEqual(progress.current, 1)

        let status = viewModel.goalStatusText(for: metric, entries: entries, selectedDate: today)
        XCTAssertFalse(status.isEmpty)
    }

    func testMetricsWithoutGoals() {
        let withGoal = makeMetric(type: .positive)
        let withoutGoal = Metric(name: "Plain", habitType: .positive)
        XCTAssertEqual(viewModel.metricsWithoutGoals([withGoal, withoutGoal]).count, 1)
    }
}
