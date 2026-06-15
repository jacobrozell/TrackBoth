import Foundation
import SwiftData

// MARK: - Entry Store
/// Repository for `MetricEntry` persistence operations.
struct EntryStore {
    let context: ModelContext

    func fetchAll() throws -> [MetricEntry] {
        try context.fetch(FetchDescriptor<MetricEntry>())
    }

    func fetch(from start: Date, before end: Date) throws -> [MetricEntry] {
        let predicate = #Predicate<MetricEntry> { entry in
            entry.date >= start && entry.date < end
        }
        var descriptor = FetchDescriptor<MetricEntry>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        return try context.fetch(descriptor)
    }

    func fetchForMetric(_ metricID: UUID, from start: Date, before end: Date) throws -> [MetricEntry] {
        let predicate = #Predicate<MetricEntry> { entry in
            entry.metricID == metricID && entry.date >= start && entry.date < end
        }
        var descriptor = FetchDescriptor<MetricEntry>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        return try context.fetch(descriptor)
    }

    func insert(_ entry: MetricEntry) {
        context.insert(entry)
    }

    func delete(_ entry: MetricEntry) {
        context.delete(entry)
    }

    func deleteAll() throws {
        try fetchAll().forEach { context.delete($0) }
    }

    func deleteEntries(for metricID: UUID) throws {
        let predicate = #Predicate<MetricEntry> { $0.metricID == metricID }
        let entries = try context.fetch(FetchDescriptor<MetricEntry>(predicate: predicate))
        entries.forEach { context.delete($0) }
    }
}
