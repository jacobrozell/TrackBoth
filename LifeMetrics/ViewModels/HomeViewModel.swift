import Foundation
import SwiftData
import SwiftUI

// MARK: - HomeViewModel
/// ViewModel for HomeView containing all business logic and state management
@Observable
class HomeViewModel {
    
    // MARK: - Properties
    var showingAddMetric = false
    var showingSettings = false
    var metricToDelete: Metric?
    var showingDeleteConfirmation = false
    var metricToEdit: Metric?
    var selectedDate = Date()
    var showingDatePicker = false
    
    // MARK: - Computed Properties
    /// Total number of positive habits
    func totalHabits(from metrics: [Metric]) -> Int {
        metrics.filter { $0.safeHabitType == .positive }.count
    }
    
    /// Total number of vices
    func totalVices(from metrics: [Metric]) -> Int {
        metrics.filter { $0.safeHabitType == .vice }.count
    }
    
    /// Number of metrics with active streaks (1+ days)
    func activeStreaks(from metrics: [Metric], entries: [MetricEntry]) -> Int {
        metrics.compactMap { metric in
            let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: selectedDate)
            return streak > 0 ? streak : nil
        }.count
    }
    
    /// Number of metrics completed today
    func todayCompleted(from metrics: [Metric], entries: [MetricEntry]) -> Int {
        let today = Calendar.current.startOfDay(for: selectedDate)
        return metrics.filter { metric in
            let isVice = metric.safeHabitType == .vice
            let todayEntry = entries.first { entry in
                entry.metricID == metric.id && 
                Calendar.current.isDate(entry.date, inSameDayAs: today)
            }
            return todayEntry?.value == !isVice
        }.count
    }
    
    /// Whether user can navigate to previous day
    var canGoBack: Bool {
        let calendar = Calendar.current
        let daysBack = calendar.dateComponents([.day], from: selectedDate, to: Date()).day ?? 0
        return daysBack < 7 // Allow going back up to 7 days
    }
    
    /// Whether selected date is today
    var isToday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: Date())
    }
    
    // MARK: - Actions
    /// Navigate to previous day
    func goToPreviousDay() {
        if canGoBack {
            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    /// Navigate to next day or today
    func goToNextDay() {
        if !isToday {
            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        }
    }
    
    /// Go to today's date
    func goToToday() {
        selectedDate = Date()
    }
    
    /// Show add metric sheet
    func showAddMetric() {
        showingAddMetric = true
    }
    
    /// Show settings sheet
    func showSettings() {
        showingSettings = true
    }
    
    /// Show delete confirmation for metric
    func showDeleteConfirmation(for metric: Metric) {
        metricToDelete = metric
        showingDeleteConfirmation = true
    }
    
    /// Show edit sheet for metric
    func showEditMetric(_ metric: Metric) {
        metricToEdit = metric
    }
    
    /// Delete metric and all associated entries
    func deleteMetric(in modelContext: ModelContext, entries: [MetricEntry]) {
        guard let metric = metricToDelete else { return }

        withAnimation {
            // Delete all associated entries first
            let entriesToDelete = entries.filter { $0.metricID == metric.id }
            for entry in entriesToDelete {
                modelContext.delete(entry)
            }
            
            // Delete the metric
            modelContext.delete(metric)
            
            // Save changes
            try? modelContext.save()
        }
        
        // Reset state
        metricToDelete = nil
        showingDeleteConfirmation = false
    }
    
    /// Toggle metric completion for selected date
    func toggleMetricCompletion(_ metric: Metric, in modelContext: ModelContext, entries: [MetricEntry]) {
        let isVice = metric.safeHabitType == .vice
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        // Look for existing entry for this metric and date
        if let existingEntry = entries.first(where: { 
            $0.metricID == metric.id && calendar.isDate($0.date, inSameDayAs: startOfDay) 
        }) {
            // Toggle existing entry
            existingEntry.value.toggle()
        } else {
            // Create new entry
            let newEntry = MetricEntry(
                metricID: metric.id,
                date: startOfDay,
                value: !isVice // Default to completed for positive habits, not completed for vices
            )
            modelContext.insert(newEntry)
        }
        
        try? modelContext.save()
    }
    
    /// Update metric entry with details and motivation
    func updateMetricEntry(
        for metric: Metric,
        details: String?,
        motivation: String?,
        starred: Bool?,
        in modelContext: ModelContext,
        entries: [MetricEntry]
    ) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        let entry = MetricEntry.getOrCreate(
            for: metric.id,
            date: startOfDay,
            in: modelContext,
            entries: entries
        )
        
        if let details = details {
            entry.details = details
        }
        if let motivation = motivation {
            entry.motivation = motivation
        }
        if let starred = starred {
            entry.starred = starred
        }
        
        try? modelContext.save()
    }
    
    /// Reset all state
    func reset() {
        showingAddMetric = false
        showingSettings = false
        metricToDelete = nil
        showingDeleteConfirmation = false
        metricToEdit = nil
        selectedDate = Date()
        showingDatePicker = false
    }
}
