import Foundation

// MARK: - Streak Calculation Utilities
struct StreakUtils {
    
    /// Calculate current streak for a metric
    static func calculateCurrentStreak(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> Int {
        let startTime = Date()
        let isVice = metric.safeHabitType == .vice
        
        // For positive habits: count consecutive days with value == true
        // For vices: count consecutive days with value == false
        // Build quick lookup maps of entries by day for this metric
        let calendar = Calendar.current
        let startOfDayEntries = entries
            .filter { $0.metricID == metric.id }
            .reduce(into: [Date: MetricEntry]()) { acc, entry in
                let day = calendar.startOfDay(for: entry.date)
                // Prefer entries later in the day if duplicates exist
                if let existing = acc[day] {
                    if entry.date > existing.date { acc[day] = entry }
                } else {
                    acc[day] = entry
                }
            }

        var streak = 0
        let maxLookbackDays = 365
        var dayCursor = calendar.startOfDay(for: selectedDate)

        for _ in 0..<maxLookbackDays {
            if let entry = startOfDayEntries[dayCursor] {
                if isVice {
                    // For vices, a true entry breaks the clean streak
                    if entry.value == true { break }
                    // false (avoided) extends the streak
                    streak += 1
                } else {
                    // For positive habits, only true extends the streak
                    if entry.value == true {
                        streak += 1
                    } else {
                        break
                    }
                }
            } else {
                // No entry
                if isVice {
                    // Missing means avoided for vices → extend streak
                    streak += 1
                } else {
                    // Missing means not done for habits → break streak
                    break
                }
            }

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dayCursor) else { break }
            dayCursor = previousDay
        }

        return streak
    }
    
    /// Calculate longest streak for a metric
    static func calculateLongestStreak(for metric: Metric, entries: [MetricEntry]) -> Int {
        let startTime = Date()
        let isVice = metric.safeHabitType == .vice
        
        let sortedEntries = entries
            .filter { $0.metricID == metric.id && $0.value == !isVice }
            .sorted { $0.date < $1.date }
        
        var maxStreak = 0
        var currentStreak = 0
        let calendar = Calendar.current
        
        for i in 0..<sortedEntries.count {
            if i == 0 {
                currentStreak = 1
            } else {
                let prevDate = sortedEntries[i-1].date
                let currentDate = sortedEntries[i].date
                
                let daysDifference = calendar.dateComponents([.day], from: prevDate, to: currentDate).day ?? 0
                if daysDifference == 1 {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            }
        }
        
        return max(maxStreak, currentStreak)
    }
    
    /// Calculate current streak for filtered entries (already filtered for success)
    static func calculateCurrentStreak(filteredEntries: [MetricEntry], selectedDate: Date = Date()) -> Int {
        let sortedEntries = filteredEntries.sorted { $0.date > $1.date }
        
        var streak = 0
        let calendar = Calendar.current
        var currentDate = selectedDate
        
        for entry in sortedEntries {
            if calendar.isDate(entry.date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    /// Calculate longest streak for filtered entries
    static func calculateLongestStreak(filteredEntries: [MetricEntry]) -> Int {
        let sortedEntries = filteredEntries.sorted { $0.date < $1.date }
        
        var maxStreak = 0
        var currentStreak = 0
        let calendar = Calendar.current
        
        for i in 0..<sortedEntries.count {
            if i == 0 {
                currentStreak = 1
            } else {
                let prevDate = sortedEntries[i-1].date
                let currentDate = sortedEntries[i].date
                
                let daysDifference = calendar.dateComponents([.day], from: prevDate, to: currentDate).day ?? 0
                if daysDifference == 1 {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            }
        }
        
        return max(maxStreak, currentStreak)
    }
}
