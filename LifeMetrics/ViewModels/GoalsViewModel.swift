import Foundation
import SwiftData
import SwiftUI

// MARK: - GoalsViewModel
/// ViewModel for GoalsView containing goals management logic
@Observable
class GoalsViewModel {
    
    // MARK: - Properties
    var showingAddGoal = false
    
    // MARK: - Computed Properties
    /// Metrics with goals set
    func metricsWithGoals(_ metrics: [Metric]) -> [Metric] {
        metrics.filter { metric in
            metric.goalPeriod != nil && metric.goalTarget != nil
        }
    }
    
    /// Metrics without goals
    func metricsWithoutGoals(_ metrics: [Metric]) -> [Metric] {
        metrics.filter { metric in
            metric.goalPeriod == nil || metric.goalTarget == nil
        }
    }
    
    /// Calculate goal progress for a metric
    func goalProgress(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> (current: Int, target: Int, percentage: Double) {
        GoalUtils.calculateGoalProgress(for: metric, entries: entries, selectedDate: selectedDate)
    }
    
    /// Check if metric has achieved its goal
    func hasAchievedGoal(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> Bool {
        let progress = goalProgress(for: metric, entries: entries, selectedDate: selectedDate)
        return progress.current >= progress.target
    }
    
    /// Get goal status text
    func goalStatusText(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> String {
        let progress = goalProgress(for: metric, entries: entries, selectedDate: selectedDate)
        let period = metric.goalPeriod?.displayName ?? "period"
        
        if hasAchievedGoal(for: metric, entries: entries, selectedDate: selectedDate) {
            return "✅ Goal achieved this \(period)"
        } else {
            return "\(progress.current)/\(progress.target) this \(period)"
        }
    }
    
    // MARK: - Actions
    /// Show add goal sheet
    func showAddGoal() {
        showingAddGoal = true
    }
    
    /// Create a new goal for a metric
    func createGoal(for metric: Metric, period: GoalPeriod, target: Int, in modelContext: ModelContext) {
        metric.goalPeriod = period
        metric.goalTarget = target
        try? modelContext.save()
    }
    
    /// Update existing goal for a metric
    func updateGoal(for metric: Metric, period: GoalPeriod, target: Int, in modelContext: ModelContext) {
        metric.goalPeriod = period
        metric.goalTarget = target
        try? modelContext.save()
    }
    
    /// Remove goal from a metric
    func removeGoal(for metric: Metric, in modelContext: ModelContext) {
        metric.goalPeriod = nil
        metric.goalTarget = nil
        try? modelContext.save()
    }
    
    /// Reset all state
    func reset() {
        showingAddGoal = false
    }
}
