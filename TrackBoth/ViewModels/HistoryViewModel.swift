import Foundation
import SwiftData

// MARK: - HistoryViewModel
/// ViewModel for HistoryView containing history filtering and display logic
@Observable
class HistoryViewModel {

    // MARK: - Properties
    var selectedFilter: MetricFilter = .all
    var selectedDate = Date()
    var searchText = ""
    var showingAddMetric = false
    var entryTypeFilter: EntryTypeFilter = .all

    // MARK: - Display Data

    /// Metrics visible for the current filter chip selection.
    func filteredMetrics(_ metrics: [Metric]) -> [Metric] {
        var filtered = FilterUtils.filteredMetrics(selectedFilter, in: metrics)

        if !searchText.isEmpty {
            filtered = filtered.filter { metric in
                metric.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered
    }

    /// Entries for the selected calendar day, sorted by metric name.
    func dayEntries(_ entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        entriesForSelectedDate(entries, metrics: metrics)
            .sorted { lhs, rhs in
                let lhsName = metrics.first { $0.id == lhs.metricID }?.name ?? ""
                let rhsName = metrics.first { $0.id == rhs.metricID }?.name ?? ""
                if lhsName != rhsName { return lhsName < rhsName }
                return lhs.date > rhs.date
            }
    }

    func selectedDaySectionTitle() -> String {
        if CalendarHelper.isToday(selectedDate) {
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: selectedDate)
    }

    /// Entries for the selected month, filter, and optional search text.
    func recentEntries(_ entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let endOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.end ?? selectedDate

        var filtered = entries.filter { entry in
            entry.date >= startOfMonth && entry.date < endOfMonth
        }
        filtered = FilterUtils.filteredEntries(selectedFilter, entries: filtered, metrics: metrics)

        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            filtered = filtered.filter { entry in
                let details = entry.details?.lowercased() ?? ""
                let motivation = entry.motivation?.lowercased() ?? ""
                return details.contains(searchLower) || motivation.contains(searchLower)
            }
        }

        return filtered.sorted { $0.date > $1.date }
    }

    /// Calendar heatmap data for the selected month and filter.
    func calendarEntries(_ entries: [MetricEntry], metrics: [Metric]) -> [Date: [MetricEntry]] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let endOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.end ?? selectedDate

        var filtered = entries.filter { entry in
            entry.date >= startOfMonth && entry.date < endOfMonth
        }
        filtered = FilterUtils.filteredEntries(selectedFilter, entries: filtered, metrics: metrics)

        return Dictionary(grouping: filtered) { entry in
            calendar.startOfDay(for: entry.date)
        }
    }

    func hasAnyEntries(_ entries: [MetricEntry]) -> Bool {
        !entries.isEmpty
    }

    /// Filtered entries based on selected filter (all dates).
    func filteredEntries(_ entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        entries.filter { entry in
            FilterUtils.matchesFilter(selectedFilter, entry: entry, metrics: metrics)
        }
    }

    /// Entries for selected date.
    func entriesForSelectedDate(_ entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)

        return filteredEntries(entries, metrics: metrics).filter { entry in
            calendar.isDate(entry.date, inSameDayAs: startOfDay)
        }
    }

    func hasEntriesForSelectedDate(_ entries: [MetricEntry], metrics: [Metric]) -> Bool {
        !entriesForSelectedDate(entries, metrics: metrics).isEmpty
    }

    func entriesGroupedByMonth(_ entries: [MetricEntry], metrics: [Metric]) -> [String: [MetricEntry]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        return Dictionary(grouping: filteredEntries(entries, metrics: metrics)) { entry in
            formatter.string(from: entry.date)
        }
    }

    // MARK: - Actions

    func showAddMetric() {
        showingAddMetric = true
    }

    func updateFilter(_ filter: MetricFilter) {
        selectedFilter = filter
    }

    func updateSelectedDate(_ date: Date) {
        selectedDate = date
    }

    func updateSearchText(_ text: String) {
        searchText = text
    }

    func updateEntryTypeFilter(_ filter: EntryTypeFilter) {
        entryTypeFilter = filter
    }

    func goToPreviousMonth() {
        let calendar = Calendar.current
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }

    func goToNextMonth() {
        let calendar = Calendar.current
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }

    func goToCurrentMonth() {
        selectedDate = Date()
    }

    func reset() {
        selectedFilter = .all
        selectedDate = Date()
        searchText = ""
        showingAddMetric = false
        entryTypeFilter = .all
    }
}
