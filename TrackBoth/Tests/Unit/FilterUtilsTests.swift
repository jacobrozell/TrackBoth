import XCTest
@testable import TrackBoth

final class FilterUtilsTests: XCTestCase {

    private func makeMetric(name: String, type: HabitType) -> Metric {
        Metric(name: name, habitType: type)
    }

    private func makeEntry(metricID: UUID, value: Bool, logged: Bool = true) -> MetricEntry {
        MetricEntry(metricID: metricID, date: Date(), value: value, hasBeenLogged: logged)
    }

    func testFilteredMetricsAllHabits() {
        let habit = makeMetric(name: "Habit", type: .positive)
        let vice = makeMetric(name: "Vice", type: .vice)
        let metrics = [habit, vice]

        let filtered = FilterUtils.filteredMetrics(.allHabits, in: metrics)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.id, habit.id)
    }

    func testFilteredMetricsSpecificMetric() {
        let habit = makeMetric(name: "Habit", type: .positive)
        let vice = makeMetric(name: "Vice", type: .vice)
        let metrics = [habit, vice]

        let filtered = FilterUtils.filteredMetrics(.specific(vice), in: metrics)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.id, vice.id)
    }

    func testAllFilterIncludesEveryEntry() {
        let habit = makeMetric(name: "Habit", type: .positive)
        let vice = makeMetric(name: "Vice", type: .vice)
        let metrics = [habit, vice]
        let entries = [
            makeEntry(metricID: habit.id, value: true),
            makeEntry(metricID: vice.id, value: false)
        ]

        let filtered = FilterUtils.filteredEntries(.all, entries: entries, metrics: metrics)
        XCTAssertEqual(filtered.count, 2)
    }

    func testAllHabitsFilter() {
        let habit = makeMetric(name: "Habit", type: .positive)
        let vice = makeMetric(name: "Vice", type: .vice)
        let metrics = [habit, vice]
        let entries = [
            makeEntry(metricID: habit.id, value: true),
            makeEntry(metricID: vice.id, value: false)
        ]

        let filtered = FilterUtils.filteredEntries(.allHabits, entries: entries, metrics: metrics)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.metricID, habit.id)
    }

    func testAllVicesFilter() {
        let habit = makeMetric(name: "Habit", type: .positive)
        let vice = makeMetric(name: "Vice", type: .vice)
        let metrics = [habit, vice]
        let entries = [
            makeEntry(metricID: habit.id, value: true),
            makeEntry(metricID: vice.id, value: false)
        ]

        let filtered = FilterUtils.filteredEntries(.allVices, entries: entries, metrics: metrics)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.metricID, vice.id)
    }

    func testSpecificMetricFilter() {
        let habit = makeMetric(name: "Habit", type: .positive)
        let vice = makeMetric(name: "Vice", type: .vice)
        let metrics = [habit, vice]
        let entries = [
            makeEntry(metricID: habit.id, value: true),
            makeEntry(metricID: vice.id, value: false)
        ]

        let filtered = FilterUtils.filteredEntries(.specific(habit), entries: entries, metrics: metrics)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.metricID, habit.id)
    }

    func testSuccessfulEntriesUsesTrackingSemantics() {
        let habit = makeMetric(name: "Habit", type: .positive)
        let vice = makeMetric(name: "Vice", type: .vice)
        let metrics = [habit, vice]
        let entries = [
            makeEntry(metricID: habit.id, value: true),
            makeEntry(metricID: habit.id, value: false),
            makeEntry(metricID: vice.id, value: false),
            makeEntry(metricID: vice.id, value: true),
            makeEntry(metricID: vice.id, value: false, logged: false)
        ]

        let successful = FilterUtils.successfulEntries(.all, entries: entries, metrics: metrics)
        XCTAssertEqual(successful.count, 2)
        XCTAssertTrue(successful.contains { $0.metricID == habit.id && $0.value == true })
        XCTAssertTrue(successful.contains { $0.metricID == vice.id && $0.value == false })
    }
}
