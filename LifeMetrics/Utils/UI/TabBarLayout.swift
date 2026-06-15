import SwiftUI
import UIKit

// MARK: - Interface orientation
enum InterfaceLayout {
    /// True when the active window scene is in a landscape interface orientation.
    static var isLandscape: Bool {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .contains { $0.interfaceOrientation.isLandscape }
    }
}

// MARK: - TabBarLayout
/// Shared spacing and layout decisions for tab content, FABs, and landscape adaptation.
enum TabBarLayout {
    /// Extra scroll padding inside the content area.
    static let contentScrollPadding: CGFloat = 16
    /// Bottom inset for scroll content above the tab bar (portrait).
    static let scrollBottomInset: CGFloat = 96
    /// Portrait scroll padding below list content (tab bar + breathing room).
    static let portraitScrollBottomInset: CGFloat = scrollBottomInset
    /// Bottom inset for floating action buttons (portrait) — legacy overlay positioning.
    static let fabBottomInset: CGFloat = 96
    static let fabDiameter: CGFloat = 56
    /// Landscape tab bar is ~64pt; keep content above it.
    static let landscapeTabBarHeight: CGFloat = 64
    static let landscapeScrollBottomInset: CGFloat = landscapeTabBarHeight + 8
    static let landscapeFabBottomInset: CGFloat = landscapeTabBarHeight + 12
    /// iPad sidebar split: modest trailing scroll padding (FAB uses safeAreaInset).
    static let sidebarScrollBottomInset: CGFloat = contentScrollPadding
    static let fabTrailingInset: CGFloat = 20
    /// Vertical padding inside the FAB safe-area inset bar.
    static let fabInsetVerticalPadding: CGFloat = 8

    /// Maximum width for filter / stats sidebars on wide layouts (iPad, Plus landscape).
    static let sidebarMaxWidth: CGFloat = 300
    static let sidebarWidthFraction: CGFloat = 0.34

    /// How a tab should adapt when horizontal space grows but height stays phone-sized.
    enum LayoutMode {
        case portrait
        /// iPhone landscape: extra width, limited height — stay single-column, tighten chrome.
        case compactLandscape
        /// iPad / wide phones: sidebar + main content split.
        case sidebarSplit
    }

    static func sidebarWidth(for totalWidth: CGFloat) -> CGFloat {
        min(sidebarMaxWidth, totalWidth * sidebarWidthFraction)
    }

    static func scrollBottomInset(for mode: LayoutMode) -> CGFloat {
        switch mode {
        case .portrait:
            return portraitScrollBottomInset
        case .compactLandscape:
            return landscapeScrollBottomInset
        case .sidebarSplit:
            return sidebarScrollBottomInset
        }
    }

    static func scrollBottomInset(isLandscape: Bool) -> CGFloat {
        isLandscape ? landscapeScrollBottomInset : portraitScrollBottomInset
    }

    static func shouldUseSidebarSplit(
        size: CGSize,
        horizontal: UserInterfaceSizeClass?,
        vertical: UserInterfaceSizeClass?
    ) -> Bool {
        guard usesSidebarSplit(horizontal: horizontal, vertical: vertical) else {
            return false
        }
        if size.isLandscapeLayout { return true }
        // iPad landscape: tab chrome can leave a portrait-shaped content area.
        return InterfaceLayout.isLandscape
    }

    static func fabBottomInset(isLandscape: Bool) -> CGFloat {
        isLandscape ? landscapeFabBottomInset : fabBottomInset
    }
    static func isLandscape(_ size: CGSize) -> Bool {
        size.isLandscapeLayout
    }

    /// Sidebar split is for iPad-class layouts only (both axes regular).
    /// iPhone landscape stays compact even when horizontal size class is regular (Plus/Air).
    static func usesSidebarSplit(
        horizontal: UserInterfaceSizeClass?,
        vertical: UserInterfaceSizeClass?
    ) -> Bool {
        horizontal == .regular && vertical == .regular
    }

    static func isCompactLandscape(
        horizontal: UserInterfaceSizeClass?,
        vertical: UserInterfaceSizeClass?
    ) -> Bool {
        vertical == .compact
    }
}

extension CGSize {
    var isLandscapeLayout: Bool { width > height }
}

extension View {
    func tabBarScrollContentInset(isLandscape: Bool = false) -> some View {
        padding(.bottom, TabBarLayout.scrollBottomInset(isLandscape: isLandscape))
    }

    func tabBarFloatingActionButton(isLandscape: Bool = false, action: @escaping () -> Void) -> some View {
        modifier(TabBarFloatingActionButtonModifier(isLandscape: isLandscape, action: action))
    }

    func landscapeSidebarWidth(_ totalWidth: CGFloat) -> some View {
        frame(width: TabBarLayout.sidebarWidth(for: totalWidth))
    }
}

private struct TabBarFloatingActionButtonModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let isLandscape: Bool
    let action: () -> Void

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                Spacer(minLength: 0)
                FloatingActionButton(action: action)
                    .padding(.trailing, TabBarLayout.fabTrailingInset)
            }
            .padding(.top, TabBarLayout.fabInsetVerticalPadding)
            .padding(.bottom, fabInsetBottomPadding)
        }
    }

    private var fabInsetBottomPadding: CGFloat {
        dynamicTypeSize.usesExpandedChrome ? 4 : 0
    }
}
