import XCTest
@testable import TrackBoth

final class MotivationViewModelTests: XCTestCase {

    private var viewModel: MotivationViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MotivationViewModel()
    }

    private func makeEntry(metricID: UUID, motivation: String? = nil, details: String? = nil, starred: Bool = false) -> MetricEntry {
        MetricEntry(
            metricID: metricID,
            date: Date(),
            value: true,
            motivation: motivation,
            starred: starred,
            details: details,
            hasBeenLogged: true
        )
    }

    func testEntriesWithMotivationFiltersAndSorts() {
        let id = UUID()
        let older = makeEntry(metricID: id, motivation: "Older")
        older.date = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let newer = makeEntry(metricID: id, motivation: "Newer")
        let empty = makeEntry(metricID: id)

        let result = viewModel.entriesWithMotivation([older, newer, empty])
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.motivation, "Newer")
    }

    func testEntriesWithDetailsAndStarred() {
        let id = UUID()
        let detailed = makeEntry(metricID: id, details: "Note")
        let starred = makeEntry(metricID: id, starred: true)

        XCTAssertEqual(viewModel.entriesWithDetails([detailed, starred]).count, 1)
        XCTAssertEqual(viewModel.starredEntries([detailed, starred]).count, 1)
        XCTAssertTrue(viewModel.hasAnyContent([detailed, starred]))
    }

    func testEntriesForSelectedMetric() {
        let read = Metric(name: "Read", habitType: .positive)
        let smoke = Metric(name: "Smoke", habitType: .vice)
        viewModel.selectedMetric = read
        let entries = [
            makeEntry(metricID: read.id, motivation: "A"),
            makeEntry(metricID: smoke.id, motivation: "B")
        ]
        XCTAssertEqual(viewModel.entriesForSelectedMetric(entries).count, 1)
        XCTAssertEqual(viewModel.motivationEntries(entries).count, 1)
    }

    func testViceMetricsFilter() {
        let metrics = [
            Metric(name: "Read", habitType: .positive),
            Metric(name: "Smoke", habitType: .vice)
        ]
        XCTAssertEqual(viewModel.viceMetrics(metrics).count, 1)
    }

    func testResetClearsSelectionAndSheets() {
        viewModel.selectedFilter = .specific(Metric(name: "Read", habitType: .positive))
        viewModel.selectedMetric = Metric(name: "Read", habitType: .positive)
        viewModel.showingAddMotivation = true
        viewModel.reset()
        XCTAssertEqual(viewModel.selectedFilter, .all)
        XCTAssertNil(viewModel.selectedMetric)
        XCTAssertFalse(viewModel.showingAddMotivation)
    }

    func testPrimaryAndDailyMotivationsRespectFilter() {
        let habit = Metric(name: "Read", habitType: .positive)
        habit.primaryMotivation = "Books"
        let vice = Metric(name: "Smoke", habitType: .vice)
        let entries = [
            makeEntry(metricID: habit.id, motivation: "Focus"),
            makeEntry(metricID: vice.id, motivation: "Quit")
        ]

        viewModel.selectedFilter = .allHabits
        XCTAssertEqual(viewModel.primaryMotivations([habit, vice]).count, 1)
        XCTAssertEqual(viewModel.dailyMotivations(entries, metrics: [habit, vice]).count, 1)
    }
}
