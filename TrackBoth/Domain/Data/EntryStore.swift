import Foundation
import SwiftData

// MARK: - EntryRepository
/// Persistence boundary for `MetricEntry`. View models depend on this protocol,
/// never on `ModelContext` directly, so they can be unit-tested with an in-memory fake.
protocol EntryRepository {
    func fetchAll() throws -> [MetricEntry]
    func fetch(from start: Date, before end: Date) throws -> [MetricEntry]
    func fetchForMetric(_ metricID: UUID, from start: Date, before end: Date) throws -> [MetricEntry]
    /// Existing entry for the given metric/day without creating one. Prefers an
    /// explicitly logged entry, then any entry for that day.
    func entry(for metricID: UUID, on date: Date) throws -> MetricEntry?
    /// Existing entry for the given metric/day, inserting a new (unlogged) one if absent.
    @discardableResult
    func getOrCreate(for metricID: UUID, on date: Date) throws -> MetricEntry
    func insert(_ entry: MetricEntry)
    func delete(_ entry: MetricEntry)
    func deleteAll() throws
    func deleteEntries(for metricID: UUID) throws
}

// MARK: - Entry Store
/// SwiftData-backed implementation of `EntryRepository`.
struct EntryStore: EntryRepository {
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

    func entry(for metricID: UUID, on date: Date) throws -> MetricEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return nil }
        let predicate = #Predicate<MetricEntry> { entry in
            entry.metricID == metricID && entry.date >= startOfDay && entry.date < nextDay
        }
        let sameDay = try context.fetch(FetchDescriptor<MetricEntry>(predicate: predicate))
        return sameDay.first(where: { $0.hasBeenLogged }) ?? sameDay.first
    }

    @discardableResult
    func getOrCreate(for metricID: UUID, on date: Date) throws -> MetricEntry {
        if let existing = try entry(for: metricID, on: date) {
            return existing
        }
        let startOfDay = Calendar.current.startOfDay(for: date)
        let newEntry = MetricEntry(metricID: metricID, date: startOfDay, value: false, hasBeenLogged: false)
        context.insert(newEntry)
        return newEntry
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
