import Foundation
import SwiftData

// MARK: - MotivationViewModel
/// ViewModel for MotivationView containing motivation content logic
@Observable
class MotivationViewModel {

    // MARK: - Properties
    var selectedFilter: MetricFilter = .all
    var selectedMetric: Metric?
    var showingAddMotivation = false
    var showingAddMetric = false

    // MARK: - Display Data

    func primaryMotivations(_ metrics: [Metric]) -> [Metric] {
        FilterUtils.filteredMetrics(selectedFilter, in: metrics).filter { metric in
            metric.primaryMotivation != nil && !metric.primaryMotivation!.isEmpty
        }
    }

    func dailyMotivations(_ entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        let motivationEntries = entries.filter { entry in
            entry.motivation != nil && !entry.motivation!.isEmpty
        }
        return FilterUtils.filteredEntries(selectedFilter, entries: motivationEntries, metrics: metrics)
            .sorted { $0.date > $1.date }
    }

    func hasAnyMotivations(_ metrics: [Metric], entries: [MetricEntry]) -> Bool {
        let hasPrimary = metrics.contains { $0.primaryMotivation != nil && !$0.primaryMotivation!.isEmpty }
        let hasDaily = entries.contains { $0.motivation != nil && !$0.motivation!.isEmpty }
        return hasPrimary || hasDaily
    }

    func entriesWithMotivation(_ entries: [MetricEntry]) -> [MetricEntry] {
        entries.filter { entry in
            entry.motivation != nil && !entry.motivation!.isEmpty
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

    func entriesForSelectedMetric(_ entries: [MetricEntry]) -> [MetricEntry] {
        guard let selectedMetric else { return [] }
        return entries.filter { $0.metricID == selectedMetric.id }
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

    func motivationEntries(_ entries: [MetricEntry]) -> [MetricEntry] {
        let filteredEntries = entries.filter { entry in
            entry.motivation != nil && !entry.motivation!.isEmpty
        }

        if let selectedMetric {
            return filteredEntries.filter { $0.metricID == selectedMetric.id }
        }
        return filteredEntries
    }

    // MARK: - Actions

    func selectMetric(_ metric: Metric?) {
        selectedMetric = metric
    }

    func showAddMotivation() {
        showingAddMotivation = true
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
        modelContext.saveChanges(operation: "add motivation", entity: "MetricEntry")
    }

    func updateMotivation(
        for entry: MetricEntry,
        motivation: String,
        in modelContext: ModelContext
    ) {
        entry.motivation = motivation
        modelContext.saveChanges(operation: "update motivation", entity: "MetricEntry")
    }

    func removeMotivation(
        from entry: MetricEntry,
        in modelContext: ModelContext
    ) {
        entry.motivation = nil
        modelContext.saveChanges(operation: "remove motivation", entity: "MetricEntry")
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
        let today = Calendar.current.startOfDay(for: Date())
        let entry = MetricEntry.getOrCreate(
            for: metric.id,
            date: today,
            in: modelContext,
            entries: entries,
            metric: metric
        )
        entry.motivation = motivation
        modelContext.saveChanges(operation: "save motivation to metric", entity: "MetricEntry")
    }

    func reset() {
        selectedFilter = .all
        selectedMetric = nil
        showingAddMotivation = false
        showingAddMetric = false
    }
}
