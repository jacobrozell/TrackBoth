import Foundation

// MARK: - Product Surface
/// Gates lean 1.0 Release vs development-only features.
/// See `specs/ProductSurfaceSpec.md`.
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

    /// Forces Confidence 1.0 navigation in DEBUG (UI tests, screenshots).
    static var forceLeanUI: Bool {
        ProcessInfo.processInfo.arguments.contains("-lean_ui")
    }

    static var showsDemoData: Bool { current == .development }
    static var showsGoals: Bool { current == .development && !forceLeanUI }
    static var showsMotivation: Bool { current == .development && !forceLeanUI }
    static var showsCharts: Bool { current == .development && !forceLeanUI }
    static var showsMilestoneBanners: Bool { current == .development && !forceLeanUI }
    static var showsExtendedRowMetadata: Bool { current == .development && !forceLeanUI }
    static var showsExtendedThemes: Bool { current == .development && !forceLeanUI }
    static var showsWidget: Bool { current == .development }
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
    case widget
    case watch
    case motivationGame
}
