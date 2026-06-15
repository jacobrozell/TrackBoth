import XCTest
@testable import TrackBoth

final class HomeViewModelTests: XCTestCase {

    private var calendar: Calendar!
    private var today: Date!
    private var viewModel: HomeViewModel!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
        today = calendar.startOfDay(for: Date())
        viewModel = HomeViewModel()
    }

    private func makeMetric(name: String, type: HabitType, logged: Bool = true) -> Metric {
        let metric = Metric(name: name, habitType: type)
        metric.hasBeenLogged = logged
        return metric
    }

    private func makeEntry(metricID: UUID, dayOffset: Int, value: Bool, logged: Bool = true) -> MetricEntry {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        return MetricEntry(
            metricID: metricID,
            date: calendar.startOfDay(for: date),
            value: value,
            hasBeenLogged: logged
        )
    }

    func testTotalHabitsAndVices() {
        let metrics = [
            makeMetric(name: "Read", type: .positive),
            makeMetric(name: "Exercise", type: .positive),
            makeMetric(name: "Smoke", type: .vice)
        ]
        XCTAssertEqual(viewModel.totalHabits(from: metrics), 2)
        XCTAssertEqual(viewModel.totalVices(from: metrics), 1)
    }

    func testTodayCompletedCountsSuccessfulEntries() {
        let habit = makeMetric(name: "Read", type: .positive)
        let vice = makeMetric(name: "Smoke", type: .vice)
        let entries = [
            makeEntry(metricID: habit.id, dayOffset: 0, value: true),
            makeEntry(metricID: vice.id, dayOffset: 0, value: false)
        ]

        XCTAssertEqual(viewModel.todayCompleted(from: [habit, vice], entries: entries), 2)
    }

    func testActiveStreaksCountsMetricsWithStreak() {
        let habit = makeMetric(name: "Read", type: .positive)
        let entries = (0...2).map { makeEntry(metricID: habit.id, dayOffset: -$0, value: true) }
        XCTAssertEqual(viewModel.activeStreaks(from: [habit], entries: entries), 1)
    }

    func testIsTodayAndNavigationBounds() {
        viewModel.selectedDate = today
        XCTAssertTrue(viewModel.isToday)
        XCTAssertFalse(viewModel.canGoForward)

        let thirtyOneDaysAgo = calendar.date(byAdding: .day, value: -31, to: today)!
        viewModel.selectedDate = thirtyOneDaysAgo
        XCTAssertFalse(viewModel.canGoBack)
    }

    func testGoToTodayResetsSelectedDate() {
        viewModel.selectedDate = calendar.date(byAdding: .day, value: -3, to: today)!
        viewModel.goToToday()
        XCTAssertTrue(calendar.isDate(viewModel.selectedDate, inSameDayAs: today))
    }

    func testResetClearsSheetState() {
        viewModel.showingAddMetric = true
        viewModel.showingSettings = true
        viewModel.reset()
        XCTAssertFalse(viewModel.showingAddMetric)
        XCTAssertFalse(viewModel.showingSettings)
    }
}
