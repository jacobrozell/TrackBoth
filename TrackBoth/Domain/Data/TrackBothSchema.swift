import SwiftData

// MARK: - TrackBoth Schema
enum TrackBothSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Metric.self, MetricEntry.self, Goal.self]
    }
}

enum TrackBothMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TrackBothSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
