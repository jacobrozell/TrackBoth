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
        let entries = [
            makeEntry(metricID: read.id, motivation: "A"),
            makeEntry(metricID: smoke.id, motivation: "B")
        ]
        XCTAssertEqual(viewModel.entriesForSelectedMetric(entries, metric: read).count, 1)
        XCTAssertEqual(viewModel.motivationEntries(entries, for: read).count, 1)
    }

    func testDisplayMetricsOrdersVicesFirst() {
        let habit = Metric(name: "Alpha Habit", habitType: .positive)
        let vice = Metric(name: "Beta Vice", habitType: .vice)
        let ordered = viewModel.displayMetrics([habit, vice])
        XCTAssertEqual(ordered.map(\.name), ["Beta Vice", "Alpha Habit"])
    }

    func testNotesForMetricFiltersAndSorts() {
        let metric = Metric(name: "Smoke", habitType: .vice)
        let older = makeEntry(metricID: metric.id, motivation: "Older")
        older.date = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let newer = makeEntry(metricID: metric.id, motivation: "Newer")
        let other = makeEntry(metricID: UUID(), motivation: "Other")

        let notes = viewModel.notes(for: metric, entries: [older, newer, other])
        XCTAssertEqual(notes.count, 2)
        XCTAssertEqual(notes.first?.motivation, "Newer")
    }

    func testHasWhyIgnoresWhitespace() {
        let metric = Metric(name: "Smoke", habitType: .vice)
        metric.primaryMotivation = "  "
        XCTAssertFalse(viewModel.hasWhy(metric))
        metric.primaryMotivation = "Health"
        XCTAssertTrue(viewModel.hasWhy(metric))
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
        viewModel.motivationSheet = .addNote(Metric(name: "Read", habitType: .positive))
        viewModel.reset()
        XCTAssertEqual(viewModel.selectedFilter, .all)
        XCTAssertNil(viewModel.motivationSheet)
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
        XCTAssertEqual(viewModel.viceDisplayMetrics([habit, vice]).count, 0)
        XCTAssertEqual(viewModel.habitDisplayMetrics([habit, vice]).count, 1)

        viewModel.selectedFilter = .all
        XCTAssertEqual(viewModel.viceDisplayMetrics([habit, vice]).count, 1)
        XCTAssertEqual(viewModel.habitDisplayMetrics([habit, vice]).count, 1)
    }
}
