import XCTest
import SwiftData
@testable import TrackBoth

final class MetricEntryTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        let schema = Schema([Metric.self, MetricEntry.self, Goal.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    func testHasContentReflectsLoggedDetailsMotivationAndQuantity() {
        let logged = MetricEntry(metricID: UUID(), date: Date(), value: false, hasBeenLogged: true)
        XCTAssertTrue(logged.hasContent)

        let withDetails = MetricEntry(metricID: UUID(), date: Date(), value: false, details: "Note")
        XCTAssertTrue(withDetails.hasContent)

        let empty = MetricEntry(metricID: UUID(), date: Date(), value: false)
        XCTAssertFalse(empty.hasContent)

        let withQuantity = MetricEntry(metricID: UUID(), date: Date(), value: false, quantity: 3, unit: "pages")
        XCTAssertTrue(withQuantity.hasContent)
        XCTAssertEqual(withQuantity.quantityString, "3 pages")
    }

    func testFindReturnsExistingEntryWithoutCreating() {
        let metricID = UUID()
        let date = Calendar.current.startOfDay(for: Date())
        let entry = MetricEntry(metricID: metricID, date: date, value: true, hasBeenLogged: true)
        context.insert(entry)
        try! context.save()

        let found = MetricEntry.find(for: metricID, date: date, in: [entry])
        XCTAssertEqual(found?.id, entry.id)
    }

    func testGetOrCreateInsertsWhenMissing() {
        let metric = Metric(name: "Read", habitType: .positive)
        context.insert(metric)
        let date = Calendar.current.startOfDay(for: Date())

        let created = MetricEntry.getOrCreate(for: metric.id, date: date, in: context, entries: [], metric: metric)
        XCTAssertFalse(created.hasBeenLogged)

        let fetched = try! context.fetch(FetchDescriptor<MetricEntry>())
        XCTAssertEqual(fetched.count, 1)
    }

    func testUpdateOrCreateMarksLoggedWhenValueProvided() {
        let metric = Metric(name: "Read", habitType: .positive)
        context.insert(metric)
        let date = Calendar.current.startOfDay(for: Date())

        let entry = MetricEntry.updateOrCreate(
            for: metric.id,
            date: date,
            value: true,
            in: context,
            entries: [],
            metric: metric
        )

        XCTAssertTrue(entry.hasBeenLogged)
        XCTAssertTrue(metric.hasBeenLogged)
    }

    func testUpdateOrCreateDoesNotMarkLoggedForMotivationOnly() {
        let metric = Metric(name: "Read", habitType: .positive)
        context.insert(metric)
        let date = Calendar.current.startOfDay(for: Date())

        let entry = MetricEntry.updateOrCreate(
            for: metric.id,
            date: date,
            motivation: "Stay focused",
            in: context,
            entries: [],
            metric: metric
        )

        XCTAssertFalse(entry.hasBeenLogged)
        XCTAssertFalse(metric.hasBeenLogged)
        XCTAssertEqual(entry.motivation, "Stay focused")
    }

    func testCleanupEmptyEntriesRemovesPlaceholders() {
        let metricID = UUID()
        let empty = MetricEntry(metricID: metricID, date: Date(), value: false)
        let kept = MetricEntry(metricID: metricID, date: Date(), value: true, hasBeenLogged: true)
        context.insert(empty)
        context.insert(kept)

        MetricEntry.cleanupEmptyEntries(in: context, entries: [empty, kept])
        let remaining = try! context.fetch(FetchDescriptor<MetricEntry>())
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.id, kept.id)
    }
}
