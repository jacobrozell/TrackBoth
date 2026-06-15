import Foundation
import SwiftData

// MARK: - Metric Store
/// Repository for `Metric` persistence operations.
struct MetricStore {
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
