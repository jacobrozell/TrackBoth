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
    
    // MARK: - Computed Properties
    /// Filtered metrics based on selected filter and search text
    func filteredMetrics(_ metrics: [Metric]) -> [Metric] {
        var filtered = metrics
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .allHabits:
            filtered = filtered.filter { $0.safeHabitType == .positive }
        case .allVices:
            filtered = filtered.filter { $0.safeHabitType == .vice }
        case .specific(let metric):
            filtered = [metric]
        }
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter { metric in
                metric.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
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
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        return Dictionary(grouping: filteredEntries(entries, metrics: metrics)) { entry in
            formatter.string(from: entry.date)
        }
    }
    
    // MARK: - Actions
    /// Update selected filter
    func updateFilter(_ filter: MetricFilter) {
        selectedFilter = filter
    }
    
    /// Update selected date
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
    }
    
    /// Update search text
    func updateSearchText(_ text: String) {
        searchText = text
    }
    
    /// Show add metric sheet
    func showAddMetric() {
        showingAddMetric = true
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
    }
}
