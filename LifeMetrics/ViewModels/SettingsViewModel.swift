import Foundation
import SwiftData
import SwiftUI

// MARK: - SettingsViewModel
/// ViewModel for SettingsView containing settings and export logic
@Observable
class SettingsViewModel {
    
    // MARK: - Properties
    var showingExportSheet = false
    
    // MARK: - Computed Properties
    /// Total number of metrics
    func totalMetrics(_ metrics: [Metric]) -> Int {
        let count = metrics.count
        logger.debug("Total metrics calculated: \(count)", category: .business)
        return count
    }
    
    /// Total number of entries
    func totalEntries(_ entries: [MetricEntry]) -> Int {
        let count = entries.count
        logger.debug("Total entries calculated: \(count)", category: .business)
        return count
    }
    
    /// Number of positive habits
    func positiveHabits(_ metrics: [Metric]) -> Int {
        metrics.filter { $0.habitType == .positive }.count
    }
    
    /// Number of vices
    func vices(_ metrics: [Metric]) -> Int {
        metrics.filter { $0.habitType == .vice }.count
    }
    
    /// Number of metrics with goals
    func metricsWithGoals(_ metrics: [Metric]) -> Int {
        metrics.filter { metric in
            ((metric.goals?.isEmpty) == nil)
        }.count
    }
    
    /// Number of entries with motivation
    func entriesWithMotivation(_ entries: [MetricEntry]) -> Int {
        entries.filter { entry in
            entry.motivation != nil && !entry.motivation!.isEmpty
        }.count
    }
    
    /// Number of starred entries
    func starredEntries(_ entries: [MetricEntry]) -> Int {
        entries.filter { $0.safeStarred }.count
    }
    
    /// App statistics summary
    func appStatistics(_ metrics: [Metric], entries: [MetricEntry]) -> String {
        let totalMetrics = totalMetrics(metrics)
        let totalEntries = totalEntries(entries)
        let positiveHabits = positiveHabits(metrics)
        let vices = vices(metrics)
        let withGoals = metricsWithGoals(metrics)
        let withMotivation = entriesWithMotivation(entries)
        let starred = starredEntries(entries)
        
        return """
        Total Metrics: \(totalMetrics)
        Total Entries: \(totalEntries)
        Positive Habits: \(positiveHabits)
        Vices: \(vices)
        Metrics with Goals: \(withGoals)
        Entries with Motivation: \(withMotivation)
        Starred Entries: \(starred)
        """
    }
    
    // MARK: - Actions
    /// Show export sheet
    func showExportSheet() {
        showingExportSheet = true
    }
    
    /// Export all data as CSV
    func exportDataAsCSV(_ metrics: [Metric], entries: [MetricEntry]) -> String {
        logger.info("Starting CSV export - Metrics: \(metrics.count), Entries: \(entries.count)", category: .ui)
        let startTime = Date()
        
        var csvContent = "Metric Name,Habit Type,Date,Value,Motivation,Details,Starred\n"
        
        for entry in entries.sorted(by: { $0.date > $1.date }) {
            let metric = metrics.first { $0.id == entry.metricID }
            let metricName = metric?.name ?? "Unknown"
            let habitType = metric?.habitType.displayName ?? "Unknown"
            let dateString = DateFormatter.dateFormatter.string(from: entry.date)
            let value = entry.value ? "Yes" : "No"
            let motivation = entry.motivation?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
            let details = entry.details?.replacingOccurrences(of: "\"", with: "\"\"") ?? ""
            let starred = entry.safeStarred ? "Yes" : "No"
            
            csvContent += "\"\(metricName)\",\"\(habitType)\",\"\(dateString)\",\"\(value)\",\"\(motivation)\",\"\(details)\",\"\(starred)\"\n"
        }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("CSV export", duration: duration)
        logger.info("CSV export completed - Size: \(csvContent.count) characters", category: .ui)
        
        return csvContent
    }
    
    /// Export metrics data as CSV
    func exportMetricsAsCSV(_ metrics: [Metric]) -> String {
        var csvContent = "Metric Name,Habit Type,Created Date,Goal Period,Goal Target\n"
        
        for metric in metrics.sorted(by: { $0.createdAt > $1.createdAt }) {
            let name = metric.name.replacingOccurrences(of: "\"", with: "\"\"")
            let habitType = metric.habitType.displayName
            let createdDate = DateFormatter.dateFormatter.string(from: metric.createdAt)
            let goalPeriod = metric.booleanGoals.first?.period.displayName ?? "None"
            let goalTarget = metric.booleanGoals.first?.target.description ?? "None"
            
            csvContent += "\"\(name)\",\"\(habitType)\",\"\(createdDate)\",\"\(goalPeriod)\",\"\(goalTarget)\"\n"
        }
        
        return csvContent
    }
    
    /// Clear all data
    func clearAllData(in modelContext: ModelContext, metrics: [Metric], entries: [MetricEntry]) {
        // Delete all entries first
        for entry in entries {
            modelContext.delete(entry)
        }
        
        // Delete all metrics
        for metric in metrics {
            modelContext.delete(metric)
        }
        
        // Save changes
        try? modelContext.save()
    }
    
    /// Reset all state
    func reset() {
        showingExportSheet = false
    }
}
