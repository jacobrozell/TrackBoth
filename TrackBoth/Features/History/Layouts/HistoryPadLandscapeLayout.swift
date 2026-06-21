import SwiftUI
import SwiftData

// MARK: - History Pad Landscape Layout
/// iPad landscape split: filters + calendar sidebar, entry list main panel.
struct HistoryPadLandscapeLayout: View {
    @Bindable var viewModel: HistoryViewModel
    let metrics: [Metric]
    let entries: [MetricEntry]
    let streakEntries: [MetricEntry]
    let dynamicTypeSize: DynamicTypeSize
    let totalWidth: CGFloat
    let totalHeight: CGFloat

    var body: some View {
        LandscapeSplitLayout(
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            sidebar: { sidebarPanel },
            content: { contentPanel }
        )
    }

    private var sidebarPanel: some View {
        VStack(spacing: 12) {
            ScreenSectionHeader(title: "Filter")
            MetricFilterSidebar(
                title: "",
                metrics: metrics,
                selectedFilter: $viewModel.selectedFilter,
                includeIndividualMetrics: true
            )

            ScreenSectionHeader(title: "Calendar")
            CalendarGridView(
                entries: viewModel.calendarEntries(entries, metrics: metrics),
                selectedFilter: viewModel.selectedFilter,
                selectedDate: $viewModel.selectedDate,
                metrics: metrics
            )
            .padding(12)
            .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            Spacer(minLength: 0)
        }
        .padding()
    }

    private var contentPanel: some View {
        let recentEntries = viewModel.recentEntries(entries, metrics: metrics)

        return ScrollView {
            LazyVStack(spacing: 12) {
                ScreenSectionHeader(
                    title: "Recent",
                    trailing: recentEntries.isEmpty ? nil : "\(min(recentEntries.count, 20))"
                )
                .padding(.horizontal, 16)

                if recentEntries.isEmpty {
                    Text("No entries for this filter yet.")
                        .font(.subheadline)
                        .foregroundStyle(Color.currentSecondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                } else {
                    ForEach(recentEntries.prefix(20)) { entry in
                        HistoryEntryCardView(entry: entry, metrics: metrics, entries: streakEntries)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 8)
            .adaptiveScrollInset()
        }
    }
}
