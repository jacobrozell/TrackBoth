import XCTest
@testable import TrackBoth

final class ChartDataProcessorTests: XCTestCase {

    private func makeMetric(name: String, type: HabitType) -> Metric {
        Metric(name: name, habitType: type)
    }

    func testWeeklySuccessCountsGroupsByWeek() {
        let habit = makeMetric(name: "Read", type: .positive)
        let weekStart = CalendarHelper.startOfWeek(for: Date())
        let entry = MetricEntry(metricID: habit.id, date: weekStart, value: true, hasBeenLogged: true)

        let weekly = ChartDataProcessor.weeklySuccessCounts(
            filter: .all,
            entries: [entry],
            metrics: [habit]
        )

        XCTAssertEqual(weekly.count, 1)
        XCTAssertEqual(weekly.first?.count, 1)
    }

    func testCumulativeSuccessTrendIncrementsOnSuccessfulDay() {
        let habit = makeMetric(name: "Read", type: .positive)
        let today = Calendar.current.startOfDay(for: Date())
        let entry = MetricEntry(metricID: habit.id, date: today, value: true, hasBeenLogged: true)

        let trend = ChartDataProcessor.cumulativeSuccessTrend(
            filter: .all,
            entries: [entry],
            metrics: [habit],
            dayCount: 1,
            endDate: today
        )

        XCTAssertEqual(trend.last?.value, 1)
    }
}
