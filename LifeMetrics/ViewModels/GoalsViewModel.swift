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
    /// Metrics with goals set (boolean or quantity)
    func metricsWithGoals(_ metrics: [Metric]) -> [Metric] {
        let startTime = Date()
        let result = metrics.filter { metric in
            GoalUtils.hasAnyGoal(metric)
        }
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Metrics with goals calculation", duration: duration)
        logger.debug("Metrics with goals calculated: \(result.count) out of \(metrics.count)", category: .business)
        return result
    }
    
    /// Metrics without goals
    func metricsWithoutGoals(_ metrics: [Metric]) -> [Metric] {
        metrics.filter { metric in
            !GoalUtils.hasAnyGoal(metric)
        }
    }
    
    /// Calculate goal progress for a metric
    func goalProgress(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> (current: Int, target: Int, percentage: Double) {
        let startTime = Date()
        
        // Use the first boolean goal for progress calculation
        guard let goal = metric.booleanGoals.first else {
            logger.debug("No boolean goal found for metric: \(metric.name)", category: .business)
            return (current: 0, target: 0, percentage: 0.0)
        }
        
        let result = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Goal progress calculation", duration: duration)
        logger.debug("Goal progress calculated - Metric: \(metric.name), Current: \(Int(result.current))/\(Int(result.target)) (\(String(format: "%.1f", result.percentage))%)", category: .business)
        return (current: Int(result.current), target: Int(result.target), percentage: result.percentage)
    }
    
    /// Check if metric has achieved its goal
    func hasAchievedGoal(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> Bool {
        let progress = goalProgress(for: metric, entries: entries, selectedDate: selectedDate)
        let achieved = progress.current >= progress.target
        logger.debug("Goal achievement check - Metric: \(metric.name), Achieved: \(achieved)", category: .business)
        return achieved
    }
    
    /// Get goal status text
    func goalStatusText(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> String {
        let progress = goalProgress(for: metric, entries: entries, selectedDate: selectedDate)
        let period = metric.booleanGoals.first?.period.displayName ?? "period"
        
        if hasAchievedGoal(for: metric, entries: entries, selectedDate: selectedDate) {
            return "✅ Goal achieved this \(period)"
        } else {
            return "\(progress.current)/\(progress.target) this \(period)"
        }
    }
    
    // MARK: - Quantity Goal Methods
    
    /// Calculate quantity goal progress for a metric
    func quantityGoalProgress(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> (current: Double, target: Double, percentage: Double, unit: String) {
        let startTime = Date()
        
        // Use the first quantity goal for progress calculation
        guard let goal = metric.quantityGoals.first else {
            logger.debug("No quantity goal found for metric: \(metric.name)", category: .business)
            return (current: 0.0, target: 0.0, percentage: 0.0, unit: "times")
        }
        
        let result = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Quantity goal progress calculation", duration: duration)
        logger.debug("Quantity goal progress calculated - Metric: \(metric.name), Current: \(result.current)/\(result.target) (\(String(format: "%.1f", result.percentage))%)", category: .business)
        return (current: result.current, target: result.target, percentage: result.percentage, unit: result.unit)
    }
    
    /// Check if metric has achieved its quantity goal
    func hasAchievedQuantityGoal(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> Bool {
        let progress = quantityGoalProgress(for: metric, entries: entries, selectedDate: selectedDate)
        let achieved = progress.current >= progress.target
        logger.debug("Quantity goal achievement check - Metric: \(metric.name), Achieved: \(achieved)", category: .business)
        return achieved
    }
    
    /// Get quantity goal status text
    func quantityGoalStatusText(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> String {
        let progress = quantityGoalProgress(for: metric, entries: entries, selectedDate: selectedDate)
        
        // Use the first quantity goal for status text
        guard let goal = metric.quantityGoals.first else {
            return "No quantity goal set"
        }
        
        return GoalUtils.getGoalStatusText(for: goal, metric: metric, progress: progress)
    }
    
    /// Check if metric has quantity goals set
    func hasQuantityGoal(_ metric: Metric) -> Bool {
        return GoalUtils.hasGoals(ofType: .quantity, in: metric)
    }
    
    /// Get metrics with quantity goals
    func metricsWithQuantityGoals(_ metrics: [Metric]) -> [Metric] {
        return metrics.filter { hasQuantityGoal($0) }
    }
    
    /// Get metrics with boolean goals only
    func metricsWithBooleanGoals(_ metrics: [Metric]) -> [Metric] {
        return metrics.filter { metric in
            !metric.booleanGoals.isEmpty
        }
    }
    
    // MARK: - Actions
    /// Show add goal sheet
    func showAddGoal() {
        showingAddGoal = true
    }
    
    /// Create a new boolean goal for a metric
    func createGoal(for metric: Metric, period: GoalPeriod, target: Int, in modelContext: ModelContext) {
        let newGoal = Goal(
            goalType: .boolean,
            period: period,
            target: target
        )
        newGoal.metric = metric
        metric.goals?.append(newGoal)
        modelContext.insert(newGoal)
        try? modelContext.save()
    }
    
    /// Update existing boolean goal for a metric
    func updateGoal(for metric: Metric, period: GoalPeriod, target: Int, in modelContext: ModelContext) {
        if let existingGoal = metric.booleanGoals.first {
            existingGoal.period = period
            existingGoal.target = target
        } else {
            createGoal(for: metric, period: period, target: target, in: modelContext)
        }
        try? modelContext.save()
    }
    
    /// Remove boolean goal from a metric
    func removeGoal(for metric: Metric, in modelContext: ModelContext) {
        if let goal = metric.booleanGoals.first {
            metric.goals?.removeAll { $0.id == goal.id }
            modelContext.delete(goal)
        }
        try? modelContext.save()
    }
    
    /// Create a quantity goal for a metric
    func createQuantityGoal(for metric: Metric, goalType: QuantityGoalType, target: Int, period: GoalPeriod, in modelContext: ModelContext) {
        let newGoal = Goal(
            goalType: .quantity,
            period: period,
            target: target,
            quantityGoalType: goalType
        )
        newGoal.metric = metric
        metric.goals?.append(newGoal)
        modelContext.insert(newGoal)
        try? modelContext.save()
    }
    
    /// Update existing quantity goal for a metric
    func updateQuantityGoal(for metric: Metric, goalType: QuantityGoalType, target: Int, period: GoalPeriod, in modelContext: ModelContext) {
        if let existingGoal = metric.quantityGoals.first {
            existingGoal.quantityGoalType = goalType
            existingGoal.target = target
            existingGoal.period = period
        } else {
            createQuantityGoal(for: metric, goalType: goalType, target: target, period: period, in: modelContext)
        }
        try? modelContext.save()
    }
    
    /// Remove quantity goal from a metric
    func removeQuantityGoal(for metric: Metric, in modelContext: ModelContext) {
        if let goal = metric.quantityGoals.first {
            metric.goals?.removeAll { $0.id == goal.id }
            modelContext.delete(goal)
        }
        try? modelContext.save()
    }
    
    /// Reset all state
    func reset() {
        showingAddGoal = false
    }
}
