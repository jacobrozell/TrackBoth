import SwiftUI

// MARK: - Metric Tab Shell
/// Shared navigation + geometry wrapper for metric tabs.
struct MetricTabShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: (GeometryProxy?, Bool) -> Content

    @Environment(\.adaptiveLayoutMode) private var layoutMode

    var body: some View {
        NavigationStack {
            Group {
                if layoutMode == .sidebarSplit {
                    GeometryReader { geometry in
                        content(geometry, true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                } else {
                    content(nil, false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .themedBackground()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.currentBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Filtered Split Tab Layout
/// Portrait chip row or landscape sidebar filter with shared main content.
struct FilteredSplitTabLayout<Content: View>: View {
    let geometry: GeometryProxy?
    let usesSplit: Bool
    let filterMetrics: [Metric]
    @Binding var selectedFilter: MetricFilter
    var sidebarTitle: String = "Filter by Habit"
    var includeIndividualMetrics: Bool = true
    var landscapeFABAction: (() -> Void)? = nil
    var portraitFABAction: (() -> Void)? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        if usesSplit, let geometry {
            LandscapeSplitLayout(
                totalWidth: geometry.size.width,
                totalHeight: geometry.size.height,
                sidebar: { sidebar },
                content: { content() }
            )
            .modifier(LandscapeFABModifier(action: landscapeFABAction))
        } else {
            VStack(spacing: 0) {
                if !filterMetrics.isEmpty {
                    MetricFilterChipRow(
                        metrics: filterMetrics,
                        selectedFilter: $selectedFilter,
                        includeIndividualMetrics: includeIndividualMetrics
                    )
                }
                content()
            }
            .modifier(PortraitFABModifier(action: portraitFABAction))
        }
    }

    private var sidebar: some View {
        VStack(spacing: 12) {
            MetricFilterSidebar(
                title: sidebarTitle,
                metrics: filterMetrics,
                selectedFilter: $selectedFilter,
                includeIndividualMetrics: includeIndividualMetrics
            )
            Spacer(minLength: 0)
        }
        .padding()
    }
}

private struct LandscapeFABModifier: ViewModifier {
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        if let action {
            content.tabBarFloatingActionButton(isLandscape: true, action: action)
        } else {
            content
        }
    }
}

private struct PortraitFABModifier: ViewModifier {
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        if let action {
            content.adaptiveFloatingActionButton(action: action)
        } else {
            content
        }
    }
}
