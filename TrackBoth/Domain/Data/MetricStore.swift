import Foundation
import SwiftData

// MARK: - MetricRepository
/// Persistence boundary for `Metric`. View models depend on this protocol,
/// never on `ModelContext` directly, so they can be unit-tested with an in-memory fake.
protocol MetricRepository {
    func fetchAll(sortedByName: Bool) throws -> [Metric]
    func insert(_ metric: Metric)
    func delete(_ metric: Metric)
    func deleteAll() throws
}

// MARK: - Metric Store
/// SwiftData-backed implementation of `MetricRepository`.
struct MetricStore: MetricRepository {
    let context: ModelContext

    func fetchAll(sortedByName: Bool = true) throws -> [Metric] {
        var descriptor = FetchDescriptor<Metric>()
        if sortedByName {
            descriptor.sortBy = [SortDescriptor(\.name)]
        }
        return try context.fetch(descriptor)
    }

    func insert(_ metric: Metric) {
        context.insert(metric)
    }

    func delete(_ metric: Metric) {
        context.delete(metric)
    }

    func deleteAll() throws {
        try fetchAll(sortedByName: false).forEach { context.delete($0) }
    }
}
