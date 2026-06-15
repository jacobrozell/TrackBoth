import Foundation

// MARK: - ViceSlipTimer
enum ViceSlipTimer {
    static func lastSlipDate(metricID: UUID, entries: [MetricEntry]) -> Date? {
        entries
            .filter { $0.metricID == metricID && $0.hasBeenLogged && $0.value == true }
            .map(\.date)
            .max()
    }

    /// Elapsed time since the most recent logged slip, framed as recovery.
    static func formattedRecoveryTime(
        metricID: UUID,
        entries: [MetricEntry],
        asOf date: Date = Date()
    ) -> String? {
        guard let lastSlip = lastSlipDate(metricID: metricID, entries: entries) else { return nil }

        let calendar = Calendar.current
        let from = calendar.startOfDay(for: lastSlip)
        guard from <= date else { return nil }

        let components = calendar.dateComponents([.day, .hour], from: from, to: date)
        let days = max(0, components.day ?? 0)
        let hours = max(0, components.hour ?? 0)

        if days == 0, hours == 0 { return "< 1h recovering" }
        if days == 0 { return "\(hours)h recovering" }
        if hours == 0 { return "\(days)d recovering" }
        return "\(days)d \(hours)h recovering"
    }

    /// Short label for compact UI under the clean-day badge.
    static func compactRecoveryLabel(
        metricID: UUID,
        entries: [MetricEntry],
        asOf date: Date = Date()
    ) -> String? {
        guard let lastSlip = lastSlipDate(metricID: metricID, entries: entries) else { return nil }

        let calendar = Calendar.current
        let from = calendar.startOfDay(for: lastSlip)
        guard from <= date else { return nil }

        let days = max(0, calendar.dateComponents([.day], from: from, to: date).day ?? 0)
        if days == 0 { return "Recovering" }
        return "\(days)d recovering"
    }
}
