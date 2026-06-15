import XCTest
@testable import TrackBoth

final class ChartsViewModelTests: XCTestCase {

    private var viewModel: ChartsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ChartsViewModel()
    }

    private func makeMetric(name: String, type: HabitType) -> Metric {
        Metric(name: name, habitType: type)
    }

    func testFilteredMetricsByHabitType() {
        let metrics = [
            makeMetric(name: "Read", type: .positive),
            makeMetric(name: "Smoke", type: .vice)
        ]

        viewModel.selectedFilter = .allHabits
        XCTAssertEqual(viewModel.filteredMetrics(metrics).count, 1)
        XCTAssertEqual(viewModel.filteredMetrics(metrics).first?.habitType, .positive)

        viewModel.selectedFilter = .allVices
        XCTAssertEqual(viewModel.filteredMetrics(metrics).count, 1)
        XCTAssertEqual(viewModel.filteredMetrics(metrics).first?.habitType, .vice)
    }

    func testFilteredEntriesRespectsSelectedMetric() {
        let habit = makeMetric(name: "Read", type: .positive)
        let vice = makeMetric(name: "Smoke", type: .vice)
        let entries = [
            MetricEntry(metricID: habit.id, date: Date(), value: true, hasBeenLogged: true),
            MetricEntry(metricID: vice.id, date: Date(), value: false, hasBeenLogged: true)
        ]

        viewModel.selectedFilter = .specific(habit)
        XCTAssertEqual(viewModel.filteredEntries(entries, metrics: [habit, vice]).count, 1)
        XCTAssertEqual(viewModel.filteredEntries(entries, metrics: [habit, vice]).first?.metricID, habit.id)
    }

    func testHasDataToDisplayRequiresMetricsAndEntries() {
        let metric = makeMetric(name: "Read", type: .positive)
        let entry = MetricEntry(metricID: metric.id, date: Date(), value: true, hasBeenLogged: true)

        XCTAssertFalse(viewModel.hasDataToDisplay([], entries: [entry]))
        XCTAssertFalse(viewModel.hasDataToDisplay([metric], entries: []))
        XCTAssertTrue(viewModel.hasDataToDisplay([metric], entries: [entry]))
    }

    func testUpdateFilterAndChartType() {
        let metric = makeMetric(name: "Read", type: .positive)
        viewModel.updateFilter(.specific(metric))
        XCTAssertEqual(viewModel.selectedFilter, .specific(metric))

        viewModel.updateChartType(.heatmap)
        XCTAssertEqual(viewModel.selectedChartType, .heatmap)
    }

    func testResetRestoresDefaults() {
        viewModel.selectedFilter = .allVices
        viewModel.selectedChartType = .bar
        viewModel.showingSettings = true
        viewModel.reset()
        XCTAssertEqual(viewModel.selectedFilter, .all)
        XCTAssertEqual(viewModel.selectedChartType, .line)
        XCTAssertFalse(viewModel.showingSettings)
    }
}
