import Foundation

// MARK: - Goal Calculation Utilities
struct GoalUtils {
    
    /// Calculate goal progress for a metric
    static func calculateGoalProgress(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> (current: Int, target: Int, percentage: Double) {
        let isVice = metric.safeHabitType == .vice
        let period = metric.goalPeriod ?? .monthly
        let target = metric.goalTarget ?? 20
        
        let startOfPeriod = CalendarHelper.startOfPeriod(period, for: selectedDate)
        let endOfPeriod = CalendarHelper.endOfPeriod(period, for: selectedDate)
        
        let current = entries.filter { entry in
            entry.metricID == metric.id &&
            entry.date >= startOfPeriod &&
            entry.date <= endOfPeriod &&
            entry.value == !isVice
        }.count
        
        let actualDaysInPeriod = period.actualDaysInPeriod(for: selectedDate)
        let effectiveTarget = min(target, actualDaysInPeriod)
        let percentage = effectiveTarget > 0 ? Double(current) / Double(effectiveTarget) : 0.0
        
        return (current: current, target: effectiveTarget, percentage: min(percentage, 1.0))
    }
    
    /// Calculate goal progress for a specific historical period
    static func calculateHistoricalGoalProgress(for metric: Metric, entries: [MetricEntry], periodStart: Date, periodEnd: Date) -> (current: Int, target: Int, percentage: Double, wasAchieved: Bool) {
        let isVice = metric.safeHabitType == .vice
        let target = metric.goalTarget ?? 20
        
        let current = entries.filter { entry in
            entry.metricID == metric.id &&
            entry.date >= periodStart &&
            entry.date <= periodEnd &&
            entry.value == !isVice
        }.count
        
        let percentage = target > 0 ? Double(current) / Double(target) : 0.0
        let wasAchieved = current >= target
        
        return (current: current, target: target, percentage: min(percentage, 1.0), wasAchieved: wasAchieved)
    }
    
    /// Calculate goal progress for filtered entries
    static func calculateGoalProgress(filteredEntries: [MetricEntry], period: GoalPeriod, target: Int, selectedDate: Date = Date()) -> (current: Int, target: Int, percentage: Double) {
        let startOfPeriod = CalendarHelper.startOfPeriod(period, for: selectedDate)
        
        let current = filteredEntries.filter { entry in
            entry.date >= startOfPeriod &&
            entry.date <= selectedDate &&
            entry.value == true
        }.count
        
        let actualDaysInPeriod = period.actualDaysInCurrentPeriod()
        let effectiveTarget = min(target, actualDaysInPeriod)
        let percentage = effectiveTarget > 0 ? Double(current) / Double(effectiveTarget) : 0.0
        
        return (current: current, target: effectiveTarget, percentage: min(percentage, 1.0))
    }
    
    /// Get goal status text for a metric
    static func getGoalStatusText(for metric: Metric, progress: (current: Int, target: Int, percentage: Double)) -> String {
        let isVice = metric.safeHabitType == .vice
        let period = metric.goalPeriod ?? .monthly
        
        if progress.current >= progress.target {
            return isVice ? "Goal achieved! 🎉" : "Goal achieved! 🎉"
        } else {
            let remaining = progress.target - progress.current
            let periodText = period.displayName.lowercased()
            return isVice ? "\(remaining) more days to avoid this \(periodText)" : "\(remaining) more days to reach your \(periodText) goal"
        }
    }
}
