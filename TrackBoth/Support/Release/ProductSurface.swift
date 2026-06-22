import Foundation

// MARK: - Product Surface
/// Gates App Store Release vs development-only features.
/// See `Specs/ProductSurfaceSpec.md`.
enum ProductSurfaceKind: Equatable {
    case lean1_0
    case development
}

enum ProductSurface {
    static var current: ProductSurfaceKind {
        #if DEBUG
        return .development
        #else
        return .lean1_0
        #endif
    }

    /// Simulates the App Store ship surface in DEBUG (UI tests, screenshots).
    static var forceLeanUI: Bool {
        ProcessInfo.processInfo.arguments.contains("-lean_ui")
    }

    /// Full dev surface — extras not shipped to App Store users.
    private static var isFullDevelopment: Bool {
        #if DEBUG
        return !forceLeanUI
        #else
        return false
        #endif
    }

    // MARK: - Dev-only (never in Release)

    static var showsDemoData: Bool { isFullDevelopment }
    static var showsWidget: Bool { isFullDevelopment }
    static var showsWatch: Bool { false }
    static var showsMotivationGame: Bool { false }

    // MARK: - Ships in Release (1.0)

    static var showsInsights: Bool { true }
    static var showsGoals: Bool { true }
    static var showsMotivation: Bool { true }
    static var showsQuantityCharts: Bool { true }
    static var showsMilestoneBanners: Bool { true }
    static var showsExtendedRowMetadata: Bool { true }
    static var showsExtendedThemes: Bool { true }
    static var showsAdvancedMetricSetup: Bool { true }
    static var showsExtendedLogging: Bool { isFullDevelopment }
    static var showsAccessibilityMarketing: Bool { true }

    /// Legacy flags — charts/history live inside Insights.
    static var showsCharts: Bool { showsInsights }
    static var showsHistory: Bool { showsInsights }

    static func isEnabled(_ feature: LeanFeature) -> Bool {
        switch feature {
        case .demoData: showsDemoData
        case .goals: showsGoals
        case .motivation: showsMotivation
        case .insights: showsInsights
        case .charts: showsCharts
        case .milestoneBanners: showsMilestoneBanners
        case .extendedRowMetadata: showsExtendedRowMetadata
        case .extendedThemes: showsExtendedThemes
        case .advancedMetricSetup: showsAdvancedMetricSetup
        case .extendedLogging: showsExtendedLogging
        case .quantityCharts: showsQuantityCharts
        case .widget: showsWidget
        case .watch: showsWatch
        case .motivationGame: showsMotivationGame
        }
    }
}

enum LeanFeature {
    case demoData
    case goals
    case motivation
    case insights
    case charts
    case milestoneBanners
    case extendedRowMetadata
    case extendedThemes
    case advancedMetricSetup
    case extendedLogging
    case quantityCharts
    case widget
    case watch
    case motivationGame
}
