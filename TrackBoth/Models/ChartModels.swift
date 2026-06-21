import Foundation

// MARK: - Chart Data Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
    
    init(date: Date, value: Int) {
        self.date = date
        self.value = value
        logger.debug("ChartDataPoint created - Date: \(DateFormatter.dateFormatter.string(from: date)), Value: \(value)", category: .data)
    }
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

struct QuantityDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let quantity: Int
    let unit: String?
    let metricName: String
    let habitType: HabitType
}

struct WeeklyQuantityData: Identifiable {
    let id = UUID()
    let week: String
    let totalQuantity: Int
    let averageQuantity: Double
    let unit: String?
}

// MARK: - Chart Type Enum
enum ChartType: String, CaseIterable {
    case line = "Line"
    case bar = "Bar"
    case heatmap = "Heatmap"
    case quantity = "Quantity"

    var displayName: String {
        rawValue
    }

    /// Chart types shipped in lean 1.0 Release (quantity deferred until polish passes).
    static var availableInCurrentSurface: [ChartType] {
        if ProductSurface.showsQuantityCharts {
            return allCases
        }
        return [.line, .bar, .heatmap]
    }
}
