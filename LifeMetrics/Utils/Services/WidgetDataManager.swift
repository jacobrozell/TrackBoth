import Foundation
import SwiftData
import WidgetKit

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
        let startTime = Date()
        
        let widgetMetrics = metrics.map { metric in
            WidgetMetricData(
                id: metric.id.uuidString,
                name: metric.name,
                habitType: metric.habitType.rawValue,
                isCompletedToday: false, // This would be calculated
                streak: 0 // This would be calculated
            )
        }
        
        if let data = try? JSONEncoder().encode(widgetMetrics) {
            userDefaults?.set(data, forKey: "widget_metrics")
            let duration = Date().timeIntervalSince(startTime)
            logger.logPerformance("Widget metrics save", duration: duration)
            logger.debug("Widget metrics saved successfully", category: .widget)
        } else {
            logger.error("Failed to encode widget metrics data", category: .widget)
        }
    }
    
    /// Save entries data for widget
    func saveEntries(_ entries: [MetricEntry]) {
        logger.info("Saving entries data for widget - Count: \(entries.count)", category: .widget)
        let startTime = Date()
        
        let widgetEntries = entries.map { entry in
            WidgetEntryData(
                metricID: entry.metricID.uuidString,
                value: entry.value,
                quantity: entry.quantity,
                unit: entry.unit
            )
        }
        
        if let data = try? JSONEncoder().encode(widgetEntries) {
            userDefaults?.set(data, forKey: "widget_entries")
            let duration = Date().timeIntervalSince(startTime)
            logger.logPerformance("Widget entries save", duration: duration)
            logger.debug("Widget entries saved successfully", category: .widget)
        } else {
            logger.error("Failed to encode widget entries data", category: .widget)
        }
    }
    
    /// Save streaks data for widget
    func saveStreaks(_ streaks: [WidgetStreakData]) {
        let widgetStreaks = streaks.map { streak in
            WidgetStreakInfo(
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
            WidgetGoalInfo(
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
    func loadMetrics() -> [WidgetMetricData] {
        guard let data = userDefaults?.data(forKey: "widget_metrics"),
              let metrics = try? JSONDecoder().decode([WidgetMetricData].self, from: data) else {
            return []
        }
        return metrics
    }
    
    /// Load entries data for widget
    func loadEntries() -> [WidgetEntryData] {
        guard let data = userDefaults?.data(forKey: "widget_entries"),
              let entries = try? JSONDecoder().decode([WidgetEntryData].self, from: data) else {
            return []
        }
        return entries
    }
    
    /// Load streaks data for widget
    func loadStreaks() -> [WidgetStreakInfo] {
        guard let data = userDefaults?.data(forKey: "widget_streaks"),
              let streaks = try? JSONDecoder().decode([WidgetStreakInfo].self, from: data) else {
            return []
        }
        return streaks
    }
    
    /// Load goals data for widget
    func loadGoals() -> [WidgetGoalInfo] {
        guard let data = userDefaults?.data(forKey: "widget_goals"),
              let goals = try? JSONDecoder().decode([WidgetGoalInfo].self, from: data) else {
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

// MARK: - Widget Data Transfer Objects
struct WidgetMetricData: Codable {
    let id: String
    let name: String
    let habitType: String
    let isCompletedToday: Bool
    let streak: Int
}

struct WidgetEntryData: Codable {
    let metricID: String
    let value: Bool
    let quantity: Int?
    let unit: String?
}

struct WidgetStreakInfo: Codable {
    let metricID: String
    let currentStreak: Int
    let longestStreak: Int
}

struct WidgetGoalInfo: Codable {
    let metricID: String
    let name: String
    let progress: Double
    let target: Int
    let period: String
}
