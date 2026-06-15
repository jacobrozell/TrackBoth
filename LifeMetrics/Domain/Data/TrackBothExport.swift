import Foundation

// MARK: - Export / Import
/// Versioned JSON export format for TrackBoth data.
enum TrackBothExport {
    static let currentSchemaVersion = 2

    struct Payload: Codable, Equatable {
        let schemaVersion: Int
        let metrics: [MetricRecord]
        let entries: [EntryRecord]
        let exportDate: Date
    }

    struct MetricRecord: Codable, Equatable {
        let id: String
        let name: String
        let createdAt: Date
        let habitType: String
        let hasBeenLogged: Bool?
    }

    struct EntryRecord: Codable, Equatable {
        let id: String
        let metricID: String
        let date: Date
        let value: Bool
        let details: String?
        let motivation: String?
        let starred: Bool?
        let quantity: Int?
        let unit: String?
        let hasBeenLogged: Bool?
    }

    static func makePayload(metrics: [Metric], entries: [MetricEntry], exportDate: Date = Date()) -> Payload {
        Payload(
            schemaVersion: currentSchemaVersion,
            metrics: metrics.map { metric in
                MetricRecord(
                    id: metric.id.uuidString,
                    name: metric.name,
                    createdAt: metric.createdAt,
                    habitType: metric.habitType.rawValue,
                    hasBeenLogged: metric.hasBeenLogged
                )
            },
            entries: entries.map { entry in
                EntryRecord(
                    id: entry.id.uuidString,
                    metricID: entry.metricID.uuidString,
                    date: entry.date,
                    value: entry.value,
                    details: entry.details,
                    motivation: entry.motivation,
                    starred: entry.starred,
                    quantity: entry.quantity,
                    unit: entry.unit,
                    hasBeenLogged: entry.hasBeenLogged
                )
            },
            exportDate: exportDate
        )
    }

    static func encode(metrics: [Metric], entries: [MetricEntry]) throws -> Data {
        try JSONEncoder().encode(makePayload(metrics: metrics, entries: entries))
    }

    static func decode(_ data: Data) throws -> Payload {
        try JSONDecoder().decode(Payload.self, from: data)
    }

    /// Rebuild export payload from decoded data (round-trip helper for tests).
    static func roundTrip(_ data: Data) throws -> Payload {
        try decode(data)
    }
}

// Legacy typealiases used by SettingsView share sheet.
typealias ExportData = TrackBothExport.Payload
typealias ExportMetric = TrackBothExport.MetricRecord
typealias ExportEntry = TrackBothExport.EntryRecord
