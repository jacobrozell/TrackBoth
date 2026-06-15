import XCTest
@testable import TrackBoth

final class QueryDescriptorsTests: XCTestCase {

    func testChartLookbackCoversHeatmapWindow() {
        XCTAssertGreaterThanOrEqual(
            QueryDescriptors.chartLookbackDays,
            90,
            "Chart query scope should cover heatmap dayCount"
        )
    }

    func testGoalLookbackCoversYearlyPeriod() {
        XCTAssertGreaterThanOrEqual(
            QueryDescriptors.goalLookbackDays,
            GoalPeriod.yearly.maxDays
        )
    }

    func testStreakLookbackMatchesProcessorNeeds() {
        XCTAssertEqual(QueryDescriptors.streakLookbackDays, 365)
    }
}
