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
        let count = metrics.filter { $0.habitType == .positive }.count
        logger.debug("Total habits calculated: \(count)", category: .business)
        return count
    }
    
    /// Total number of vices
    func totalVices(from metrics: [Metric]) -> Int {
        let count = metrics.filter { $0.habitType == .vice }.count
        logger.debug("Total vices calculated: \(count)", category: .business)
        return count
    }
    
    /// Number of metrics with active streaks (1+ days)
    func activeStreaks(from metrics: [Metric], entries: [MetricEntry]) -> Int {
        let startTime = Date()
        let count = metrics.compactMap { metric in
            let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: selectedDate)
            return streak > 0 ? streak : nil
        }.count
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Active streaks calculation", duration: duration)
        logger.debug("Active streaks calculated: \(count)", category: .business)
        return count
    }
    
    /// Number of metrics completed today
    func todayCompleted(from metrics: [Metric], entries: [MetricEntry]) -> Int {
        let startTime = Date()
        let today = Calendar.current.startOfDay(for: selectedDate)
        let count = metrics.filter { metric in
            let todayEntry = entries.first { entry in
                entry.metricID == metric.id &&
                Calendar.current.isDate(entry.date, inSameDayAs: today)
            }
            return TrackingSemantics.countsTowardTodayCompleted(
                habitType: metric.habitType,
                entry: todayEntry
            )
        }.count
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Today completed calculation", duration: duration)
        logger.debug("Today completed calculated: \(count)", category: .business)
        return count
    }
    
    /// Whether user can navigate to previous day
    var canGoBack: Bool {
        let calendar = Calendar.current
        let daysBack = calendar.dateComponents([.day], from: selectedDate, to: Date()).day ?? 0
        return daysBack < 30 // Allow going back up to 30 days
    }
    
    /// Whether user can navigate to next day
    var canGoForward: Bool {
        return !isToday
    }
    
    /// Whether selected date is today
    var isToday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: Date())
    }
    
    // MARK: - Actions
    /// Navigate to previous day
    func goToPreviousDay() {
        if canGoBack {
            let oldDate = selectedDate
            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            logger.logUserAction("Navigate to previous day", details: "From \(DateFormatter.dateFormatter.string(from: oldDate)) to \(DateFormatter.dateFormatter.string(from: selectedDate))")
        } else {
            logger.debug("Cannot go to previous day - already at earliest date", category: .ui)
        }
    }
    
    /// Navigate to next day or today
    func goToNextDay() {
        if !isToday {
            let oldDate = selectedDate
            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            logger.logUserAction("Navigate to next day", details: "From \(DateFormatter.dateFormatter.string(from: oldDate)) to \(DateFormatter.dateFormatter.string(from: selectedDate))")
        } else {
            logger.debug("Cannot go to next day - already at today", category: .ui)
        }
    }
    
    /// Go to today's date
    func goToToday() {
        let oldDate = selectedDate
        selectedDate = Date()
        logger.logUserAction("Navigate to today", details: "From \(DateFormatter.dateFormatter.string(from: oldDate)) to \(DateFormatter.dateFormatter.string(from: selectedDate))")
    }
    
    /// Show add metric sheet
    func showAddMetric() {
        logger.logUserAction("Show add metric sheet")
        showingAddMetric = true
    }
    
    /// Show settings sheet
    func showSettings() {
        logger.logUserAction("Show settings sheet")
        showingSettings = true
    }
    
    /// Show delete confirmation for metric
    func showDeleteConfirmation(for metric: Metric) {
        logger.logUserAction("Show delete confirmation", details: "Metric: \(metric.name)")
        metricToDelete = metric
        showingDeleteConfirmation = true
    }
    
    /// Show edit sheet for metric
    func showEditMetric(_ metric: Metric) {
        logger.logUserAction("Show edit metric sheet", details: "Metric: \(metric.name)")
        metricToEdit = metric
    }
    
    /// Delete metric and all associated entries
    func deleteMetric(in modelContext: ModelContext, entries: [MetricEntry]) {
        guard let metric = metricToDelete else { 
            logger.warn("Attempted to delete metric but metricToDelete is nil", category: .data)
            return 
        }

        logger.logUserAction("Delete metric", details: "Metric: \(metric.name)")
        let startTime = Date()
        
        withAnimation {
            let entryStore = EntryStore(context: modelContext)
            do {
                try entryStore.deleteEntries(for: metric.id)
            } catch {
                logger.logError(error, context: "Failed to delete entries for metric: \(metric.name)")
            }

            modelContext.delete(metric)
            MetricCostStore.remove(for: metric.id)
            MetricDisplayPreferences.remove(for: metric.id)

            if modelContext.saveChanges(operation: "delete metric \(metric.name)", entity: "Metric") {
                let duration = Date().timeIntervalSince(startTime)
                logger.logPerformance("Metric deletion", duration: duration)
                logger.logDataOperation("DELETE", entity: "Metric", success: true)
                WidgetSyncCoordinator.syncIfEnabled(context: modelContext)
            } else {
                logger.logDataOperation("DELETE", entity: "Metric", success: false)
            }
        }
        
        // Reset state
        metricToDelete = nil
        showingDeleteConfirmation = false
    }
    
    /// Toggle metric completion for selected date
    func toggleMetricCompletion(_ metric: Metric, in modelContext: ModelContext, entries: [MetricEntry]) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)

        logger.logUserAction(
            "Toggle metric completion",
            details: "Metric: \(metric.name), Date: \(DateFormatter.dateFormatter.string(from: selectedDate))"
        )
        let startTime = Date()

        let existingEntry = MetricEntry.find(for: metric.id, date: startOfDay, in: entries)
        let newValue = TrackingSemantics.valueAfterQuickToggle(
            habitType: metric.habitType,
            existingEntry: existingEntry
        )

        let entry: MetricEntry
        if let existingEntry {
            entry = existingEntry
        } else {
            entry = MetricEntry(metricID: metric.id, date: startOfDay, value: newValue, hasBeenLogged: false)
            modelContext.insert(entry)
        }

        entry.value = newValue
        MetricEntry.markLogged(entry: entry, metric: metric)

        if modelContext.saveChanges(operation: "toggle metric \(metric.name)", entity: "MetricEntry") {
            let duration = Date().timeIntervalSince(startTime)
            logger.logPerformance("Metric toggle save", duration: duration)
            logger.logDataOperation("UPDATE", entity: "MetricEntry", success: true)
            WidgetSyncCoordinator.onHabitLogged(metric: metric, entry: entry, context: modelContext)
        } else {
            logger.logDataOperation("UPDATE", entity: "MetricEntry", success: false)
        }
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
            entries: entries,
            metric: metric
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
        
        modelContext.saveChanges(operation: "update metric entry \(metric.name)", entity: "MetricEntry")
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
