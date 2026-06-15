import XCTest
import SwiftData
@testable import TrackBoth

final class MetricStoreTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Metric.self, MetricEntry.self, Goal.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = ModelContext(container)
    }

    func testFetchAllReturnsInsertedMetrics() throws {
        let habit = Metric(name: "Read", habitType: .positive)
        MetricStore(context: context).insert(habit)

        let fetched = try MetricStore(context: context).fetchAll()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Read")
    }

    func testDeleteAllRemovesMetrics() throws {
        MetricStore(context: context).insert(Metric(name: "A", habitType: .positive))
        MetricStore(context: context).insert(Metric(name: "B", habitType: .vice))

        try MetricStore(context: context).deleteAll()
        XCTAssertTrue(try MetricStore(context: context).fetchAll().isEmpty)
    }
}
