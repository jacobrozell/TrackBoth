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
    
    // MARK: - Computed Properties
    /// Filtered metrics based on selected filter
    func filteredMetrics(_ metrics: [Metric]) -> [Metric] {
        let startTime = Date()
        let result = FilterUtils.filteredMetrics(selectedFilter, in: metrics)
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Metrics filtering", duration: duration)
        logger.debug("Metrics filtered - Filter: \(selectedFilter), Result: \(result.count) out of \(metrics.count)", category: .business)
        
        return result
    }
    
    /// Filtered entries based on selected filter
    func filteredEntries(_ entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        let startTime = Date()
        let result = entries.filter { entry in
            FilterUtils.matchesFilter(selectedFilter, entry: entry, metrics: metrics)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Entries filtering", duration: duration)
        logger.debug("Entries filtered - Filter: \(selectedFilter), Result: \(result.count) out of \(entries.count)", category: .business)
        
        return result
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
