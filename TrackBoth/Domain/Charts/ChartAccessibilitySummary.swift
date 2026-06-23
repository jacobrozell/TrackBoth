import Foundation

// MARK: - Chart VoiceOver summaries
enum ChartAccessibilitySummary {

    static func lineSummary(data: [ChartDataPoint], filter: MetricFilter) -> String {
        let title = ChartCopy.title(chartType: .line, filter: filter)
        guard !data.isEmpty else {
            return "\(title). \(ChartCopy.emptyMessage(chartType: .line, filter: filter))"
        }

        guard let latest = data.last, let first = data.first else { return title }

        let progress = latest.value - first.value
        let changePhrase: String
        if progress > 0 {
            changePhrase = "up \(progress) since the start"
        } else if progress < 0 {
            changePhrase = "down \(abs(progress)) since the start"
        } else {
            changePhrase = "unchanged since the start"
        }

        return "\(title). Cumulative total \(latest.value), \(changePhrase), across \(data.count) days."
    }

    static func barSummary(data: [WeeklyData], filter: MetricFilter) -> String {
        let title = ChartCopy.title(chartType: .bar, filter: filter)
        guard !data.isEmpty else {
            return "\(title). \(ChartCopy.emptyMessage(chartType: .bar, filter: filter))"
        }

        let total = data.reduce(0) { $0 + $1.count }
        if let bestWeek = data.max(by: { $0.count < $1.count }) {
            return "\(title). \(data.count) weeks tracked, \(total) total completions, best week \(bestWeek.week) with \(bestWeek.count)."
        }

        return "\(title). \(data.count) weeks tracked, \(total) total completions."
    }

    static func heatmapSummary(data: [HeatmapData], filter: MetricFilter) -> String {
        let title = ChartCopy.title(chartType: .heatmap, filter: filter)
        guard !data.isEmpty else {
            return "\(title). \(ChartCopy.emptyMessage(chartType: .heatmap, filter: filter))"
        }

        let completed = data.filter(\.completed).count
        let total = data.count
        let percent = total > 0 ? Int((Double(completed) / Double(total) * 100).rounded()) : 0
        return "\(title). \(completed) of \(total) days completed, \(percent) percent consistency."
    }

    static func quantitySummary(data: [QuantityDataPoint], filter: MetricFilter) -> String {
        let title = ChartCopy.title(chartType: .quantity, filter: filter)
        guard !data.isEmpty else {
            return "\(title). \(ChartCopy.emptyMessage(chartType: .quantity, filter: filter))"
        }

        let totalQuantity = data.reduce(0) { $0 + $1.quantity }
        let units = Set(data.compactMap(\.unit))
        let unitPhrase: String
        if units.count > 1 {
            unitPhrase = "mixed units"
        } else if let unit = units.first, !unit.isEmpty {
            unitPhrase = unit
        } else {
            unitPhrase = "items"
        }

        let average = Double(totalQuantity) / Double(data.count)
        return "\(title). \(data.count) logged entries, total \(totalQuantity) \(unitPhrase), average \(String(format: "%.1f", average)) per entry."
    }

    static func streakSummary(current: Int, longest: Int, filter: MetricFilter) -> String {
        let filterLabel: String
        switch filter {
        case .all: filterLabel = "all habits and vices"
        case .allHabits: filterLabel = "all habits"
        case .allVices: filterLabel = "all vices"
        case .specific(let metric): filterLabel = metric.name
        }
        return "Streak stats for \(filterLabel). Current streak \(current) days. Longest streak \(longest) days."
    }

    static func insightsSummary(_ insights: [Insight]) -> String {
        guard !insights.isEmpty else {
            return "Insights. Start tracking to unlock personalized insights."
        }
        let phrases = insights.map { "\($0.title): \($0.value), \($0.description)" }
        return "Insights. " + phrases.joined(separator: ". ") + "."
    }
}
