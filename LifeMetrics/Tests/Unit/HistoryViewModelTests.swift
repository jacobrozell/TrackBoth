import XCTest
@testable import TrackBoth

final class HistoryViewModelTests: XCTestCase {

    private var viewModel: HistoryViewModel!

    override func setUp() {
        super.setUp()
        viewModel = HistoryViewModel()
    }

    private func makeMetric(name: String, type: HabitType) -> Metric {
        Metric(name: name, habitType: type)
    }

    func testFilteredMetricsByTypeAndSearch() {
        let read = makeMetric(name: "Read Books", type: .positive)
        let smoke = makeMetric(name: "Smoke", type: .vice)
        let metrics = [read, smoke]

        viewModel.selectedFilter = .allHabits
        XCTAssertEqual(viewModel.filteredMetrics(metrics).count, 1)

        viewModel.selectedFilter = .all
        viewModel.searchText = "read"
        XCTAssertEqual(viewModel.filteredMetrics(metrics).count, 1)
        XCTAssertEqual(viewModel.filteredMetrics(metrics).first?.name, "Read Books")
    }

    func testEntriesForSelectedDate() {
        let metric = makeMetric(name: "Read", type: .positive)
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let entries = [
            MetricEntry(metricID: metric.id, date: today, value: true, hasBeenLogged: true),
            MetricEntry(metricID: metric.id, date: yesterday, value: true, hasBeenLogged: true)
        ]

        viewModel.selectedDate = today
        XCTAssertEqual(viewModel.entriesForSelectedDate(entries, metrics: [metric]).count, 1)
        XCTAssertTrue(viewModel.hasEntriesForSelectedDate(entries, metrics: [metric]))
    }

    func testRecentEntriesFiltersByMonthAndSearch() {
        let metric = makeMetric(name: "Read", type: .positive)
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())!.start
        let inMonth = MetricEntry(metricID: metric.id, date: startOfMonth, value: true, details: "Morning read", hasBeenLogged: true)
        let outOfMonth = MetricEntry(
            metricID: metric.id,
            date: calendar.date(byAdding: .month, value: -2, to: startOfMonth)!,
            value: true,
            hasBeenLogged: true
        )

        viewModel.selectedDate = startOfMonth
        XCTAssertEqual(viewModel.recentEntries([inMonth, outOfMonth], metrics: [metric]).count, 1)

        viewModel.searchText = "morning"
        XCTAssertEqual(viewModel.recentEntries([inMonth, outOfMonth], metrics: [metric]).count, 1)
    }
}
