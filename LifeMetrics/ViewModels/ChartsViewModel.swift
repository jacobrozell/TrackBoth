import Foundation
import SwiftData

// MARK: - ChartsViewModel
/// ViewModel for ChartsView containing chart logic and data processing
@Observable
class ChartsViewModel {
    
    // MARK: - Properties
    var selectedFilter: MetricFilter = .all
    var selectedChartType: ChartType = .line
    var showingAddMetric = false
    
    // MARK: - Computed Properties
    /// Filtered metrics based on selected filter
    func filteredMetrics(_ metrics: [Metric]) -> [Metric] {
        FilterUtils.filteredMetrics(selectedFilter, in: metrics)
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
        logger.logUserAction("Chart filter updated", details: "From \(selectedFilter) to \(filter)")
        selectedFilter = filter
    }
    
    /// Update selected chart type
    func updateChartType(_ chartType: ChartType) {
        logger.logUserAction("Chart type updated", details: "From \(selectedChartType) to \(chartType)")
        selectedChartType = chartType
    }
    
    /// Show add metric sheet
    func showAddMetric() {
        showingAddMetric = true
    }
    
    /// Reset all state
    func reset() {
        selectedFilter = .all
        selectedChartType = .line
        showingAddMetric = false
    }
}
