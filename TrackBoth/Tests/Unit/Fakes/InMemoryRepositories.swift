import Foundation
@testable import TrackBoth

// MARK: - In-Memory Repository Fakes
//
// Drop-in fakes for `EntryRepository` / `MetricRepository` so view models can be
// unit-tested without a `ModelContext` or SwiftData container. Add this file to the
// unit-test target in Xcode (Target Membership → TrackBothTests).
//
// NOTE: not yet a member of any target. It will not compile or run until added.

final class InMemoryEntryRepository: EntryRepository {
    private(set) var entries: [MetricEntry]

    init(entries: [MetricEntry] = []) {
        self.entries = entries
    }

    func fetchAll() throws -> [MetricEntry] {
        entries.sorted { $0.date > $1.date }
    }

    func fetch(from start: Date, before end: Date) throws -> [MetricEntry] {
        entries
            .filter { $0.date >= start && $0.date < end }
            .sorted { $0.date > $1.date }
    }

    func fetchForMetric(_ metricID: UUID, from start: Date, before end: Date) throws -> [MetricEntry] {
        entries
            .filter { $0.metricID == metricID && $0.date >= start && $0.date < end }
            .sorted { $0.date > $1.date }
    }

    func entry(for metricID: UUID, on date: Date) throws -> MetricEntry? {
        let calendar = Calendar.current
        let sameDay = entries.filter {
            $0.metricID == metricID && calendar.isDate($0.date, inSameDayAs: date)
        }
        return sameDay.first(where: { $0.hasBeenLogged }) ?? sameDay.first
    }

    @discardableResult
    func getOrCreate(for metricID: UUID, on date: Date) throws -> MetricEntry {
        if let existing = try entry(for: metricID, on: date) {
            return existing
        }
        let startOfDay = Calendar.current.startOfDay(for: date)
        let newEntry = MetricEntry(metricID: metricID, date: startOfDay, value: false, hasBeenLogged: false)
        entries.append(newEntry)
        return newEntry
    }

    func insert(_ entry: MetricEntry) {
        entries.append(entry)
    }

    func delete(_ entry: MetricEntry) {
        entries.removeAll { $0.id == entry.id }
    }

    func deleteAll() throws {
        entries.removeAll()
    }

    func deleteEntries(for metricID: UUID) throws {
        entries.removeAll { $0.metricID == metricID }
    }
}

final class InMemoryMetricRepository: MetricRepository {
    private(set) var metrics: [Metric]

    init(metrics: [Metric] = []) {
        self.metrics = metrics
    }

    func fetchAll(sortedByName: Bool = true) throws -> [Metric] {
        sortedByName ? metrics.sorted { $0.name < $1.name } : metrics
    }

    func insert(_ metric: Metric) {
        metrics.append(metric)
    }

    func delete(_ metric: Metric) {
        metrics.removeAll { $0.id == metric.id }
    }

    func deleteAll() throws {
        metrics.removeAll()
    }
}
