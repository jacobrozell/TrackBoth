import Foundation

// MARK: - Export / Import
/// Versioned JSON export format for TrackBoth data.
enum TrackBothExport {
    static let currentSchemaVersion = 4

    struct Payload: Codable, Equatable {
        let schemaVersion: Int
        let metrics: [MetricRecord]
        let entries: [EntryRecord]
        let goals: [GoalRecord]?
        let exportDate: Date
    }

    struct MetricRecord: Codable, Equatable {
        let id: String
        let name: String
        let createdAt: Date
        let habitType: String
        let hasBeenLogged: Bool?
        let primaryMotivation: String?
        let costPerUnit: String?
    }

    struct GoalRecord: Codable, Equatable {
        let id: String
        let metricID: String
        let goalType: String
        let period: String
        let target: Int
        let createdAt: Date
        let quantityGoalType: String?
        let defaultUnit: String?
        let maxDailyQuantity: Int?
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
        let mood: String?
        let hasBeenLogged: Bool?
    }

    static func makePayload(metrics: [Metric], entries: [MetricEntry], exportDate: Date = Date()) -> Payload {
        let goalRecords = metrics.flatMap { metric -> [GoalRecord] in
            (metric.goals ?? []).map { goal in
                GoalRecord(
                    id: goal.id.uuidString,
                    metricID: metric.id.uuidString,
                    goalType: goal.goalType.rawValue,
                    period: goal.period.rawValue,
                    target: goal.target,
                    createdAt: goal.createdAt,
                    quantityGoalType: goal.quantityGoalType?.rawValue,
                    defaultUnit: goal.defaultUnit,
                    maxDailyQuantity: goal.maxDailyQuantity
                )
            }
        }

        return Payload(
            schemaVersion: currentSchemaVersion,
            metrics: metrics.map { metric in
                MetricRecord(
                    id: metric.id.uuidString,
                    name: metric.name,
                    createdAt: metric.createdAt,
                    habitType: metric.habitType.rawValue,
                    hasBeenLogged: metric.hasBeenLogged,
                    primaryMotivation: metric.primaryMotivation,
                    costPerUnit: metric.costPerUnit
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
                    mood: entry.mood,
                    hasBeenLogged: entry.hasBeenLogged
                )
            },
            goals: goalRecords.isEmpty ? nil : goalRecords,
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
