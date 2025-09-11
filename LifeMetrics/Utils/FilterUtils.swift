import Foundation

// MARK: - Filter Utilities
struct FilterUtils {
    
    /// Check if a MetricEntry matches the given MetricFilter
    static func matchesFilter(_ filter: MetricFilter, entry: MetricEntry, metrics: [Metric]) -> Bool {
        switch filter {
        case .all:
            return true
        case .allHabits:
            return metrics.first { $0.id == entry.metricID }?.safeHabitType == .positive
        case .allVices:
            return metrics.first { $0.id == entry.metricID }?.safeHabitType == .vice
        case .specific(let metric):
            return entry.metricID == metric.id
        }
    }
    
    /// Get filtered entries based on the given filter
    static func filteredEntries(_ filter: MetricFilter, entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        return entries.filter { entry in
            matchesFilter(filter, entry: entry, metrics: metrics)
        }
    }
    
    /// Get filtered entries with a specific value (true/false)
    static func filteredEntries(_ filter: MetricFilter, entries: [MetricEntry], metrics: [Metric], value: Bool) -> [MetricEntry] {
        return entries.filter { entry in
            matchesFilter(filter, entry: entry, metrics: metrics) && entry.value == value
        }
    }
}
