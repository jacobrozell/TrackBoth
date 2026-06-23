import XCTest
@testable import TrackBoth

final class ChartAccessibilitySummaryTests: XCTestCase {

    func testLineSummaryIncludesProgress() {
        let data = [
            ChartDataPoint(date: Date(), value: 2),
            ChartDataPoint(date: Date().addingTimeInterval(86400), value: 5)
        ]

        let summary = ChartAccessibilitySummary.lineSummary(data: data, filter: .allHabits)

        XCTAssertTrue(summary.contains("30-Day Completion Trend"))
        XCTAssertTrue(summary.contains("Cumulative total 5"))
        XCTAssertTrue(summary.contains("up 3 since the start"))
    }

    func testLineSummaryEmptyStateUsesCopy() {
        let summary = ChartAccessibilitySummary.lineSummary(data: [], filter: .allVices)

        XCTAssertTrue(summary.contains("30-Day Avoidance Trend"))
        XCTAssertTrue(summary.contains("Avoid vices to see your progress"))
    }

    func testHeatmapSummaryIncludesConsistencyPercent() {
        let data = [
            HeatmapData(date: Date(), completed: true),
            HeatmapData(date: Date().addingTimeInterval(86400), completed: false)
        ]

        let summary = ChartAccessibilitySummary.heatmapSummary(data: data, filter: .all)

        XCTAssertTrue(summary.contains("1 of 2 days completed"))
        XCTAssertTrue(summary.contains("50 percent consistency"))
    }

    func testBarSummaryIncludesBestWeek() {
        let data = [
            WeeklyData(week: "Jun 1", count: 2),
            WeeklyData(week: "Jun 8", count: 5)
        ]

        let summary = ChartAccessibilitySummary.barSummary(data: data, filter: .allHabits)

        XCTAssertTrue(summary.contains("best week Jun 8 with 5"))
    }

    func testStreakSummaryIncludesFilterLabel() {
        let metric = Metric(name: "Run", habitType: .positive)
        let summary = ChartAccessibilitySummary.streakSummary(
            current: 3,
            longest: 10,
            filter: .specific(metric)
        )

        XCTAssertTrue(summary.contains("Run"))
        XCTAssertTrue(summary.contains("Current streak 3 days"))
        XCTAssertTrue(summary.contains("Longest streak 10 days"))
    }
}
