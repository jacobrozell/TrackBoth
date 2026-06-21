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

    static var showsDemoData: Bool { current == .development }
    static var showsCharts: Bool { true }
    static var showsWidget: Bool { current == .development }
    static var showsWatch: Bool { false }
    static var showsMotivationGame: Bool { false }
    static var showsAccessibilityMarketing: Bool { true }

    /// Whether a post-1.0 surface should be visible in the current build.
    static func isEnabled(_ feature: LeanFeature) -> Bool {
        switch feature {
        case .demoData: showsDemoData
        case .charts: showsCharts
        case .widget: showsWidget
        case .watch: showsWatch
        case .motivationGame: showsMotivationGame
        }
    }
}

enum LeanFeature {
    case demoData
    case charts
    case widget
    case watch
    case motivationGame
}
