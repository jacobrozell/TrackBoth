import XCTest
import SwiftData
@testable import TrackBoth

final class EntryStoreTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var metricID: UUID!

    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Metric.self, MetricEntry.self, Goal.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = ModelContext(container)
        metricID = UUID()
    }

    func testFetchFromDateRange() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let store = EntryStore(context: context)
        store.insert(MetricEntry(metricID: metricID, date: yesterday, value: true))
        store.insert(MetricEntry(metricID: metricID, date: today, value: true))

        let entries = try store.fetch(from: yesterday, before: tomorrow)
        XCTAssertEqual(entries.count, 2)
    }

    func testDeleteEntriesForMetric() throws {
        let otherID = UUID()
        let store = EntryStore(context: context)
        store.insert(MetricEntry(metricID: metricID, date: Date(), value: true))
        store.insert(MetricEntry(metricID: otherID, date: Date(), value: true))

        try store.deleteEntries(for: metricID)
        let remaining = try store.fetchAll()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.metricID, otherID)
    }
}
