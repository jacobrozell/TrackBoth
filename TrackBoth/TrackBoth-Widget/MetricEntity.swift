import AppIntents
import Foundation

struct MetricEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Metric")
    static var defaultQuery = MetricEntityQuery()

    let id: String
    let name: String
    let habitType: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct MetricEntityQuery: EntityQuery {
    func entities(for identifiers: [MetricEntity.ID]) async throws -> [MetricEntity] {
        let snapshot = WidgetSnapshotStore.load() ?? .empty
        return snapshot.metrics
            .filter { identifiers.contains($0.id) }
            .map(Self.entity(from:))
    }

    func suggestedEntities() async throws -> [MetricEntity] {
        let snapshot = WidgetSnapshotStore.load() ?? .empty
        return snapshot.metrics.map(Self.entity(from:))
    }

    private static func entity(from metric: WidgetMetricSnapshot) -> MetricEntity {
        MetricEntity(id: metric.id, name: metric.name, habitType: metric.habitType)
    }
}

struct ViceMetricEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Vice")
    static var defaultQuery = ViceMetricEntityQuery()

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct ViceMetricEntityQuery: EntityQuery {
    func entities(for identifiers: [ViceMetricEntity.ID]) async throws -> [ViceMetricEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ViceMetricEntity] {
        let snapshot = WidgetSnapshotStore.load() ?? .empty
        return snapshot.vices().map { ViceMetricEntity(id: $0.id, name: $0.name) }
    }
}

struct ViceWithSavingsEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Vice with Savings")
    static var defaultQuery = ViceWithSavingsEntityQuery()

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct ViceWithSavingsEntityQuery: EntityQuery {
    func entities(for identifiers: [ViceWithSavingsEntity.ID]) async throws -> [ViceWithSavingsEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [ViceWithSavingsEntity] {
        let snapshot = WidgetSnapshotStore.load() ?? .empty
        return snapshot.vicesWithSavings().map { ViceWithSavingsEntity(id: $0.id, name: $0.name) }
    }
}

struct MotivatedMetricEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Motivated Metric")
    static var defaultQuery = MotivatedMetricEntityQuery()

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct MotivatedMetricEntityQuery: EntityQuery {
    func entities(for identifiers: [MotivatedMetricEntity.ID]) async throws -> [MotivatedMetricEntity] {
        try await suggestedEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [MotivatedMetricEntity] {
        let snapshot = WidgetSnapshotStore.load() ?? .empty
        return snapshot.metricsWithMotivation().map { MotivatedMetricEntity(id: $0.id, name: $0.name) }
    }
}
