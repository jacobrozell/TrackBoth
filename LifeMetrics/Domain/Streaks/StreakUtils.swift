import Foundation

// MARK: - Streak Calculation Utilities
struct StreakUtils {
    
    /// Calculate current streak for a metric
    static func calculateCurrentStreak(for metric: Metric, entries: [MetricEntry], selectedDate: Date = Date()) -> Int {
        guard TrackingSemantics.streakEligible(metric: metric) else { return 0 }

        let habitType = metric.habitType
        let calendar = Calendar.current
        let startOfDayEntries = entries
            .filter { $0.metricID == metric.id && TrackingSemantics.isLoggedForDay(entry: $0) }
            .reduce(into: [Date: MetricEntry]()) { acc, entry in
                let day = calendar.startOfDay(for: entry.date)
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
            guard let entry = startOfDayEntries[dayCursor] else { break }

            if TrackingSemantics.isSuccessful(habitType: habitType, value: entry.value) {
                streak += 1
            } else {
                break
            }

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dayCursor) else { break }
            dayCursor = previousDay
        }

        return streak
    }
    
    /// Calculate longest streak for a metric
    static func calculateLongestStreak(for metric: Metric, entries: [MetricEntry]) -> Int {
        let sortedEntries = entries
            .filter {
                $0.metricID == metric.id &&
                TrackingSemantics.isLoggedForDay(entry: $0) &&
                TrackingSemantics.isSuccessful(habitType: metric.habitType, value: $0.value)
            }
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
