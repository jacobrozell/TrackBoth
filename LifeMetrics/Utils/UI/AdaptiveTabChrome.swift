import SwiftUI

// MARK: - Adaptive tab chrome
/// FAB in portrait / iPad sidebar; toolbar "+" in compact landscape to preserve vertical space.
extension View {
    @ViewBuilder
    func adaptiveAddButton(
        isEmpty: Bool = false,
        label: String = "Add",
        action: @escaping () -> Void
    ) -> some View {
        modifier(AdaptiveAddButtonModifier(isEmpty: isEmpty, label: label, action: action))
    }

    func adaptiveScrollInset() -> some View {
        modifier(AdaptiveScrollInsetModifier())
    }

    @ViewBuilder
    func adaptiveFloatingActionButton(action: @escaping () -> Void) -> some View {
        modifier(AdaptiveFABModifier(action: action))
    }
}

private struct AdaptiveAddButtonModifier: ViewModifier {
    @Environment(\.isCompactLandscape) private var isCompactLandscape
    let isEmpty: Bool
    let label: String
    let action: () -> Void

    func body(content: Content) -> some View {
        content.toolbar {
            if isCompactLandscape && !isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: action) {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.currentPrimary)
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.fabAddMetric)
                    .accessibilityLabel(label)
                }
            }
        }
    }
}

private struct AdaptiveScrollInsetModifier: ViewModifier {
    @Environment(\.adaptiveLayoutMode) private var layoutMode

    func body(content: Content) -> some View {
        content.padding(.bottom, TabBarLayout.scrollBottomInset(for: layoutMode))
    }
}

private struct AdaptiveFABModifier: ViewModifier {
    @Environment(\.adaptiveLayoutMode) private var layoutMode
    let action: () -> Void

    func body(content: Content) -> some View {
        switch layoutMode {
        case .compactLandscape:
            content
        case .sidebarSplit:
            content.tabBarFloatingActionButton(isLandscape: true, action: action)
        case .portrait:
            content.tabBarFloatingActionButton(isLandscape: false, action: action)
        }
    }
}
