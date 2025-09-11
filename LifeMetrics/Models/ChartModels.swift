import Foundation

// MARK: - Chart Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
}

struct WeeklyData: Identifiable {
    let id = UUID()
    let week: String
    let count: Int
}

struct HeatmapData: Identifiable {
    let id = UUID()
    let date: Date
    let completed: Bool
}

// MARK: - Chart Type Enum
enum ChartType: String, CaseIterable {
    case line = "Line"
    case bar = "Bar"
    case heatmap = "Heatmap"

    var displayName: String {
        rawValue
    }
}
