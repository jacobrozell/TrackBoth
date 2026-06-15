import Foundation
import SwiftData

// MARK: - Export Import Service
struct ExportImportService {

    @discardableResult
    static func importPayload(_ payload: TrackBothExport.Payload, into context: ModelContext) throws -> (metrics: Int, entries: Int) {
        guard payload.schemaVersion <= TrackBothExport.currentSchemaVersion else {
            throw ExportImportError.unsupportedSchema(payload.schemaVersion)
        }

        let metricStore = MetricStore(context: context)
        let entryStore = EntryStore(context: context)
        try entryStore.deleteAll()
        try metricStore.deleteAll()

        var metricByID: [UUID: Metric] = [:]
        for record in payload.metrics {
            guard let id = UUID(uuidString: record.id),
                  let habitType = HabitType(rawValue: record.habitType) else {
                continue
            }
            let metric = Metric(name: record.name, habitType: habitType)
            metric.id = id
            metric.createdAt = record.createdAt
            metric.hasBeenLogged = record.hasBeenLogged ?? false
            context.insert(metric)
            metricByID[id] = metric
        }

        var importedEntries = 0
        for record in payload.entries {
            guard let id = UUID(uuidString: record.id),
                  let metricID = UUID(uuidString: record.metricID),
                  metricByID[metricID] != nil else {
                continue
            }

            let entry = MetricEntry(
                metricID: metricID,
                date: record.date,
                value: record.value,
                motivation: record.motivation,
                starred: record.starred,
                details: record.details,
                quantity: record.quantity,
                unit: record.unit,
                hasBeenLogged: record.hasBeenLogged ?? false
            )
            entry.id = id
            context.insert(entry)
            importedEntries += 1
        }

        try context.save()
        return (payload.metrics.count, importedEntries)
    }

    static func exportRoundTrip(metrics: [Metric], entries: [MetricEntry]) throws -> TrackBothExport.Payload {
        let data = try TrackBothExport.encode(metrics: metrics, entries: entries)
        return try TrackBothExport.decode(data)
    }
}

enum ExportImportError: LocalizedError {
    case unsupportedSchema(Int)

    var errorDescription: String? {
        switch self {
        case .unsupportedSchema(let version):
            return "Unsupported export schema version \(version)."
        }
    }
}
