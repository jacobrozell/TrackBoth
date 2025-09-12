import Foundation

// MARK: - Goal Calculation Utilities
struct GoalUtils {
    
    /// Calculate goal progress for a specific goal
    static func calculateGoalProgress(for goal: Goal, metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> (current: Double, target: Double, percentage: Double, unit: String) {
        let startTime = Date()
        let isVice = metric.safeHabitType == .vice
        
        let startOfPeriod = CalendarHelper.startOfPeriod(goal.period, for: selectedDate)
        let endOfPeriod = CalendarHelper.endOfPeriod(goal.period, for: selectedDate)
        
        let relevantEntries = entries.filter { entry in
            entry.metricID == metric.id &&
            entry.date >= startOfPeriod &&
            entry.date <= endOfPeriod
        }
        
        let current: Double
        let target = Double(goal.target)
        let unit: String
        
        if goal.goalType == .boolean {
            // Boolean goal: count successful days
            let successfulDays = relevantEntries.filter { entry in
                entry.value == !isVice
            }.count
            
            let actualDaysInPeriod = goal.period.actualDaysInPeriod(for: selectedDate)
            let effectiveTarget = min(goal.target, actualDaysInPeriod)
            current = Double(successfulDays)
            unit = "days"
        } else {
            // Quantity goal: calculate based on quantity type
            let quantityEntries = relevantEntries.filter { $0.hasQuantity }
            
            switch goal.quantityGoalType ?? .totalPeriod {
            case .maxDaily:
                // For max daily, find the highest daily quantity
                let dailyQuantities = Dictionary(grouping: quantityEntries) { entry in
                    Calendar.current.startOfDay(for: entry.date)
                }.mapValues { entries in
                    entries.compactMap { $0.quantity }.reduce(0, +)
                }
                current = Double(dailyQuantities.values.max() ?? 0)
                
            case .avgDaily:
                // For average daily, calculate average quantity per day
                let totalQuantity = quantityEntries.compactMap { $0.quantity }.reduce(0, +)
                let daysWithEntries = Set(quantityEntries.map { Calendar.current.startOfDay(for: $0.date) }).count
                current = daysWithEntries > 0 ? Double(totalQuantity) / Double(daysWithEntries) : 0
                
            case .totalPeriod:
                // For total period, sum all quantities in the period
                current = Double(quantityEntries.compactMap { $0.quantity }.reduce(0, +))
            }
            
            unit = goal.safeDefaultUnit
        }
        
        let percentage = target > 0 ? min(current / target, 1.0) : 0.0
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Goal progress calculation", duration: duration)
        logger.debug("Goal progress - Metric: \(metric.name), Type: \(goal.goalType.rawValue), Period: \(goal.period.rawValue), Current: \(current)/\(target) (\(String(format: "%.1f", percentage * 100))%)", category: .business)
        
        return (current: current, target: target, percentage: percentage, unit: unit)
    }
    
    /// Calculate goal progress for a specific historical period
    static func calculateHistoricalGoalProgress(for goal: Goal, metric: Metric, entries: [MetricEntry], periodStart: Date, periodEnd: Date) -> (current: Double, target: Double, percentage: Double, wasAchieved: Bool, unit: String) {
        let isVice = metric.safeHabitType == .vice
        
        let relevantEntries = entries.filter { entry in
            entry.metricID == metric.id &&
            entry.date >= periodStart &&
            entry.date <= periodEnd
        }
        
        let current: Double
        let target = Double(goal.target)
        let unit: String
        
        if goal.goalType == .boolean {
            // Boolean goal: count successful days
            let successfulDays = relevantEntries.filter { entry in
                entry.value == !isVice
            }.count
            current = Double(successfulDays)
            unit = "days"
        } else {
            // Quantity goal: calculate based on quantity type
            let quantityEntries = relevantEntries.filter { $0.hasQuantity }
            
            switch goal.quantityGoalType ?? .totalPeriod {
            case .maxDaily:
                let dailyQuantities = Dictionary(grouping: quantityEntries) { entry in
                    Calendar.current.startOfDay(for: entry.date)
                }.mapValues { entries in
                    entries.compactMap { $0.quantity }.reduce(0, +)
                }
                current = Double(dailyQuantities.values.max() ?? 0)
                
            case .avgDaily:
                let totalQuantity = quantityEntries.compactMap { $0.quantity }.reduce(0, +)
                let daysWithEntries = Set(quantityEntries.map { Calendar.current.startOfDay(for: $0.date) }).count
                current = daysWithEntries > 0 ? Double(totalQuantity) / Double(daysWithEntries) : 0
                
            case .totalPeriod:
                current = Double(quantityEntries.compactMap { $0.quantity }.reduce(0, +))
            }
            
            unit = goal.safeDefaultUnit
        }
        
        let percentage = target > 0 ? min(current / target, 1.0) : 0.0
        let wasAchieved = current >= target
        
        return (current: current, target: target, percentage: percentage, wasAchieved: wasAchieved, unit: unit)
    }
    
    /// Get goal status text for a specific goal
    static func getGoalStatusText(for goal: Goal, metric: Metric, progress: (current: Double, target: Double, percentage: Double, unit: String)) -> String {
        let isVice = metric.safeHabitType == .vice
        
        if progress.current >= progress.target {
            return "Goal achieved! 🎉"
        } else {
            let remaining = progress.target - progress.current
            let remainingText = String(format: "%.1f", remaining)
            let periodText = goal.period.displayName.lowercased()
            
            if goal.goalType == .boolean {
                return isVice ? "\(Int(remaining)) more days to avoid this \(periodText)" : "\(Int(remaining)) more days to reach your \(periodText) goal"
            } else {
                switch goal.quantityGoalType ?? .totalPeriod {
                case .maxDaily:
                    return "\(remainingText) \(progress.unit) under daily limit"
                case .avgDaily:
                    return "\(remainingText) \(progress.unit) to reach daily average"
                case .totalPeriod:
                    return "\(remainingText) \(progress.unit) to reach \(periodText) total"
                }
            }
        }
    }
    
    /// Check if metric has any goals set
    static func hasAnyGoal(_ metric: Metric) -> Bool {
        return !(metric.goals?.isEmpty ?? true)
    }
    
    /// Check if metric has goals for a specific period
    static func hasGoals(for period: GoalPeriod, in metric: Metric) -> Bool {
        return !metric.goals(for: period).isEmpty
    }
    
    /// Check if metric has goals of a specific type
    static func hasGoals(ofType goalType: GoalType, in metric: Metric) -> Bool {
        return !(metric.goals?.filter { $0.goalType == goalType }.isEmpty ?? true)
    }
}
