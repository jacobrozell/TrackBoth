import SwiftUI

// MARK: - Accessibility layout helpers
extension DynamicTypeSize {
    /// True when the user has enabled an accessibility text size (AX1–AX5).
    var usesAccessibilityLayout: Bool {
        isAccessibilitySize
    }

    /// Larger text sizes that need relaxed layouts (accessibility sizes and XLarge+).
    var usesExpandedChrome: Bool {
        isAccessibilitySize || self >= .xLarge
    }

    /// Stacked Track rows and scrollable Insights calendar (XXXL and accessibility sizes).
    var usesRelaxedListLayout: Bool {
        isAccessibilitySize || self >= .xxxLarge
    }
}

extension EnvironmentValues {
    var usesAccessibilityLayout: Bool {
        dynamicTypeSize.usesAccessibilityLayout
    }

    var usesExpandedChrome: Bool {
        dynamicTypeSize.usesExpandedChrome
    }

    var usesRelaxedListLayout: Bool {
        dynamicTypeSize.usesRelaxedListLayout
    }
}

extension TabBarLayout {
    /// Extra scroll padding when tab labels and content grow at larger text sizes.
    static func scrollBottomInset(for mode: LayoutMode, dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        let base = scrollBottomInset(for: mode)
        guard dynamicTypeSize.usesExpandedChrome else { return base }
        switch mode {
        case .portrait:
            return base + 32
        case .compactLandscape:
            return base + 24
        case .sidebarSplit:
            return base + 16
        }
    }
}

// MARK: - Adaptive navigation chrome
extension View {
    /// Use inline nav titles in compact landscape and larger text sizes.
    func adaptiveNavigationBarTitleDisplayMode(isCompactLandscape: Bool = false) -> some View {
        modifier(AdaptiveNavTitleModifier(isCompactLandscape: isCompactLandscape))
    }
}

private struct AdaptiveNavTitleModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.isCompactLandscape) private var environmentCompactLandscape
    let isCompactLandscape: Bool

    func body(content: Content) -> some View {
        let usesInlineTitle = isCompactLandscape
            || environmentCompactLandscape
            || dynamicTypeSize.usesExpandedChrome
        content.navigationBarTitleDisplayMode(usesInlineTitle ? .inline : .large)
    }
}

// MARK: - Accessibility copy helpers
enum AccessibilityCopy {
    static func shortChartTitle(_ title: String, accessibility: Bool) -> String {
        guard accessibility else { return title }
        if title.contains("30-Day") { return "30-Day Trend" }
        return title
    }

    static func tabLabel(_ tab: TabItem, iconOnly: Bool) -> String {
        iconOnly ? tab.compactTitle : tab.standardTitle
    }

    enum TabItem {
        case track, home, settings, goals, motivation, insights, history, charts

        var standardTitle: String {
            switch self {
            case .track: return "Track"
            case .home: return "Home"
            case .settings: return "Settings"
            case .goals: return "Goals"
            case .motivation: return "Motivation"
            case .insights: return "Insights"
            case .history: return "History"
            case .charts: return "Charts"
            }
        }

        /// Short labels when five tabs need to fit at larger Dynamic Type sizes.
        var compactTitle: String {
            switch self {
            case .track: return "Track"
            case .home: return "Home"
            case .settings: return "Settings"
            case .goals: return "Goals"
            case .motivation: return "Motiv."
            case .insights: return "Insights"
            case .history: return "History"
            case .charts: return "Charts"
            }
        }

        var accessibilityTitle: String { standardTitle }
    }
}
