import Foundation
import SwiftData

// MARK: - Motivation Sheet
enum MotivationSheet: Identifiable {
    case editWhy(Metric)
    case addNote(Metric)

    var id: UUID {
        switch self {
        case .editWhy(let metric), .addNote(let metric):
            return metric.id
        }
    }

    var metric: Metric {
        switch self {
        case .editWhy(let metric), .addNote(let metric):
            return metric
        }
    }
}

// MARK: - MotivationViewModel
/// ViewModel for MotivationView containing motivation content logic
@Observable
class MotivationViewModel {

    // MARK: - Properties
    var selectedFilter: MetricFilter = .all
    var motivationSheet: MotivationSheet?
    var showingAddMetric = false

    // MARK: - Display Data

    /// Filtered metrics with vices first, then habits — both alphabetized within type.
    func displayMetrics(_ metrics: [Metric]) -> [Metric] {
        let filtered = FilterUtils.filteredMetrics(selectedFilter, in: metrics)
        let vices = filtered.filter { $0.habitType == .vice }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        let habits = filtered.filter { $0.habitType == .positive }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return vices + habits
    }

    func viceDisplayMetrics(_ metrics: [Metric]) -> [Metric] {
        displayMetrics(metrics).filter { $0.habitType == .vice }
    }

    func habitDisplayMetrics(_ metrics: [Metric]) -> [Metric] {
        displayMetrics(metrics).filter { $0.habitType == .positive }
    }

    func notes(for metric: Metric, entries: [MetricEntry]) -> [MetricEntry] {
        entries
            .filter { entry in
                entry.metricID == metric.id
                    && !(entry.motivation?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            }
            .sorted { $0.date > $1.date }
    }

    func hasWhy(_ metric: Metric) -> Bool {
        guard let text = metric.primaryMotivation?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
        return !text.isEmpty
    }

    func primaryMotivations(_ metrics: [Metric]) -> [Metric] {
        displayMetrics(metrics).filter(hasWhy)
    }

    func dailyMotivations(_ entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        let motivationEntries = entries.filter { entry in
            !(entry.motivation?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        }
        return FilterUtils.filteredEntries(selectedFilter, entries: motivationEntries, metrics: metrics)
            .sorted { $0.date > $1.date }
    }

    func hasAnyMotivations(_ metrics: [Metric], entries: [MetricEntry]) -> Bool {
        displayMetrics(metrics).contains { hasWhy($0) || !notes(for: $0, entries: entries).isEmpty }
    }

    func entriesWithMotivation(_ entries: [MetricEntry]) -> [MetricEntry] {
        entries.filter { entry in
            !(entry.motivation?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        }.sorted { $0.date > $1.date }
    }

    func starredEntries(_ entries: [MetricEntry]) -> [MetricEntry] {
        entries.filter(\.safeStarred).sorted { $0.date > $1.date }
    }

    func entriesWithDetails(_ entries: [MetricEntry]) -> [MetricEntry] {
        entries.filter { entry in
            entry.details != nil && !entry.details!.isEmpty
        }.sorted { $0.date > $1.date }
    }

    func entriesWithContent(_ entries: [MetricEntry]) -> [MetricEntry] {
        entries.filter(\.hasContent).sorted { $0.date > $1.date }
    }

    func entriesForSelectedMetric(_ entries: [MetricEntry], metric: Metric) -> [MetricEntry] {
        entries.filter { $0.metricID == metric.id }
    }

    func hasMotivationContent(_ entries: [MetricEntry]) -> Bool {
        !entriesWithMotivation(entries).isEmpty
    }

    func hasStarredContent(_ entries: [MetricEntry]) -> Bool {
        !starredEntries(entries).isEmpty
    }

    func hasAnyContent(_ entries: [MetricEntry]) -> Bool {
        !entriesWithContent(entries).isEmpty
    }

    func viceMetrics(_ metrics: [Metric]) -> [Metric] {
        metrics.filter { $0.habitType == .vice }
    }

    func motivationEntries(_ entries: [MetricEntry], for metric: Metric) -> [MetricEntry] {
        entries.filter { entry in
            entry.metricID == metric.id
                && !(entry.motivation?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        }
    }

    // MARK: - Actions

    func presentEditWhy(for metric: Metric) {
        motivationSheet = .editWhy(metric)
    }

    func presentAddNote(for metric: Metric) {
        motivationSheet = .addNote(metric)
    }

    func showAddMetric() {
        showingAddMetric = true
    }

    func addMotivation(
        to entry: MetricEntry,
        motivation: String,
        in modelContext: ModelContext
    ) {
        entry.motivation = motivation
        modelContext.saveChanges(operation: "add motivation note", entity: "MetricEntry")
    }

    func updateMotivation(
        for entry: MetricEntry,
        motivation: String,
        in modelContext: ModelContext
    ) {
        entry.motivation = motivation
        modelContext.saveChanges(operation: "update motivation note", entity: "MetricEntry")
    }

    func removeMotivation(
        from entry: MetricEntry,
        in modelContext: ModelContext
    ) {
        entry.motivation = nil
        modelContext.saveChanges(operation: "remove motivation note", entity: "MetricEntry")
    }

    func toggleStarred(
        for entry: MetricEntry,
        in modelContext: ModelContext
    ) {
        entry.starred = !entry.safeStarred
        modelContext.saveChanges(operation: "toggle starred motivation", entity: "MetricEntry")
    }

    func saveMotivationToMetric(
        motivation: String,
        for metric: Metric,
        in modelContext: ModelContext,
        entries: [MetricEntry]
    ) {
        MetricEntry.insertMotivationNote(
            for: metric.id,
            motivation: motivation,
            in: modelContext
        )
        modelContext.saveChanges(operation: "save motivation note", entity: "MetricEntry")
    }

    func reset() {
        selectedFilter = .all
        motivationSheet = nil
        showingAddMetric = false
    }
}
