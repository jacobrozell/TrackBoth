import Foundation

// MARK: - Chart Copy
/// Shared chart titles and empty-state messages keyed by chart type and metric filter.
enum ChartCopy {

    private enum Tone {
        case habit
        case vice
        case mixed

        static func from(filter: MetricFilter) -> Tone {
            switch filter {
            case .allHabits:
                return .habit
            case .allVices:
                return .vice
            case .all:
                return .mixed
            case .specific(let metric):
                return metric.habitType == .vice ? .vice : .habit
            }
        }
    }

    static func title(chartType: ChartType, filter: MetricFilter) -> String {
        switch chartType {
        case .line:
            switch Tone.from(filter: filter) {
            case .vice: return "30-Day Avoidance Trend"
            case .habit: return "30-Day Completion Trend"
            case .mixed: return "30-Day Progress Trend"
            }
        case .bar:
            switch Tone.from(filter: filter) {
            case .vice: return "Weekly Avoidance"
            case .habit: return "Weekly Completion"
            case .mixed: return "Weekly Progress"
            }
        case .heatmap:
            switch Tone.from(filter: filter) {
            case .vice: return "90-Day Avoidance Heatmap"
            case .habit: return "90-Day Completion Heatmap"
            case .mixed: return "90-Day Progress Heatmap"
            }
        case .quantity:
            switch filter {
            case .all: return "Quantity Trends"
            case .allHabits: return "Positive Habits Quantity"
            case .allVices: return "Vice Quantities Logged"
            case .specific(let metric): return "Quantity Tracking - \(metric.name)"
            }
        }
    }

    static func emptyMessage(chartType: ChartType, filter: MetricFilter) -> String {
        if case .specific(let metric) = filter {
            let isVice = metric.habitType == .vice
            switch chartType {
            case .line:
                return isVice ? "Avoid this vice to see your progress" : "Complete this habit to see your progress"
            case .bar:
                return isVice ? "Avoid this vice to see weekly patterns" : "Complete this habit to see weekly patterns"
            case .heatmap:
                return isVice ? "Avoid this vice to build your consistency map" : "Complete this habit to build your consistency map"
            case .quantity:
                return "Log quantities to see trends"
            }
        }

        switch chartType {
        case .line:
            switch Tone.from(filter: filter) {
            case .vice: return "Avoid vices to see your progress"
            case .habit: return "Complete habits to see your progress"
            case .mixed: return "Start tracking to see your progress"
            }
        case .bar:
            switch Tone.from(filter: filter) {
            case .vice: return "Avoid vices to see weekly patterns"
            case .habit: return "Complete habits to see weekly patterns"
            case .mixed: return "Track habits to see weekly patterns"
            }
        case .heatmap:
            switch Tone.from(filter: filter) {
            case .vice: return "Avoid vices to build your consistency map"
            case .habit: return "Complete habits to build your consistency map"
            case .mixed: return "Start tracking to build your consistency map"
            }
        case .quantity:
            return "Log quantities to see trends"
        }
    }
}
