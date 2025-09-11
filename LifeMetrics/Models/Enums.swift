import Foundation

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
        let calendar = CalendarHelper.calendar
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
        let calendar = CalendarHelper.calendar
        
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
