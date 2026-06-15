import Foundation

// MARK: - Goal Calculation Utilities
struct GoalUtils {

    /// Calculate goal progress for a specific goal
    static func calculateGoalProgress(
        for goal: Goal,
        metric: Metric,
        entries: [MetricEntry],
        selectedDate: Date = Date()
    ) -> (current: Double, target: Double, percentage: Double, unit: String) {
        let target = Double(goal.target)
        let unit = goal.goalType == .boolean ? "days" : goal.safeDefaultUnit

        let startOfPeriod = CalendarHelper.startOfPeriod(goal.period, for: selectedDate)
        let endOfPeriod = CalendarHelper.endOfPeriod(goal.period, for: selectedDate)

        let relevantEntries = entries.filter { entry in
            entry.metricID == metric.id &&
            entry.date >= startOfPeriod &&
            entry.date <= endOfPeriod &&
            TrackingSemantics.isLoggedForDay(entry: entry)
        }

        let current: Double
        if goal.goalType == .boolean {
            let successfulDays = Set(
                relevantEntries
                    .filter { TrackingSemantics.isSuccessful(habitType: metric.habitType, value: $0.value) }
                    .map { Calendar.current.startOfDay(for: $0.date) }
            )
            current = Double(successfulDays.count)
        } else {
            let quantityEntries = relevantEntries.filter(\.hasQuantity)
            switch goal.quantityGoalType ?? .totalPeriod {
            case .maxDaily:
                let dailyQuantities = Dictionary(grouping: quantityEntries) { entry in
                    Calendar.current.startOfDay(for: entry.date)
                }.mapValues { dayEntries in
                    dayEntries.compactMap(\.quantity).reduce(0, +)
                }
                current = Double(dailyQuantities.values.max() ?? 0)
            case .avgDaily:
                let totalQuantity = quantityEntries.compactMap(\.quantity).reduce(0, +)
                let daysWithEntries = Set(quantityEntries.map { Calendar.current.startOfDay(for: $0.date) }).count
                current = daysWithEntries > 0 ? Double(totalQuantity) / Double(daysWithEntries) : 0
            case .totalPeriod:
                current = Double(quantityEntries.compactMap(\.quantity).reduce(0, +))
            }
        }

        let percentage = target > 0 ? min(current / target, 1.0) : 0.0
        return (current: current, target: target, percentage: percentage, unit: unit)
    }

    /// Calculate goal progress for a specific historical period
    static func calculateHistoricalGoalProgress(
        for goal: Goal,
        metric: Metric,
        entries: [MetricEntry],
        periodStart: Date,
        periodEnd: Date
    ) -> (current: Double, target: Double, percentage: Double, wasAchieved: Bool, unit: String) {
        let target = Double(goal.target)
        let unit = goal.goalType == .boolean ? "days" : goal.safeDefaultUnit

        let relevantEntries = entries.filter { entry in
            entry.metricID == metric.id &&
            entry.date >= periodStart &&
            entry.date <= periodEnd &&
            TrackingSemantics.isLoggedForDay(entry: entry)
        }

        let current: Double
        if goal.goalType == .boolean {
            let successfulDays = Set(
                relevantEntries
                    .filter { TrackingSemantics.isSuccessful(habitType: metric.habitType, value: $0.value) }
                    .map { Calendar.current.startOfDay(for: $0.date) }
            )
            current = Double(successfulDays.count)
        } else {
            let quantityEntries = relevantEntries.filter(\.hasQuantity)
            switch goal.quantityGoalType ?? .totalPeriod {
            case .maxDaily:
                let dailyQuantities = Dictionary(grouping: quantityEntries) { entry in
                    Calendar.current.startOfDay(for: entry.date)
                }.mapValues { dayEntries in
                    dayEntries.compactMap(\.quantity).reduce(0, +)
                }
                current = Double(dailyQuantities.values.max() ?? 0)
            case .avgDaily:
                let totalQuantity = quantityEntries.compactMap(\.quantity).reduce(0, +)
                let daysWithEntries = Set(quantityEntries.map { Calendar.current.startOfDay(for: $0.date) }).count
                current = daysWithEntries > 0 ? Double(totalQuantity) / Double(daysWithEntries) : 0
            case .totalPeriod:
                current = Double(quantityEntries.compactMap(\.quantity).reduce(0, +))
            }
        }

        let percentage = target > 0 ? min(current / target, 1.0) : 0.0
        return (current: current, target: target, percentage: percentage, wasAchieved: current >= target, unit: unit)
    }

    static func getGoalStatusText(
        for goal: Goal,
        metric: Metric,
        progress: (current: Double, target: Double, percentage: Double, unit: String)
    ) -> String {
        if progress.current >= progress.target {
            return "Goal achieved! 🎉"
        }

        let remaining = progress.target - progress.current
        let remainingText = String(format: "%.1f", remaining)
        let periodText = goal.period.displayName.lowercased()

        if goal.goalType == .boolean {
            if metric.habitType == .vice {
                return "\(Int(remaining)) more days to avoid this \(periodText)"
            }
            return "\(Int(remaining)) more days to reach your \(periodText) goal"
        }

        switch goal.quantityGoalType ?? .totalPeriod {
        case .maxDaily:
            return "\(remainingText) \(progress.unit) under daily limit"
        case .avgDaily:
            return "\(remainingText) \(progress.unit) to reach daily average"
        case .totalPeriod:
            return "\(remainingText) \(progress.unit) to reach \(periodText) total"
        }
    }

    static func hasAnyGoal(_ metric: Metric) -> Bool {
        !(metric.goals?.isEmpty ?? true)
    }

    static func hasGoals(for period: GoalPeriod, in metric: Metric) -> Bool {
        !metric.goals(for: period).isEmpty
    }

    static func hasGoals(ofType goalType: GoalType, in metric: Metric) -> Bool {
        !(metric.goals?.filter { $0.goalType == goalType }.isEmpty ?? true)
    }
}
