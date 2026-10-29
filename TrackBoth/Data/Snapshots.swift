import Foundation

enum Snapshots {
    static func viceHistory(for metric: Metric, entries: [MetricEntry], calendar: Calendar = .current) -> ViceHistory {
        let mine = entries.filter { $0.metricID == metric.id }
        let slips = mine.filter { $0.status == .slipped }.map(\.occurredAt)
        let confirmed = Set(mine.filter { $0.status == .free }.map { calendar.startOfDay(for: $0.day) })
        return ViceHistory(startedAt: metric.startedAt, slips: slips, confirmedFreeDays: confirmed)
    }

    static func habitHistory(for metric: Metric, entries: [MetricEntry], calendar: Calendar = .current) -> HabitHistory {
        let done = entries
            .filter { $0.metricID == metric.id && $0.status == .done }
            .map { calendar.startOfDay(for: $0.day) }
        return HabitHistory(startedAt: metric.startedAt, doneDays: Set(done))
    }
}
