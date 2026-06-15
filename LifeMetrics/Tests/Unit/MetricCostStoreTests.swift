import XCTest
@testable import TrackBoth

final class MetricCostStoreTests: XCTestCase {
    override func tearDown() {
        MetricCostStore.clearAll()
        super.tearDown()
    }

    func testSetAndReadCost() {
        let id = UUID()
        MetricCostStore.setCostPerUnit(8.5, for: id)
        XCTAssertEqual(MetricCostStore.costPerUnit(for: id), 8.5)
        XCTAssertEqual(MetricCostStore.encodedCostPerUnit(for: id), "8.5")
    }

    func testRemoveClearsCost() {
        let id = UUID()
        MetricCostStore.setCostPerUnit(5, for: id)
        MetricCostStore.remove(for: id)
        XCTAssertNil(MetricCostStore.costPerUnit(for: id))
    }

    func testClearAllRemovesEveryCost() {
        let id = UUID()
        MetricCostStore.setCostPerUnit(5, for: id)
        MetricCostStore.clearAll()
        XCTAssertNil(MetricCostStore.costPerUnit(for: id))
    }
}
