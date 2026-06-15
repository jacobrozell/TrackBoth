import Foundation

// MARK: - Filter Utilities
struct FilterUtils {

    static func matchesFilter(_ filter: MetricFilter, entry: MetricEntry, metrics: [Metric]) -> Bool {
        switch filter {
        case .all:
            return true
        case .allHabits:
            return metrics.first(where: { $0.id == entry.metricID })?.habitType == .positive
        case .allVices:
            return metrics.first(where: { $0.id == entry.metricID })?.habitType == .vice
        case .specific(let metric):
            return entry.metricID == metric.id
        }
    }

    static func filteredEntries(_ filter: MetricFilter, entries: [MetricEntry], metrics: [Metric]) -> [MetricEntry] {
        entries.filter { matchesFilter(filter, entry: $0, metrics: metrics) }
    }

    /// Entries that match filter and represent a successful logged day for the metric type.
    static func successfulEntries(
        _ filter: MetricFilter,
        entries: [MetricEntry],
        metrics: [Metric]
    ) -> [MetricEntry] {
        entries.filter { entry in
            guard matchesFilter(filter, entry: entry, metrics: metrics),
                  TrackingSemantics.isLoggedForDay(entry: entry),
                  let metric = metrics.first(where: { $0.id == entry.metricID }) else {
                return false
            }
            return TrackingSemantics.isSuccessful(habitType: metric.habitType, value: entry.value)
        }
    }

    @available(*, deprecated, message: "Use successfulEntries for semantic success filtering")
    static func filteredEntries(
        _ filter: MetricFilter,
        entries: [MetricEntry],
        metrics: [Metric],
        value: Bool
    ) -> [MetricEntry] {
        entries.filter { entry in
            matchesFilter(filter, entry: entry, metrics: metrics) && entry.value == value
        }
    }
}
