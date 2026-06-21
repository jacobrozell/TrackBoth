import Foundation

// MARK: - DayLogCompletionState
enum DayLogCompletionState: Equatable {
    case none
    case partial
    case complete
}

// MARK: - DayLogSummary
enum DayLogSummary {
    static func completionState(
        metrics: [Metric],
        entries: [MetricEntry],
        on day: Date,
        calendar: Calendar = .current
    ) -> DayLogCompletionState {
        guard !metrics.isEmpty else { return .none }

        let startOfDay = calendar.startOfDay(for: day)
        let loggedCount = metrics.reduce(into: 0) { count, metric in
            guard let entry = entries.first(where: {
                $0.metricID == metric.id && calendar.isDate($0.date, inSameDayAs: startOfDay)
            }) else { return }

            if TrackingSemantics.isLoggedForDay(entry: entry) {
                count += 1
            }
        }

        if loggedCount == 0 { return .none }
        if loggedCount == metrics.count { return .complete }
        return .partial
    }
}
