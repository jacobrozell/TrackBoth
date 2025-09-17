import Foundation
import SwiftData

// MARK: - Widget Data Models
/// Shared data models for widget communication

// MARK: - Widget Data Manager
/// Manages data sharing between the main app and widget
class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let appGroupIdentifier = "group.com.trackboth.app"
    private let userDefaults = UserDefaults(suiteName: "group.com.trackboth.app")
    
    private init() {}
    
    // MARK: - Data Storage
    
    /// Save metrics data for widget
    func saveMetrics(_ metrics: [Metric]) {
        logger.info("Saving metrics data for widget - Count: \(metrics.count)", category: .widget)
        let widgetMetrics = metrics.map { metric in
            TrackBothEntry.WidgetMetric(
                id: metric.id.uuidString,
                name: metric.name,
                habitType: metric.habitType.rawValue,
                isCompletedToday: false, // This would be calculated
                streak: 0 // This would be calculated
            )
        }
        
        if let data = try? JSONEncoder().encode(widgetMetrics) {
            userDefaults?.set(data, forKey: "widget_metrics")
        }
    }
    
    /// Save entries data for widget
    func saveEntries(_ entries: [MetricEntry]) {
        logger.info("Saving entries data for widget - Count: \(entries.count)", category: .widget)
        let widgetEntries = entries.map { entry in
            TrackBothEntry.WidgetEntry(
                metricID: entry.metricID.uuidString,
                value: entry.value,
                quantity: entry.quantity,
                unit: entry.unit
            )
        }
        
        if let data = try? JSONEncoder().encode(widgetEntries) {
            userDefaults?.set(data, forKey: "widget_entries")
        }
    }
    
    /// Save streaks data for widget
    func saveStreaks(_ streaks: [WidgetStreakData]) {
        let widgetStreaks = streaks.map { streak in
            TrackBothEntry.WidgetStreak(
                metricID: streak.metricID.uuidString,
                currentStreak: streak.currentStreak,
                longestStreak: streak.longestStreak
            )
        }
        
        if let data = try? JSONEncoder().encode(widgetStreaks) {
            userDefaults?.set(data, forKey: "widget_streaks")
        }
    }
    
    /// Save goals data for widget
    func saveGoals(_ goals: [WidgetGoalData]) {
        let widgetGoals = goals.map { goal in
            TrackBothEntry.WidgetGoal(
                metricID: goal.metricID.uuidString,
                name: goal.name,
                progress: goal.progress,
                target: goal.target,
                period: goal.period.rawValue
            )
        }
        
        if let data = try? JSONEncoder().encode(widgetGoals) {
            userDefaults?.set(data, forKey: "widget_goals")
        }
    }
    
    // MARK: - Data Retrieval
    
    /// Load metrics data for widget
    func loadMetrics() -> [TrackBothEntry.WidgetMetric] {
        guard let data = userDefaults?.data(forKey: "widget_metrics"),
              let metrics = try? JSONDecoder().decode([TrackBothEntry.WidgetMetric].self, from: data) else {
            return []
        }
        return metrics
    }
    
    /// Load entries data for widget
    func loadEntries() -> [TrackBothEntry.WidgetEntry] {
        guard let data = userDefaults?.data(forKey: "widget_entries"),
              let entries = try? JSONDecoder().decode([TrackBothEntry.WidgetEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    /// Load streaks data for widget
    func loadStreaks() -> [TrackBothEntry.WidgetStreak] {
        guard let data = userDefaults?.data(forKey: "widget_streaks"),
              let streaks = try? JSONDecoder().decode([TrackBothEntry.WidgetStreak].self, from: data) else {
            return []
        }
        return streaks
    }
    
    /// Load goals data for widget
    func loadGoals() -> [TrackBothEntry.WidgetGoal] {
        guard let data = userDefaults?.data(forKey: "widget_goals"),
              let goals = try? JSONDecoder().decode([TrackBothEntry.WidgetGoal].self, from: data) else {
            return []
        }
        return goals
    }
    
    /// Update widget timeline
    func updateWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Widget Data Models
struct WidgetStreakData {
    let metricID: UUID
    let currentStreak: Int
    let longestStreak: Int
}

struct WidgetGoalData {
    let metricID: UUID
    let name: String
    let progress: Double
    let target: Int
    let period: GoalPeriod
}

// MARK: - Widget Entry (Moved from TrackBothWidget.swift)
/// Timeline entry containing widget data
struct TrackBothEntry: TimelineEntry {
    let date: Date
    let metrics: [WidgetMetric]
    let todaysEntries: [WidgetEntry]
    let streaks: [WidgetStreak]
    let goals: [WidgetGoal]
    
    struct WidgetMetric: Codable {
        let id: String
        let name: String
        let habitType: String
        let isCompletedToday: Bool
        let streak: Int
    }
    
    struct WidgetEntry: Codable {
        let metricID: String
        let value: Bool
        let quantity: Int?
        let unit: String?
    }
    
    struct WidgetStreak: Codable {
        let metricID: String
        let currentStreak: Int
        let longestStreak: Int
    }
    
    struct WidgetGoal: Codable {
        let metricID: String
        let name: String
        let progress: Double
        let target: Int
        let period: String
    }
}
