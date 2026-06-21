import Foundation

// MARK: - Product Surface
/// Gates lean 1.0 Release vs development-only features.
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

    /// Full dev surface — extra tabs and polish targets not in 1.0 Release.
    private static var isFullDevelopment: Bool {
        #if DEBUG
        return !forceLeanUI
        #else
        return false
        #endif
    }

    static var showsDemoData: Bool { isFullDevelopment }

    /// Goals tab — dev only; goal progress still shows on Track rows in Release.
    static var showsGoals: Bool { isFullDevelopment }

    static var showsMotivation: Bool { true }
    static var showsCharts: Bool { true }
    static var showsMilestoneBanners: Bool { true }
    static var showsExtendedRowMetadata: Bool { true }

    /// Quantity chart type — partial polish; dev only until QA passes.
    static var showsQuantityCharts: Bool { isFullDevelopment }

    static var showsExtendedThemes: Bool { isFullDevelopment }
    static var showsAdvancedMetricSetup: Bool { isFullDevelopment }
    static var showsExtendedLogging: Bool { isFullDevelopment }
    static var showsWidget: Bool { isFullDevelopment }
    static var showsWatch: Bool { false }
    static var showsMotivationGame: Bool { false }
    static var showsAccessibilityMarketing: Bool { true }

    /// Whether a post-1.0 surface should be visible in the current build.
    static func isEnabled(_ feature: LeanFeature) -> Bool {
        switch feature {
        case .demoData: showsDemoData
        case .goals: showsGoals
        case .motivation: showsMotivation
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
