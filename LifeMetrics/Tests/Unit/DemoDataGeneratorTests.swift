import XCTest
import SwiftData
@testable import TrackBoth

final class DemoDataGeneratorTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "hasDemoData")
        let schema = Schema([Metric.self, MetricEntry.self, Goal.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "hasDemoData")
        DemoDataGenerator.clearDemoData(modelContext: context)
        super.tearDown()
    }

    func testGenerateAndClearDemoDataRoundTrip() {
        XCTAssertFalse(DemoDataGenerator.hasDemoData())

        DemoDataGenerator.generateDemoData(modelContext: context)
        XCTAssertTrue(DemoDataGenerator.hasDemoData())

        let metrics = try! context.fetch(FetchDescriptor<Metric>())
        let entries = try! context.fetch(FetchDescriptor<MetricEntry>())
        XCTAssertGreaterThan(metrics.count, 0)
        XCTAssertGreaterThan(entries.count, 0)

        DemoDataGenerator.clearDemoData(modelContext: context)
        XCTAssertFalse(DemoDataGenerator.hasDemoData())
        XCTAssertEqual(try! context.fetch(FetchDescriptor<Metric>()).count, 0)
    }
}
