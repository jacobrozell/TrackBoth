import Foundation
import AppIntents
import SwiftData

// MARK: - Log Habit Intent
/// App Intent for logging habits directly from the widget
struct LogHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Habit"
    static var description: IntentDescription = "Log a habit or vice directly from the widget"
    
    @Parameter(title: "Metric ID")
    var metricID: String
    
    @Parameter(title: "Value")
    var value: Bool
    
    func perform() async throws -> some IntentResult {
        // This would interact with the shared data container
        // For now, we'll just return success
        return .result()
    }
}

// MARK: - Open App Intent
/// App Intent for opening the main app
struct OpenAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Open QuickLog"
    static var description: IntentDescription = "Open the QuickLog app"
    
    func perform() async throws -> some IntentResult & OpensIntent {
        return .result(opensIntent: true)
    }
}

// MARK: - Open Charts Intent
/// App Intent for opening the Charts view
struct OpenChartsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Charts"
    static var description: IntentDescription = "Open the Charts view in QuickLog"
    
    func perform() async throws -> some IntentResult & OpensIntent {
        return .result(opensIntent: true)
    }
}

// MARK: - Open Goals Intent
/// App Intent for opening the Goals view
struct OpenGoalsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Goals"
    static var description: IntentDescription = "Open the Goals view in QuickLog"
    
    func perform() async throws -> some IntentResult & OpensIntent {
        return .result(opensIntent: true)
    }
}

// MARK: - Widget Data Manager and Models
/// (Defined in WidgetDataModels.swift)
