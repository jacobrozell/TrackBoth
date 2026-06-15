import XCTest
import SwiftData
@testable import TrackBoth

final class ExportImportTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        container = try! ModelContainer(
            for: Schema([Metric.self, MetricEntry.self, Goal.self]),
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        context = ModelContext(container)
    }

    func testExportIncludesSchemaVersion() throws {
        let metric = Metric(name: "Run", habitType: .positive)
        metric.hasBeenLogged = true
        context.insert(metric)

        let entry = MetricEntry(metricID: metric.id, date: Date(), value: true, quantity: 3, unit: "miles", hasBeenLogged: true)
        context.insert(entry)
        try context.save()

        let payload = try ExportImportService.exportRoundTrip(metrics: [metric], entries: [entry])
        XCTAssertEqual(payload.schemaVersion, TrackBothExport.currentSchemaVersion)
        XCTAssertEqual(payload.metrics.count, 1)
        XCTAssertEqual(payload.entries.first?.quantity, 3)
        XCTAssertEqual(payload.entries.first?.hasBeenLogged, true)
    }

    func testImportRoundTripRestoresData() throws {
        let metric = Metric(name: "Coffee", habitType: .vice)
        metric.hasBeenLogged = true
        context.insert(metric)

        let day = Calendar.current.startOfDay(for: Date())
        let entry = MetricEntry(metricID: metric.id, date: day, value: false, hasBeenLogged: true)
        context.insert(entry)
        try context.save()

        let data = try TrackBothExport.encode(metrics: [metric], entries: [entry])
        let payload = try TrackBothExport.decode(data)
        let counts = try ExportImportService.importPayload(payload, into: context)

        XCTAssertEqual(counts.metrics, 1)
        XCTAssertEqual(counts.entries, 1)

        let importedMetrics = try context.fetch(FetchDescriptor<Metric>())
        let importedEntries = try context.fetch(FetchDescriptor<MetricEntry>())
        XCTAssertEqual(importedMetrics.first?.name, "Coffee")
        XCTAssertEqual(importedEntries.first?.value, false)
        XCTAssertTrue(importedEntries.first?.hasBeenLogged == true)
    }

    func testLegacyExportWithoutOptionalFieldsStillDecodes() throws {
        let metricID = UUID()
        let entryID = UUID()
        let payload = TrackBothExport.Payload(
            schemaVersion: 1,
            metrics: [
                TrackBothExport.MetricRecord(
                    id: metricID.uuidString,
                    name: "Read",
                    createdAt: Date(timeIntervalSince1970: 0),
                    habitType: "positive",
                    hasBeenLogged: nil
                )
            ],
            entries: [
                TrackBothExport.EntryRecord(
                    id: entryID.uuidString,
                    metricID: metricID.uuidString,
                    date: Date(timeIntervalSince1970: 86_400),
                    value: true,
                    details: nil,
                    motivation: nil,
                    starred: nil,
                    quantity: nil,
                    unit: nil,
                    hasBeenLogged: nil
                )
            ],
            exportDate: Date(timeIntervalSince1970: 172_800)
        )

        let data = try JSONEncoder().encode(payload)
        let decoded = try TrackBothExport.decode(data)
        XCTAssertEqual(decoded.schemaVersion, 1)
        XCTAssertNil(decoded.entries.first?.quantity)
    }
}
