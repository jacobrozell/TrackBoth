import Foundation

// MARK: - Goal Preset Models
struct GoalPreset {
    let title: String
    let target: Int
    let description: String
}

struct QuantityPreset {
    let title: String
    let target: Int
    let unit: String
    let description: String
}

// MARK: - Preset Configurations

// Boolean Goal Presets
private let weeklyHabitPresets = [
    GoalPreset(title: "Daily", target: 7, description: "Every day"),
    GoalPreset(title: "5 Days", target: 5, description: "5 days per week"),
    GoalPreset(title: "3 Days", target: 3, description: "3 days per week"),
    GoalPreset(title: "Weekends", target: 2, description: "Weekends only")
]

private let weeklyVicePresets = [
    GoalPreset(title: "Never", target: 0, description: "Complete avoidance"),
    GoalPreset(title: "Rarely", target: 1, description: "Max 1 day"),
    GoalPreset(title: "Occasionally", target: 2, description: "Max 2 days"),
    GoalPreset(title: "Moderately", target: 3, description: "Max 3 days")
]

private let biWeeklyHabitPresets = [
    GoalPreset(title: "Daily", target: 14, description: "Every day"),
    GoalPreset(title: "5x Week", target: 10, description: "5 days per week"),
    GoalPreset(title: "3x Week", target: 6, description: "3 days per week"),
    GoalPreset(title: "Weekends", target: 4, description: "Weekends only")
]

private let biWeeklyVicePresets = [
    GoalPreset(title: "Never", target: 0, description: "Complete avoidance"),
    GoalPreset(title: "Rarely", target: 2, description: "Max 2 days"),
    GoalPreset(title: "Occasionally", target: 4, description: "Max 4 days"),
    GoalPreset(title: "Moderately", target: 6, description: "Max 6 days")
]

private let monthlyHabitPresets = [
    GoalPreset(title: "Daily", target: 30, description: "Every day"),
    GoalPreset(title: "5x Week", target: 20, description: "5 days per week"),
    GoalPreset(title: "3x Week", target: 12, description: "3 days per week"),
    GoalPreset(title: "Weekends", target: 8, description: "Weekends only")
]

private let monthlyVicePresets = [
    GoalPreset(title: "Never", target: 0, description: "Complete avoidance"),
    GoalPreset(title: "Rarely", target: 2, description: "Max 2 days"),
    GoalPreset(title: "Occasionally", target: 5, description: "Max 5 days"),
    GoalPreset(title: "Moderately", target: 10, description: "Max 10 days")
]

private let yearlyHabitPresets = [
    GoalPreset(title: "Daily", target: 365, description: "Every day"),
    GoalPreset(title: "5x Week", target: 260, description: "5 days per week"),
    GoalPreset(title: "3x Week", target: 156, description: "3 days per week"),
    GoalPreset(title: "Weekends", target: 104, description: "Weekends only")
]

private let yearlyVicePresets = [
    GoalPreset(title: "Never", target: 0, description: "Complete avoidance"),
    GoalPreset(title: "Rarely", target: 24, description: "Max 24 days"),
    GoalPreset(title: "Occasionally", target: 60, description: "Max 60 days"),
    GoalPreset(title: "Moderately", target: 120, description: "Max 120 days")
]

// MARK: - Quantity Preset Configurations

// Max Daily Presets
private let maxDailyHabitPresets = [
    QuantityPreset(title: "Light", target: 1, unit: "times", description: "1 time per day"),
    QuantityPreset(title: "Moderate", target: 3, unit: "times", description: "3 times per day"),
    QuantityPreset(title: "Heavy", target: 5, unit: "times", description: "5 times per day"),
    QuantityPreset(title: "Intense", target: 10, unit: "times", description: "10 times per day")
]

private let maxDailyVicePresets = [
    QuantityPreset(title: "Never", target: 0, unit: "times", description: "Complete avoidance"),
    QuantityPreset(title: "Rarely", target: 1, unit: "times", description: "Max 1 time per day"),
    QuantityPreset(title: "Occasionally", target: 2, unit: "times", description: "Max 2 times per day"),
    QuantityPreset(title: "Moderately", target: 3, unit: "times", description: "Max 3 times per day")
]

// Average Daily Presets
private let avgDailyHabitPresets = [
    QuantityPreset(title: "Light", target: 1, unit: "times", description: "Average 1 per day"),
    QuantityPreset(title: "Moderate", target: 2, unit: "times", description: "Average 2 per day"),
    QuantityPreset(title: "Heavy", target: 3, unit: "times", description: "Average 3 per day"),
    QuantityPreset(title: "Intense", target: 5, unit: "times", description: "Average 5 per day")
]

private let avgDailyVicePresets = [
    QuantityPreset(title: "Never", target: 0, unit: "times", description: "Complete avoidance"),
    QuantityPreset(title: "Rarely", target: 1, unit: "times", description: "Average 1 per day"),
    QuantityPreset(title: "Occasionally", target: 2, unit: "times", description: "Average 2 per day"),
    QuantityPreset(title: "Moderately", target: 3, unit: "times", description: "Average 3 per day")
]

// Total Period Presets
private let totalPeriodHabitPresets = [
    QuantityPreset(title: "Light", target: 7, unit: "times", description: "7 total this week"),
    QuantityPreset(title: "Moderate", target: 14, unit: "times", description: "14 total this week"),
    QuantityPreset(title: "Heavy", target: 21, unit: "times", description: "21 total this week"),
    QuantityPreset(title: "Intense", target: 35, unit: "times", description: "35 total this week")
]

private let totalPeriodVicePresets = [
    QuantityPreset(title: "Never", target: 0, unit: "times", description: "Complete avoidance"),
    QuantityPreset(title: "Rarely", target: 1, unit: "times", description: "Max 1 this week"),
    QuantityPreset(title: "Occasionally", target: 3, unit: "times", description: "Max 3 this week"),
    QuantityPreset(title: "Moderately", target: 7, unit: "times", description: "Max 7 this week")
]

// MARK: - Preset Access Functions
func getBooleanPresets(for period: GoalPeriod, isVice: Bool) -> [GoalPreset] {
    switch period {
    case .weekly:
        return isVice ? weeklyVicePresets : weeklyHabitPresets
    case .biWeekly:
        return isVice ? biWeeklyVicePresets : biWeeklyHabitPresets
    case .monthly:
        return isVice ? monthlyVicePresets : monthlyHabitPresets
    case .yearly:
        return isVice ? yearlyVicePresets : yearlyHabitPresets
    }
}

func getQuantityPresets(for type: QuantityGoalType, isVice: Bool) -> [QuantityPreset] {
    switch type {
    case .maxDaily:
        return isVice ? maxDailyVicePresets : maxDailyHabitPresets
    case .avgDaily:
        return isVice ? avgDailyVicePresets : avgDailyHabitPresets
    case .totalPeriod:
        return isVice ? totalPeriodVicePresets : totalPeriodHabitPresets
    }
}
