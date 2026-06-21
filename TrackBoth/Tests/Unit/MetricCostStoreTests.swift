import XCTest
import SwiftData
@testable import TrackBoth

final class MetricCostStoreTests: XCTestCase {

    override func tearDown() {
        MetricCostStore.clearAll()
        super.tearDown()
    }

    func testLegacyCostMapRoundTrip() {
        let key = UUID().uuidString
        UserDefaults.standard.set([key: "8.5"], forKey: "metricCostPerUnit")
        defer { MetricCostStore.clearAll() }

        XCTAssertEqual(MetricCostStore.legacyCostMap()[key], "8.5")
    }

    func testMetricCostPerUnitHelpers() {
        let metric = Metric(name: "Coffee", habitType: .vice)
        metric.setCostPerUnitDecimal(8.5)
        XCTAssertEqual(metric.costPerUnitDecimal, 8.5)
        XCTAssertEqual(metric.costPerUnit, "8.5")

        metric.setCostPerUnitDecimal(nil)
        XCTAssertNil(metric.costPerUnitDecimal)
        XCTAssertNil(metric.costPerUnit)
    }

    func testMigrateCostPerUnitFromUserDefaults() throws {
        let container = try ModelContainer(
            for: Schema([Metric.self, MetricEntry.self, Goal.self]),
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let context = ModelContext(container)

        let metric = Metric(name: "Smoking", habitType: .vice)
        context.insert(metric)
        try context.save()

        UserDefaults.standard.set([metric.id.uuidString: "12"], forKey: "metricCostPerUnit")
        MigrationUtils.migrateCostPerUnitFromUserDefaults(in: context)

        XCTAssertEqual(metric.costPerUnitDecimal, 12)
        XCTAssertTrue(MetricCostStore.legacyCostMap().isEmpty)
    }
}
