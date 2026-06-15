import Foundation
import SwiftData
import SwiftUI

// MARK: - Query Descriptors
/// Shared `@Query` scopes to avoid full-table fetches where a bounded window is enough.
enum QueryDescriptors {
    /// Days of history needed for streak calculations (matches `StreakUtils` lookback).
    static let streakLookbackDays = 365

    static func monthInterval(for date: Date, calendar: Calendar = .current) -> (start: Date, end: Date) {
        let interval = calendar.dateInterval(of: .month, for: date)
        let start = interval?.start ?? calendar.startOfDay(for: date)
        let end = interval?.end ?? start
        return (start, end)
    }

    static func streakLookbackInterval(
        endingOn endDay: Date = Date(),
        calendar: Calendar = .current
    ) -> (start: Date, end: Date) {
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDay)) ?? endDay
        let start = calendar.date(
            byAdding: .day,
            value: -streakLookbackDays,
            to: calendar.startOfDay(for: endDay)
        ) ?? endDay
        return (start, end)
    }

    static func entriesInMonth(of date: Date) -> Query<MetricEntry, [MetricEntry]> {
        let interval = monthInterval(for: date)
        let start = interval.start
        let end = interval.end
        return Query(
            filter: #Predicate<MetricEntry> { entry in
                entry.date >= start && entry.date < end
            },
            sort: \.date,
            order: .reverse
        )
    }

    static func entriesForStreakLookback(endingOn endDay: Date = Date()) -> Query<MetricEntry, [MetricEntry]> {
        let interval = streakLookbackInterval(endingOn: endDay)
        let start = interval.start
        let end = interval.end
        return Query(
            filter: #Predicate<MetricEntry> { entry in
                entry.date >= start && entry.date < end
            },
            sort: \.date,
            order: .reverse
        )
    }

    static var allMetrics: Query<Metric, [Metric]> {
        Query(sort: \.name)
    }

    /// Maximum chart visualization window (`ChartDataProcessor` heatmap).
    static let chartLookbackDays = 90

    /// Covers the longest goal period (yearly) around a reference date.
    static let goalLookbackDays = 366

    static func entriesFrom(
        _ start: Date,
        before end: Date
    ) -> Query<MetricEntry, [MetricEntry]> {
        Query(
            filter: #Predicate<MetricEntry> { entry in
                entry.date >= start && entry.date < end
            },
            sort: \.date,
            order: .reverse
        )
    }

    static func entriesForChartLookback(endingOn endDay: Date = Date()) -> Query<MetricEntry, [MetricEntry]> {
        let calendar = Calendar.current
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDay)) ?? endDay
        let start = calendar.date(byAdding: .day, value: -chartLookbackDays, to: calendar.startOfDay(for: endDay)) ?? endDay
        return entriesFrom(start, before: end)
    }

    static func entriesForGoalLookback(around date: Date = Date()) -> Query<MetricEntry, [MetricEntry]> {
        let calendar = Calendar.current
        let anchor = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: anchor) ?? anchor
        let start = calendar.date(byAdding: .day, value: -goalLookbackDays, to: anchor) ?? anchor
        return entriesFrom(start, before: end)
    }

    /// Entries that may carry daily motivation text.
    static var entriesWithMotivation: Query<MetricEntry, [MetricEntry]> {
        Query(
            filter: #Predicate<MetricEntry> { entry in
                entry.motivation != nil
            },
            sort: \.date,
            order: .reverse
        )
    }
}
