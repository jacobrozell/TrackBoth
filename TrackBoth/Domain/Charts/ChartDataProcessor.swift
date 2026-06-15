import Foundation

// MARK: - Chart Data Processor
/// Pure data aggregation for chart visualizations.
enum ChartDataProcessor {

    static func cumulativeSuccessTrend(
        filter: MetricFilter,
        entries: [MetricEntry],
        metrics: [Metric],
        dayCount: Int = 30,
        calendar: Calendar = .current,
        endDate: Date = Date()
    ) -> [ChartDataPoint] {
        let startDate = calendar.date(byAdding: .day, value: -dayCount, to: endDate) ?? endDate
        var data: [ChartDataPoint] = []
        var currentDate = startDate
        var cumulativeCount = 0

        while currentDate <= endDate {
            let dayEntries = entries.filter { entry in
                calendar.isDate(entry.date, inSameDayAs: currentDate) &&
                FilterUtils.matchesFilter(filter, entry: entry, metrics: metrics)
            }

            if !FilterUtils.successfulEntries(filter, entries: dayEntries, metrics: metrics).isEmpty {
                cumulativeCount += 1
            }

            data.append(ChartDataPoint(date: currentDate, value: cumulativeCount))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return data
    }

    static func weeklySuccessCounts(
        filter: MetricFilter,
        entries: [MetricEntry],
        metrics: [Metric],
        dayCount: Int = 28,
        calendar: Calendar = CalendarHelper.calendar,
        endDate: Date = Date()
    ) -> [WeeklyData] {
        let startDate = calendar.date(byAdding: .day, value: -dayCount, to: endDate) ?? endDate
        var weeklyCounts: [String: Int] = [:]

        for entry in FilterUtils.successfulEntries(filter, entries: entries, metrics: metrics) {
            guard entry.date >= startDate, entry.date <= endDate else { continue }
            let weekStart = CalendarHelper.startOfWeek(for: entry.date)
            let weekKey = DateFormatter.weekFormatter.string(from: weekStart)
            weeklyCounts[weekKey, default: 0] += 1
        }

        return weeklyCounts
            .map { WeeklyData(week: $0.key, count: $0.value) }
            .sorted { $0.week < $1.week }
    }

    static func dailySuccessHeatmap(
        filter: MetricFilter,
        entries: [MetricEntry],
        metrics: [Metric],
        dayCount: Int = 90,
        calendar: Calendar = .current,
        endDate: Date = Date()
    ) -> [HeatmapData] {
        let startDate = calendar.date(byAdding: .day, value: -dayCount, to: endDate) ?? endDate
        var data: [HeatmapData] = []
        var currentDate = startDate

        while currentDate <= endDate {
            let dayEntries = entries.filter { entry in
                calendar.isDate(entry.date, inSameDayAs: currentDate) &&
                FilterUtils.matchesFilter(filter, entry: entry, metrics: metrics)
            }

            let completed = !FilterUtils.successfulEntries(filter, entries: dayEntries, metrics: metrics).isEmpty
            data.append(HeatmapData(date: currentDate, completed: completed))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return data
    }
}
