import XCTest
import SwiftData
@testable import TrackBoth

final class DemoDataGeneratorTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "hasDemoData")
        MetricCostStore.clearAll()
        MetricDisplayPreferences.clearAll()
        MilestoneStore.clearAll()
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
        let goals = try! context.fetch(FetchDescriptor<Goal>())
        XCTAssertGreaterThan(metrics.count, 0)
        XCTAssertGreaterThan(entries.count, 0)
        XCTAssertGreaterThan(goals.count, 0)

        DemoDataGenerator.clearDemoData(modelContext: context)
        XCTAssertFalse(DemoDataGenerator.hasDemoData())
        XCTAssertEqual(try! context.fetch(FetchDescriptor<Metric>()).count, 0)
        XCTAssertEqual(try! context.fetch(FetchDescriptor<Goal>()).count, 0)
    }

    func testDemoDataIncludesHabitsAndVices() {
        DemoDataGenerator.generateDemoData(modelContext: context)
        let metrics = try! context.fetch(FetchDescriptor<Metric>())

        XCTAssertEqual(metrics.filter { $0.habitType == .positive }.count, 4)
        XCTAssertEqual(metrics.filter { $0.habitType == .vice }.count, 4)
    }

    func testDemoSocialMediaShowsRecoveryTimerAndSlip() {
        DemoDataGenerator.generateDemoData(modelContext: context)
        let metrics = try! context.fetch(FetchDescriptor<Metric>())
        let entries = try! context.fetch(FetchDescriptor<MetricEntry>())

        guard let social = metrics.first(where: { $0.name == "Social media" }) else {
            XCTFail("Missing Social media metric")
            return
        }

        XCTAssertTrue(MetricDisplayPreferences.showTimeSinceSlip(for: social.id))
        XCTAssertNotNil(social.primaryMotivation)

        let label = ViceSlipTimer.compactRecoveryLabel(metricID: social.id, entries: entries)
        XCTAssertNotNil(label)
        XCTAssertTrue(label?.contains("recovering") == true)
    }

    func testDemoSmokingHasMoneySavedInputs() {
        DemoDataGenerator.generateDemoData(modelContext: context)
        let metrics = try! context.fetch(FetchDescriptor<Metric>())
        let entries = try! context.fetch(FetchDescriptor<MetricEntry>())

        guard let smoking = metrics.first(where: { $0.name == "Smoking" }) else {
            XCTFail("Missing Smoking metric")
            return
        }

        XCTAssertEqual(smoking.costPerUnitDecimal, 12)
        let streak = StreakUtils.calculateCurrentStreak(for: smoking, entries: entries)
        XCTAssertGreaterThanOrEqual(streak, 7)
        XCTAssertNotNil(ViceSavingsCalculator.savingsLabel(streak: streak, costPerUnit: 12))
    }

    func testDemoTodayEntriesAreLogged() {
        DemoDataGenerator.generateDemoData(modelContext: context)
        let metrics = try! context.fetch(FetchDescriptor<Metric>())
        let entries = try! context.fetch(FetchDescriptor<MetricEntry>())
        let today = Calendar.current.startOfDay(for: Date())

        for metric in metrics {
            let todayEntry = entries.first {
                $0.metricID == metric.id && Calendar.current.isDate($0.date, inSameDayAs: today)
            }
            XCTAssertNotNil(todayEntry, "Expected today entry for \(metric.name)")
            XCTAssertTrue(todayEntry?.hasBeenLogged == true)
        }
    }
}
