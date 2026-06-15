import SwiftUI

// MARK: - Accessibility layout helpers
extension DynamicTypeSize {
    /// True when the user has enabled an accessibility text size (AX1–AX5).
    var usesAccessibilityLayout: Bool {
        isAccessibilitySize
    }
}

extension EnvironmentValues {
    var usesAccessibilityLayout: Bool {
        dynamicTypeSize.usesAccessibilityLayout
    }
}

extension TabBarLayout {
    /// Extra scroll padding when tab labels and content grow at accessibility sizes.
    static func scrollBottomInset(for mode: LayoutMode, dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        let base = scrollBottomInset(for: mode)
        guard dynamicTypeSize.usesAccessibilityLayout else { return base }
        switch mode {
        case .portrait:
            return max(base + 160, TabBarLayout.fabBottomInset + 96)
        case .compactLandscape:
            return max(base + 120, TabBarLayout.landscapeFabBottomInset + 80)
        case .sidebarSplit:
            return base + 48
        }
    }

    /// Bottom padding so the FAB clears the floating tab bar.
    static func fabOverlayClearance(isLandscape: Bool, dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        let base = fabBottomInset(isLandscape: isLandscape)
        guard dynamicTypeSize.usesAccessibilityLayout else { return base }
        return base + 44
    }
}

// MARK: - Adaptive navigation chrome
extension View {
    /// Use inline nav titles in compact landscape and accessibility text sizes.
    func adaptiveNavigationBarTitleDisplayMode(isCompactLandscape: Bool = false) -> some View {
        modifier(AdaptiveNavTitleModifier(isCompactLandscape: isCompactLandscape))
    }
}

private struct AdaptiveNavTitleModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let isCompactLandscape: Bool

    func body(content: Content) -> some View {
        content.navigationBarTitleDisplayMode(
            (isCompactLandscape || dynamicTypeSize.usesAccessibilityLayout) ? .inline : .large
        )
    }
}

// MARK: - Accessibility copy helpers
enum AccessibilityCopy {
    static func shortChartTitle(_ title: String, accessibility: Bool) -> String {
        guard accessibility else { return title }
        if title.contains("30-Day") { return "30-Day Trend" }
        return title
    }

    static func tabLabel(_ tab: TabItem, accessibility: Bool) -> String {
        guard accessibility else { return tab.standardTitle }
        return tab.accessibilityTitle
    }

    enum TabItem {
        case home, goals, motivation, history, charts

        var standardTitle: String {
            switch self {
            case .home: return "Home"
            case .goals: return "Goals"
            case .motivation: return "Motivation"
            case .history: return "History"
            case .charts: return "Charts"
            }
        }

        var accessibilityTitle: String {
            switch self {
            case .home: return "Home"
            case .goals: return "Goals"
            case .motivation: return "Motiv"
            case .history: return "Past"
            case .charts: return "Stats"
            }
        }
    }
}
