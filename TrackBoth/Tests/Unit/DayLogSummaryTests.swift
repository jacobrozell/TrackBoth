import XCTest
@testable import TrackBoth

final class DayLogSummaryTests: XCTestCase {
    private let calendar = Calendar.current

    func testEmptyMetricsReturnsNone() {
        let state = DayLogSummary.completionState(metrics: [], entries: [], on: Date())
        XCTAssertEqual(state, .none)
    }

    func testNoEntriesReturnsNone() {
        let metric = Metric(name: "Exercise", habitType: .positive)
        let state = DayLogSummary.completionState(metrics: [metric], entries: [], on: Date())
        XCTAssertEqual(state, .none)
    }

    func testAllLoggedReturnsComplete() {
        let metricA = Metric(name: "Exercise", habitType: .positive)
        let metricB = Metric(name: "Social media", habitType: .vice)
        let day = calendar.startOfDay(for: Date())

        let entryA = MetricEntry(metricID: metricA.id, date: day, value: true, hasBeenLogged: true)
        let entryB = MetricEntry(metricID: metricB.id, date: day, value: false, hasBeenLogged: true)

        let state = DayLogSummary.completionState(
            metrics: [metricA, metricB],
            entries: [entryA, entryB],
            on: day
        )
        XCTAssertEqual(state, .complete)
    }

    func testSomeLoggedReturnsPartial() {
        let metricA = Metric(name: "Exercise", habitType: .positive)
        let metricB = Metric(name: "Social media", habitType: .vice)
        let day = calendar.startOfDay(for: Date())

        let entryA = MetricEntry(metricID: metricA.id, date: day, value: true, hasBeenLogged: true)

        let state = DayLogSummary.completionState(
            metrics: [metricA, metricB],
            entries: [entryA],
            on: day
        )
        XCTAssertEqual(state, .partial)
    }
}
