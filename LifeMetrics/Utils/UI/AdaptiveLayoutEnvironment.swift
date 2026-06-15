import SwiftUI

// MARK: - Adaptive layout environment
/// Propagates layout mode from the root so tabs share one source of truth.
private struct AdaptiveLayoutModeKey: EnvironmentKey {
    static let defaultValue: TabBarLayout.LayoutMode = .portrait
}

extension EnvironmentValues {
    var adaptiveLayoutMode: TabBarLayout.LayoutMode {
        get { self[AdaptiveLayoutModeKey.self] }
        set { self[AdaptiveLayoutModeKey.self] = newValue }
    }

    var isCompactLandscape: Bool {
        adaptiveLayoutMode == .compactLandscape
    }

    var usesSidebarSplit: Bool {
        adaptiveLayoutMode == .sidebarSplit
    }

    var usesLandscapeChrome: Bool {
        adaptiveLayoutMode != .portrait
    }
}

extension View {
    /// Call on the root container (e.g. TabView) to publish layout mode to all tabs.
    func publishAdaptiveLayoutMode(
        horizontal: UserInterfaceSizeClass?,
        vertical: UserInterfaceSizeClass?
    ) -> some View {
        let mode = TabBarLayout.layoutMode(horizontal: horizontal, vertical: vertical)
        return environment(\.adaptiveLayoutMode, mode)
    }
}

extension TabBarLayout {
    static func layoutMode(
        horizontal: UserInterfaceSizeClass?,
        vertical: UserInterfaceSizeClass?
    ) -> LayoutMode {
        if usesSidebarSplit(horizontal: horizontal, vertical: vertical), InterfaceLayout.isLandscape {
            return .sidebarSplit
        }
        if isCompactLandscape(horizontal: horizontal, vertical: vertical) {
            return .compactLandscape
        }
        return .portrait
    }
}
