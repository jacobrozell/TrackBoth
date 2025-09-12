import Foundation
import SwiftData
import WidgetKit

// MARK: - Widget Integration
/// Handles integration between the main app and widgets
class WidgetIntegration: ObservableObject {
    static let shared = WidgetIntegration()
    
    private let widgetDataManager = WidgetDataManager.shared
    
    private init() {}
    
    // MARK: - Data Updates
    
    /// Update widget data when metrics change
    func updateMetrics(_ metrics: [Metric]) {
        logger.info("Updating widget metrics - Count: \(metrics.count)", category: .widget)
        widgetDataManager.saveMetrics(metrics)
        widgetDataManager.updateWidget()
    }
    
    /// Update widget data when entries change
    func updateEntries(_ entries: [MetricEntry]) {
        logger.info("Updating widget entries - Count: \(entries.count)", category: .widget)
        widgetDataManager.saveEntries(entries)
        widgetDataManager.updateWidget()
    }
    
    /// Update widget data when streaks change
    func updateStreaks(_ metrics: [Metric], entries: [MetricEntry]) {
        let streaks = calculateStreaks(metrics: metrics, entries: entries)
        widgetDataManager.saveStreaks(streaks)
        widgetDataManager.updateWidget()
    }
    
    /// Update widget data when goals change
    func updateGoals(_ metrics: [Metric], entries: [MetricEntry]) {
        let goals = calculateGoals(metrics, entries: entries)
        widgetDataManager.saveGoals(goals)
        widgetDataManager.updateWidget()
    }
    
    /// Update all widget data
    func updateAllData(metrics: [Metric], entries: [MetricEntry]) {
        updateMetrics(metrics)
        updateEntries(entries)
        updateStreaks(metrics, entries: entries)
        updateGoals(metrics, entries: entries)
    }
    
    // MARK: - Private Methods
    
    private func calculateStreaks(metrics: [Metric], entries: [MetricEntry]) -> [WidgetStreakData] {
        return metrics.map { metric in
            let metricEntries = entries.filter { $0.metricID == metric.id }
            let currentStreak = calculateCurrentStreak(for: metric, entries: metricEntries)
            let longestStreak = calculateLongestStreak(for: metric, entries: metricEntries)
            
            return WidgetStreakData(
                metricID: metric.id,
                currentStreak: currentStreak,
                longestStreak: longestStreak
            )
        }
    }
    
    private func calculateCurrentStreak(for metric: Metric, entries: [MetricEntry]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        // Sort entries by date descending
        let sortedEntries = entries.sorted { $0.date > $1.date }
        
        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.date)
            
            if calendar.isDate(entryDate, inSameDayAs: currentDate) {
                // Check if this entry counts as a success
                let isSuccess = metric.safeHabitType == .vice ? !entry.value : entry.value
                
                if isSuccess {
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                } else {
                    break
                }
            } else if entryDate < currentDate {
                // Gap in entries, streak is broken
                break
            }
        }
        
        return streak
    }
    
    private func calculateLongestStreak(for metric: Metric, entries: [MetricEntry]) -> Int {
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.date < $1.date }
        
        var maxStreak = 0
        var currentStreak = 0
        var lastSuccessDate: Date?
        
        for entry in sortedEntries {
            let isSuccess = metric.safeHabitType == .vice ? !entry.value : entry.value
            
            if isSuccess {
                if let lastDate = lastSuccessDate {
                    let daysBetween = calendar.dateComponents([.day], from: lastDate, to: entry.date).day ?? 0
                    if daysBetween == 1 {
                        currentStreak += 1
                    } else {
                        maxStreak = max(maxStreak, currentStreak)
                        currentStreak = 1
                    }
                } else {
                    currentStreak = 1
                }
                lastSuccessDate = entry.date
            } else {
                maxStreak = max(maxStreak, currentStreak)
                currentStreak = 0
            }
        }
        
        return max(maxStreak, currentStreak)
    }
    
    private func calculateGoals(_ metrics: [Metric], entries: [MetricEntry]) -> [WidgetGoalData] {
        return metrics.compactMap { metric in
            guard let goalTarget = metric.goalTarget,
                  let goalPeriod = metric.goalPeriod else {
                return nil
            }
            
            // Calculate progress based on current period using actual entry data
            let progress = calculateGoalProgress(for: metric, target: goalTarget, period: goalPeriod, entries: entries)
            
            return WidgetGoalData(
                metricID: metric.id,
                name: metric.name,
                progress: progress,
                target: goalTarget,
                period: goalPeriod
            )
        }
    }
    
    private func calculateGoalProgress(for metric: Metric, target: Int, period: GoalPeriod, entries: [MetricEntry]) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case .monthly:
            startDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .yearly:
            startDate = calendar.dateInterval(of: .year, for: now)?.start ?? now
        case .weekly:
            startDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case .biWeekly:
            // Bi-weekly: 2 weeks from start of current week
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            startDate = calendar.date(byAdding: .weekOfYear, value: -2, to: weekStart) ?? now
        }
        
        // Filter entries for this metric within the goal period
        let periodEntries = entries.filter { entry in
            entry.metricID == metric.id &&
            entry.date >= startDate &&
            entry.date <= now
        }
        
        // Count successful entries based on habit type
        let successfulEntries = periodEntries.filter { entry in
            let isVice = metric.safeHabitType == .vice
            // For positive habits: count when value == true (completed)
            // For vices: count when value == false (avoided)
            return isVice ? !entry.value : entry.value
        }
        
        let currentCount = successfulEntries.count
        let progress = target > 0 ? Double(currentCount) / Double(target) : 0.0
        return min(progress, 1.0) // Cap at 100%
    }
}

// MARK: - Widget Data Extensions
extension Metric {
    /// Check if this metric is completed today
    var isCompletedToday: Bool {
        // This would need to be implemented with actual entry data
        return false
    }
}

// MARK: - Widget Update Triggers
extension WidgetIntegration {
    /// Call this when a habit is logged
    func onHabitLogged(metric: Metric, entry: MetricEntry) {
        // Update widget data
        updateAllData(metrics: [metric], entries: [entry])
    }
    
    /// Call this when a metric is created or updated
    func onMetricChanged(metric: Metric, entries: [MetricEntry]) {
        updateMetrics([metric])
        updateGoals([metric], entries: entries)
    }
    
    /// Call this when data is imported or restored
    func onDataImported(metrics: [Metric], entries: [MetricEntry]) {
        updateAllData(metrics: metrics, entries: entries)
    }
}
