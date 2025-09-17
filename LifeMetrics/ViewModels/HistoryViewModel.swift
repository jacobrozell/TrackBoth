import Foundation
import SwiftData
import SwiftUI

// MARK: - HistoryViewModel
/// ViewModel for HistoryView containing history filtering and display logic
@Observable
class HistoryViewModel {
    
    // MARK: - Properties
    var selectedFilter: MetricFilter = .all
    var selectedDate = Date()
    var searchText = ""
    var showingAddMetric = false
    var showingSettings = false
    var entryTypeFilter: EntryTypeFilter = .all
    
    // MARK: - Computed Properties
    /// Filtered metrics based on selected filter and search text
    func filteredMetrics(_ metrics: [Metric]) -> [Metric] {
        let startTime = Date()
        var filtered = metrics
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .allHabits:
            filtered = filtered.filter { $0.habitType == .positive }
        case .allVices:
            filtered = filtered.filter { $0.habitType == .vice }
        case .specific(let metric):
            filtered = [metric]
        }
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter { metric in
                metric.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("History metrics filtering", duration: duration)
        logger.debug("History metrics filtered - Filter: \(selectedFilter), Search: '\(searchText)', Result: \(filtered.count) out of \(metrics.count)", category: .business)
        
        return filtered
    }
    
    /// Filtered entries based on selected filter
    func filteredEntries(_ entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        entries.filter { entry in
            FilterUtils.matchesFilter(selectedFilter, entry: entry, metrics: metrics)
        }
    }
    
    /// Entries for selected date
    func entriesForSelectedDate(_ entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        return filteredEntries(entries, metrics: metrics).filter { entry in
            calendar.isDate(entry.date, inSameDayAs: startOfDay)
        }
    }
    
    /// Check if there are entries for selected date
    func hasEntriesForSelectedDate(_ entries: [MetricEntry], metrics: [Metric]) -> Bool {
        !entriesForSelectedDate(entries, metrics: metrics).isEmpty
    }
    
    /// Get entries grouped by month for calendar view
    func entriesGroupedByMonth(_ entries: [MetricEntry], metrics: [Metric]) -> [String: [MetricEntry]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        return Dictionary(grouping: filteredEntries(entries, metrics: metrics)) { entry in
            formatter.string(from: entry.date)
        }
    }
    
    /// Calendar entries grouped by date with all filters applied
    func calendarEntries(_ entries: [MetricEntry], metrics: [Metric]) -> [Date: [MetricEntry]] {
        let startTime = Date()
        let filteredEntries = entries.filter { entry in
            // Only show entries that have meaningful content
            guard entry.hasContent else { return false }
            
            // Apply search filter
            if !searchText.isEmpty {
                guard entry.details?.localizedCaseInsensitiveContains(searchText) == true else {
                    return false
                }
            }
            
            // Apply entry type filter
            switch entryTypeFilter {
            case .all:
                break
            case .boolean:
                guard !entry.hasQuantity else { return false }
            case .quantity:
                guard entry.hasQuantity else { return false }
            }
            
            // Apply metric filter
            switch selectedFilter {
            case .all:
                return true
            case .allHabits:
                return metrics.first { $0.id == entry.metricID }?.habitType == .positive
            case .allVices:
                return metrics.first { $0.id == entry.metricID }?.habitType == .vice
            case .specific(let metric):
                return entry.metricID == metric.id
            }
        }
        
        let result = Dictionary(grouping: filteredEntries) { entry in
            CalendarHelper.startOfDay(for: entry.date)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Calendar entries calculation", duration: duration)
        logger.debug("Calendar entries calculated - Filtered: \(filteredEntries.count), Grouped: \(result.count) days", category: .performance)
        
        return result
    }
    
    // MARK: - Actions
    /// Update selected filter
    func updateFilter(_ filter: MetricFilter) {
        logger.logUserAction("History filter updated", details: "From \(selectedFilter) to \(filter)")
        selectedFilter = filter
    }
    
    /// Update selected date
    func updateSelectedDate(_ date: Date) {
        logger.logUserAction("History date updated", details: "From \(DateFormatter.dateFormatter.string(from: selectedDate)) to \(DateFormatter.dateFormatter.string(from: date))")
        selectedDate = date
    }
    
    /// Update search text
    func updateSearchText(_ text: String) {
        logger.logUserAction("History search updated", details: "From '\(searchText)' to '\(text)'")
        searchText = text
    }
    
    /// Show add metric sheet
    func showAddMetric() {
        showingAddMetric = true
    }
    
    /// Show settings sheet
    func showSettings() {
        showingSettings = true
    }
    
    /// Update entry type filter
    func updateEntryTypeFilter(_ filter: EntryTypeFilter) {
        logger.logUserAction("History entry type filter updated", details: "From \(entryTypeFilter) to \(filter)")
        entryTypeFilter = filter
    }
    
    /// Navigate to previous month
    func goToPreviousMonth() {
        let calendar = Calendar.current
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    /// Navigate to next month
    func goToNextMonth() {
        let calendar = Calendar.current
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
    
    /// Go to current month
    func goToCurrentMonth() {
        selectedDate = Date()
    }
    
    /// Reset all state
    func reset() {
        selectedFilter = .all
        selectedDate = Date()
        searchText = ""
        showingAddMetric = false
        showingSettings = false
        entryTypeFilter = .all
    }
}
