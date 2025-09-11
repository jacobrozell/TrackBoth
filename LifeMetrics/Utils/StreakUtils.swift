import Foundation

// MARK: - Streak Calculation Utilities
struct StreakUtils {
    
    /// Calculate current streak for a metric
    static func calculateCurrentStreak(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> Int {
        let isVice = metric.safeHabitType == .vice
        
        // For positive habits: count consecutive days with value == true
        // For vices: count consecutive days with value == false
        let sortedEntries = entries
            .filter { $0.metricID == metric.id && $0.value == !isVice }
            .sorted { $0.date > $1.date }
        
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
    
    /// Calculate longest streak for a metric
    static func calculateLongestStreak(for metric: Metric, entries: [MetricEntry]) -> Int {
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
