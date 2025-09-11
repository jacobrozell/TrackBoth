import Foundation
import SwiftData
import SwiftUI

// MARK: - ChartsViewModel
/// ViewModel for ChartsView containing chart logic and data processing
@Observable
class ChartsViewModel {
    
    // MARK: - Properties
    var selectedFilter: MetricFilter = .all
    var selectedChartType: ChartType = .line
    var showingAddMetric = false
    var showingSettings = false
    
    // MARK: - Computed Properties
    /// Filtered metrics based on selected filter
    func filteredMetrics(_ metrics: [Metric]) -> [Metric] {
        switch selectedFilter {
        case .all:
            return metrics
        case .allHabits:
            return metrics.filter { $0.safeHabitType == .positive }
        case .allVices:
            return metrics.filter { $0.safeHabitType == .vice }
        case .specific(let metric):
            return [metric]
        }
    }
    
    /// Filtered entries based on selected filter
    func filteredEntries(_ entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        entries.filter { entry in
            FilterUtils.matchesFilter(selectedFilter, entry: entry, metrics: metrics)
        }
    }
    
    /// Check if there's data to display charts
    func hasDataToDisplay(_ metrics: [Metric], entries: [MetricEntry]) -> Bool {
        !metrics.isEmpty && !filteredEntries(entries, metrics: metrics).isEmpty
    }
    
    // MARK: - Actions
    /// Update selected filter
    func updateFilter(_ filter: MetricFilter) {
        selectedFilter = filter
    }
    
    /// Update selected chart type
    func updateChartType(_ chartType: ChartType) {
        selectedChartType = chartType
    }
    
    /// Show add metric sheet
    func showAddMetric() {
        showingAddMetric = true
    }
    
    /// Show settings sheet
    func showSettings() {
        showingSettings = true
    }
    
    /// Reset all state
    func reset() {
        selectedFilter = .all
        selectedChartType = .line
        showingAddMetric = false
        showingSettings = false
    }
}
