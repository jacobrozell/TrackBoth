import XCTest
@testable import TrackBoth

final class ChartCopyTests: XCTestCase {

    func testLineTitleForHabitsFilter() {
        XCTAssertEqual(
            ChartCopy.title(chartType: .line, filter: .allHabits),
            "30-Day Completion Trend"
        )
    }

    func testBarEmptyMessageForSpecificVice() {
        let vice = Metric(name: "Smoke", habitType: .vice)
        let message = ChartCopy.emptyMessage(chartType: .bar, filter: .specific(vice))
        XCTAssertEqual(message, "Avoid this vice to see weekly patterns")
    }

    func testQuantityTitleForSpecificMetric() {
        let habit = Metric(name: "Read", habitType: .positive)
        XCTAssertEqual(
            ChartCopy.title(chartType: .quantity, filter: .specific(habit)),
            "Quantity Tracking - Read"
        )
    }
}
