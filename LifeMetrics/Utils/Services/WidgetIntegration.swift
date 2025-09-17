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
        return StreakUtils.calculateCurrentStreak(for: metric, entries: entries)
    }
    
    private func calculateLongestStreak(for metric: Metric, entries: [MetricEntry]) -> Int {
        return StreakUtils.calculateLongestStreak(for: metric, entries: entries)
    }
    
    private func calculateGoals(_ metrics: [Metric], entries: [MetricEntry]) -> [WidgetGoalData] {
        return metrics.compactMap { metric in
            guard let goal = metric.booleanGoals.first else {
                return nil
            }
            
            // Calculate progress based on current period using actual entry data
            let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries)
            
            return WidgetGoalData(
                metricID: metric.id,
                name: metric.name,
                progress: progress.percentage / 100.0,
                target: Int(progress.target),
                period: goal.period
            )
        }
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
