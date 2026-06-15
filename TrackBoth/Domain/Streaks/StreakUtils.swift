import Foundation

// MARK: - Streak Calculation Utilities
struct StreakUtils {

    private static let maxLookbackDays = 365

    // MARK: - Per-metric streaks

    /// Calculate current streak for a metric.
    static func calculateCurrentStreak(
        for metric: Metric,
        entries: [MetricEntry],
        selectedDate: Date = Date()
    ) -> Int {
        guard TrackingSemantics.streakEligible(metric: metric) else { return 0 }

        let calendar = Calendar.current
        let entriesByDay = loggedEntriesByDay(for: metric, entries: entries)
        var streak = 0
        var dayCursor = calendar.startOfDay(for: selectedDate)

        for _ in 0..<maxLookbackDays {
            if let entry = entriesByDay[dayCursor] {
                if TrackingSemantics.isSuccessful(habitType: metric.habitType, value: entry.value) {
                    streak += 1
                } else {
                    break
                }
            } else if isUnloggedGraceDay(day: dayCursor, selectedDate: selectedDate, hasLoggedEntry: false) {
                // Today not logged yet — keep counting from yesterday.
            } else {
                break
            }

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dayCursor) else { break }
            dayCursor = previousDay
        }

        return streak
    }

    /// Calculate longest streak for a metric.
    static func calculateLongestStreak(for metric: Metric, entries: [MetricEntry]) -> Int {
        guard TrackingSemantics.streakEligible(metric: metric) else { return 0 }

        let successfulDays = loggedEntriesByDay(for: metric, entries: entries)
            .filter { _, entry in TrackingSemantics.isSuccessful(habitType: metric.habitType, value: entry.value) }
            .map(\.key)
            .sorted()

        return longestConsecutiveRun(from: successfulDays)
    }

    // MARK: - Filter-based streaks (charts / insights)

    static func filteredMetrics(for filter: MetricFilter, in metrics: [Metric]) -> [Metric] {
        FilterUtils.filteredMetrics(filter, in: metrics)
    }

    static func calculateFilterCurrentStreak(
        filter: MetricFilter,
        metrics: [Metric],
        entries: [MetricEntry],
        selectedDate: Date = Date()
    ) -> Int {
        switch filter {
        case .specific(let metric):
            return calculateCurrentStreak(for: metric, entries: entries, selectedDate: selectedDate)
        default:
            return calculateAggregateCurrentStreak(
                metrics: filteredMetrics(for: filter, in: metrics),
                entries: entries,
                selectedDate: selectedDate
            )
        }
    }

    static func calculateFilterLongestStreak(
        filter: MetricFilter,
        metrics: [Metric],
        entries: [MetricEntry]
    ) -> Int {
        switch filter {
        case .specific(let metric):
            return calculateLongestStreak(for: metric, entries: entries)
        default:
            return calculateAggregateLongestStreak(
                metrics: filteredMetrics(for: filter, in: metrics),
                entries: entries
            )
        }
    }

    // MARK: - Aggregate streaks

    /// Consecutive days ending at `selectedDate` where at least one metric had a successful logged day.
    static func calculateAggregateCurrentStreak(
        metrics: [Metric],
        entries: [MetricEntry],
        selectedDate: Date = Date()
    ) -> Int {
        let eligibleMetrics = metrics.filter { TrackingSemantics.streakEligible(metric: $0) }
        guard !eligibleMetrics.isEmpty else { return 0 }

        let calendar = Calendar.current
        let entriesByMetric = Dictionary(
            uniqueKeysWithValues: eligibleMetrics.map { ($0.id, loggedEntriesByDay(for: $0, entries: entries)) }
        )

        var streak = 0
        var dayCursor = calendar.startOfDay(for: selectedDate)

        for _ in 0..<maxLookbackDays {
            let daySuccess = eligibleMetrics.contains { metric in
                guard let entry = entriesByMetric[metric.id]?[dayCursor] else { return false }
                return TrackingSemantics.isSuccessful(habitType: metric.habitType, value: entry.value)
            }

            let anyLogged = eligibleMetrics.contains { metric in
                entriesByMetric[metric.id]?[dayCursor] != nil
            }

            if daySuccess {
                streak += 1
            } else if isUnloggedGraceDay(day: dayCursor, selectedDate: selectedDate, hasLoggedEntry: anyLogged) {
                // Today not logged yet for any metric in the group.
            } else {
                break
            }

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dayCursor) else { break }
            dayCursor = previousDay
        }

        return streak
    }

    /// Longest consecutive run of days where at least one metric had a successful logged day.
    static func calculateAggregateLongestStreak(metrics: [Metric], entries: [MetricEntry]) -> Int {
        let eligibleMetrics = metrics.filter { TrackingSemantics.streakEligible(metric: $0) }
        guard !eligibleMetrics.isEmpty else { return 0 }

        var successDays = Set<Date>()

        for metric in eligibleMetrics {
            let days = loggedEntriesByDay(for: metric, entries: entries)
                .filter { _, entry in TrackingSemantics.isSuccessful(habitType: metric.habitType, value: entry.value) }
                .map(\.key)
            successDays.formUnion(days)
        }

        return longestConsecutiveRun(from: successDays.sorted())
    }

    // MARK: - Private helpers

    private static func loggedEntriesByDay(for metric: Metric, entries: [MetricEntry]) -> [Date: MetricEntry] {
        let calendar = Calendar.current
        return entries
            .filter { $0.metricID == metric.id && TrackingSemantics.isLoggedForDay(entry: $0) }
            .reduce(into: [Date: MetricEntry]()) { acc, entry in
                let day = calendar.startOfDay(for: entry.date)
                if let existing = acc[day] {
                    if entry.date > existing.date { acc[day] = entry }
                } else {
                    acc[day] = entry
                }
            }
    }

    /// When viewing today, an unlogged day does not break the streak until the user logs.
    private static func isUnloggedGraceDay(day: Date, selectedDate: Date, hasLoggedEntry: Bool) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(selectedDate)
            && calendar.isDate(day, inSameDayAs: selectedDate)
            && !hasLoggedEntry
    }

    private static func longestConsecutiveRun(from sortedDays: [Date]) -> Int {
        guard !sortedDays.isEmpty else { return 0 }

        let calendar = Calendar.current
        var maxStreak = 1
        var currentStreak = 1

        for index in 1..<sortedDays.count {
            let daysDifference = calendar.dateComponents(
                [.day],
                from: sortedDays[index - 1],
                to: sortedDays[index]
            ).day ?? 0

            if daysDifference == 1 {
                currentStreak += 1
            } else {
                maxStreak = max(maxStreak, currentStreak)
                currentStreak = 1
            }
        }

        return max(maxStreak, currentStreak)
    }
}
