import Foundation
import SwiftData
import SwiftUI

// MARK: - MotivationViewModel
/// ViewModel for MotivationView containing motivation content logic
@Observable
class MotivationViewModel {
    
    // MARK: - Properties
    var selectedMetric: Metric?
    var showingAddMotivation = false
    var showingAddMetric = false
    
    // MARK: - Computed Properties
    /// Entries with motivation content
    func entriesWithMotivation(_ entries: [MetricEntry]) -> [MetricEntry] {
        let startTime = Date()
        let result = entries.filter { entry in
            entry.motivation != nil && !entry.motivation!.isEmpty
        }.sorted { $0.date > $1.date }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Motivation entries filtering", duration: duration)
        logger.debug("Motivation entries filtered - Result: \(result.count) out of \(entries.count)", category: .business)
        
        return result
    }
    
    /// Entries with starred content
    func starredEntries(_ entries: [MetricEntry]) -> [MetricEntry] {
        entries.filter { entry in
            entry.safeStarred
        }.sorted { $0.date > $1.date }
    }
    
    /// Entries with details content
    func entriesWithDetails(_ entries: [MetricEntry]) -> [MetricEntry] {
        entries.filter { entry in
            entry.details != nil && !entry.details!.isEmpty
        }.sorted { $0.date > $1.date }
    }
    
    /// All entries with meaningful content (motivation, details, or starred)
    func entriesWithContent(_ entries: [MetricEntry]) -> [MetricEntry] {
        entries.filter { entry in
            entry.hasContent
        }.sorted { $0.date > $1.date }
    }
    
    /// Entries for selected metric
    func entriesForSelectedMetric(_ entries: [MetricEntry]) -> [MetricEntry] {
        guard let selectedMetric = selectedMetric else { return [] }
        return entries.filter { $0.metricID == selectedMetric.id }
    }
    
    /// Check if there's motivation content to display
    func hasMotivationContent(_ entries: [MetricEntry]) -> Bool {
        !entriesWithMotivation(entries).isEmpty
    }
    
    /// Check if there are starred entries
    func hasStarredContent(_ entries: [MetricEntry]) -> Bool {
        !starredEntries(entries).isEmpty
    }
    
    /// Check if there's any content to display
    func hasAnyContent(_ entries: [MetricEntry]) -> Bool {
        !entriesWithContent(entries).isEmpty
    }
    
    // MARK: - Actions
    /// Select a metric for motivation view
    func selectMetric(_ metric: Metric?) {
        logger.logUserAction("Motivation metric selected", details: "Metric: \(metric?.name ?? "None")")
        selectedMetric = metric
    }
    
    /// Show add motivation sheet
    func showAddMotivation() {
        logger.logUserAction("Show add motivation")
        showingAddMotivation = true
    }
    
    /// Show add metric sheet
    func showAddMetric() {
        logger.logUserAction("Show add metric")
        showingAddMetric = true
    }
    
    /// Add motivation to an entry
    func addMotivation(
        to entry: MetricEntry,
        motivation: String,
        in modelContext: ModelContext
    ) {
        entry.motivation = motivation
        try? modelContext.save()
    }
    
    /// Update motivation for an entry
    func updateMotivation(
        for entry: MetricEntry,
        motivation: String,
        in modelContext: ModelContext
    ) {
        entry.motivation = motivation
        try? modelContext.save()
    }
    
    /// Remove motivation from an entry
    func removeMotivation(
        from entry: MetricEntry,
        in modelContext: ModelContext
    ) {
        entry.motivation = nil
        try? modelContext.save()
    }
    
    /// Toggle starred status for an entry
    func toggleStarred(
        for entry: MetricEntry,
        in modelContext: ModelContext
    ) {
        entry.starred = !entry.safeStarred
        try? modelContext.save()
    }
    
    /// Save motivation to a metric
    func saveMotivationToMetric(
        motivation: String,
        for metric: Metric,
        in modelContext: ModelContext,
        entries: [MetricEntry]
    ) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let entry = MetricEntry.getOrCreate(
            for: metric.id,
            date: today,
            in: modelContext,
            entries: entries
        )
        
        entry.motivation = motivation
        try? modelContext.save()
    }
    
    /// Reset all state
    func reset() {
        selectedMetric = nil
        showingAddMotivation = false
        showingAddMetric = false
    }
}
