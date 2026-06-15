import Foundation

// MARK: - CalendarHelper
/// Utility class for consistent calendar operations throughout the app
/// Handles user preferences for week start day and provides date calculations
class CalendarHelper {
    
    // MARK: - Properties
    /// Get the user's preferred week start day from AppStorage
    static var weekStartDay: Int {
        UserDefaults.standard.object(forKey: "weekStartDay") as? Int ?? 1
    }
    
    /// Create a calendar with the user's preferred week start day
    static var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = weekStartDay
        return cal
    }
    
    // MARK: - Date Calculations
    /// Get the start of the week for a given date using user's preference
    static func startOfWeek(for date: Date) -> Date {
        let cal = calendar
        return cal.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }
    
    /// Get the end of the week for a given date using user's preference
    static func endOfWeek(for date: Date) -> Date {
        let cal = calendar
        return cal.dateInterval(of: .weekOfYear, for: date)?.end ?? date
    }
    
    /// Get the start of the bi-weekly period for a given date
    static func startOfBiWeek(for date: Date) -> Date {
        return startOfWeek(for: date)
    }
    
    /// Get the end of the bi-weekly period for a given date
    static func endOfBiWeek(for date: Date) -> Date {
        let cal = calendar
        let weekStart = startOfWeek(for: date)
        return cal.date(byAdding: .day, value: 14, to: weekStart) ?? weekStart
    }
    
    /// Get the start of the month for a given date
    static func startOfMonth(for date: Date) -> Date {
        let cal = calendar
        return cal.dateInterval(of: .month, for: date)?.start ?? date
    }
    
    /// Get the end of the month for a given date
    static func endOfMonth(for date: Date) -> Date {
        let cal = calendar
        return cal.dateInterval(of: .month, for: date)?.end ?? date
    }
    
    /// Get the start of the year for a given date
    static func startOfYear(for date: Date) -> Date {
        let cal = calendar
        return cal.dateInterval(of: .year, for: date)?.start ?? date
    }
    
    /// Get the end of the year for a given date
    static func endOfYear(for date: Date) -> Date {
        let cal = calendar
        return cal.dateInterval(of: .year, for: date)?.end ?? date
    }
    
    /// Get the start date for a given goal period
    static func startOfPeriod(_ period: GoalPeriod, for date: Date) -> Date {
        switch period {
        case .weekly:
            return startOfWeek(for: date)
        case .monthly:
            return startOfMonth(for: date)
        case .yearly:
            return startOfYear(for: date)
        }
    }
    
    /// Get the end date for a given goal period
    static func endOfPeriod(_ period: GoalPeriod, for date: Date) -> Date {
        switch period {
        case .weekly:
            return endOfWeek(for: date)
        case .monthly:
            return endOfMonth(for: date)
        case .yearly:
            return endOfYear(for: date)
        }
    }
    
    /// Get days remaining in the current period
    static func daysRemainingInPeriod(_ period: GoalPeriod, from date: Date = Date()) -> Int {
        let cal = calendar
        let endDate = endOfPeriod(period, for: date)
        return cal.dateComponents([.day], from: date, to: endDate).day ?? 0
    }
    
    /// Get the first weekday of a month for calendar display
    static func firstWeekdayOfMonth(for date: Date) -> Int {
        let cal = calendar
        let startOfMonth = startOfMonth(for: date)
        return cal.component(.weekday, from: startOfMonth)
    }
    
    /// Get the calendar start date for a month (including previous month's days)
    static func calendarStartForMonth(for date: Date) -> Date {
        let cal = calendar
        let startOfMonth = startOfMonth(for: date)
        let firstWeekday = firstWeekdayOfMonth(for: date)
        let daysToSubtract = (firstWeekday - cal.firstWeekday + 7) % 7
        return cal.date(byAdding: .day, value: -daysToSubtract, to: startOfMonth) ?? startOfMonth
    }
    
    // MARK: - Date Comparison Utilities
    
    /// Check if a date is today
    static func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    /// Check if two dates are on the same day
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    /// Get start of day for a date
    static func startOfDay(for date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    /// Add days to a date
    static func addDays(_ days: Int, to date: Date) -> Date {
        return calendar.date(byAdding: .day, value: days, to: date) ?? date
    }
    
    /// Get the number of days between two dates
    static func daysBetween(_ startDate: Date, _ endDate: Date) -> Int {
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    
    /// Check if a date is in the current week
    static func isInCurrentWeek(_ date: Date) -> Bool {
        return calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Check if two dates are in the same week
    static func isSameWeek(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, equalTo: date2, toGranularity: .weekOfYear)
    }
    
    /// Check if a date is in the current month
    static func isInCurrentMonth(_ date: Date) -> Bool {
        return calendar.isDate(date, equalTo: Date(), toGranularity: .month)
    }
    
    /// Check if a date is in the current year
    static func isInCurrentYear(_ date: Date) -> Bool {
        return calendar.isDate(date, equalTo: Date(), toGranularity: .year)
    }
    
    /// Get the number of days in a month
    static func daysInMonth(for date: Date) -> Int {
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }
    
    /// Get the number of days in a year
    static func daysInYear(for date: Date) -> Int {
        return calendar.range(of: .day, in: .year, for: date)?.count ?? 365
    }
}
