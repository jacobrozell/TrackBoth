import XCTest
@testable import TrackBoth

final class SettingsViewModelTests: XCTestCase {

    private var viewModel: SettingsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = SettingsViewModel()
    }

    func testCountsMetricsEntriesAndTypes() {
        let habit = Metric(name: "Read", habitType: .positive)
        let vice = Metric(name: "Smoke", habitType: .vice)
        let goal = Goal(goalType: .boolean, period: .weekly, target: 1)
        goal.metric = habit
        habit.goals = [goal]

        let entry = MetricEntry(metricID: habit.id, date: Date(), value: true, motivation: "Focus", starred: true, hasBeenLogged: true)

        XCTAssertEqual(viewModel.totalMetrics([habit, vice]), 2)
        XCTAssertEqual(viewModel.positiveHabits([habit, vice]), 1)
        XCTAssertEqual(viewModel.vices([habit, vice]), 1)
        XCTAssertEqual(viewModel.totalEntries([entry]), 1)
        XCTAssertEqual(viewModel.entriesWithMotivation([entry]), 1)
        XCTAssertEqual(viewModel.starredEntries([entry]), 1)
    }

    func testExportDataAsCSVIncludesHeaderAndRow() {
        let metric = Metric(name: "Read", habitType: .positive)
        let entry = MetricEntry(metricID: metric.id, date: Date(), value: true, hasBeenLogged: true)
        let csv = viewModel.exportDataAsCSV([metric], entries: [entry])
        XCTAssertTrue(csv.contains("Metric Name,Habit Type,Date,Value,Motivation,Details,Starred"))
        XCTAssertTrue(csv.contains("Read"))
    }

    func testExportMetricsAsCSVIncludesGoalColumns() {
        let metric = Metric(name: "Read", habitType: .positive)
        let goal = Goal(goalType: .boolean, period: .weekly, target: 3)
        goal.metric = metric
        metric.goals = [goal]
        let csv = viewModel.exportMetricsAsCSV([metric])
        XCTAssertTrue(csv.contains("Goal Period"))
        XCTAssertTrue(csv.contains("Read"))
    }

    func testShowExportSheetAndReset() {
        viewModel.showExportSheet()
        XCTAssertTrue(viewModel.showingExportSheet)
        viewModel.reset()
        XCTAssertFalse(viewModel.showingExportSheet)
    }
}
