import SwiftUI

// MARK: - HabitType Enum
enum HabitType: String, CaseIterable, Codable {
    case positive = "positive"
    case vice = "vice"
    
    var displayName: String {
        switch self {
        case .positive: return "Positive Habit"
        case .vice: return "Vice to Avoid"
        }
    }
    
    var icon: String {
        switch self {
        case .positive: return "checkmark.circle.fill"
        case .vice: return "xmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .positive: return "green"
        case .vice: return "red"
        }
    }
}

// MARK: - GoalPeriod Enum
enum GoalPeriod: String, CaseIterable, Codable {
    case weekly = "weekly"
    case biWeekly = "biweekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .biWeekly: return "Bi-weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var maxDays: Int {
        switch self {
        case .weekly: return 7
        case .biWeekly: return 14
        case .monthly: return 31
        case .yearly: return 365
        }
    }
    
    /// Returns the actual number of days in the current period
    func actualDaysInCurrentPeriod() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .weekly:
            return 7
        case .biWeekly:
            return 14
        case .monthly:
            return calendar.range(of: .day, in: .month, for: now)?.count ?? 31
        case .yearly:
            return calendar.range(of: .day, in: .year, for: now)?.count ?? 365
        }
    }
    
    /// Returns the actual number of days in a specific period
    func actualDaysInPeriod(for date: Date) -> Int {
        let calendar = Calendar.current
        
        switch self {
        case .weekly:
            return 7
        case .biWeekly:
            return 14
        case .monthly:
            return calendar.range(of: .day, in: .month, for: date)?.count ?? 31
        case .yearly:
            return calendar.range(of: .day, in: .year, for: date)?.count ?? 365
        }
    }
}

// MARK: - MetricFilter Enum
enum MetricFilter: Hashable {
    case all
    case allHabits
    case allVices
    case specific(Metric)
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .allHabits: return "All Habits"
        case .allVices: return "All Vices"
        case .specific(let metric): return metric.name
        }
    }
    
    var icon: String? {
        switch self {
        case .all: return "square.grid.2x2"
        case .allHabits: return "checkmark.circle.fill"
        case .allVices: return "xmark.circle.fill"
        case .specific(let metric): return metric.safeHabitType.icon
        }
    }
    
    var color: String? {
        switch self {
        case .all: return "blue"
        case .allHabits: return "green"
        case .allVices: return "red"
        case .specific(let metric): return metric.safeHabitType.color
        }
    }
}

// MARK: - QuantityGoalType Enum
enum QuantityGoalType: String, CaseIterable, Codable {
    case maxDaily = "maxDaily"
    case avgDaily = "avgDaily"
    case totalPeriod = "totalPeriod"
    
    var displayName: String {
        switch self {
        case .maxDaily: return "Max Daily"
        case .avgDaily: return "Average Daily"
        case .totalPeriod: return "Total Period"
        }
    }
    
    var description: String {
        switch self {
        case .maxDaily: return "Keep under X per day"
        case .avgDaily: return "Average X per day"
        case .totalPeriod: return "Total X per period"
        }
    }
    
    var icon: String {
        switch self {
        case .maxDaily: return "arrow.down"
        case .avgDaily: return "chart.bar"
        case .totalPeriod: return "sum"
        }
    }
}

// MARK: - Theme Enum
enum Theme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "gear"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
