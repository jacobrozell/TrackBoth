import SwiftUI
import SwiftData

// MARK: - Insights Pad Landscape Layout
/// iPad landscape: calendar + filter sidebar; chart and day entries in main panel.
struct InsightsPadLandscapeLayout: View {
    @Binding var selectedChartType: ChartType
    @Bindable var viewModel: HistoryViewModel
    let metrics: [Metric]
    let monthEntries: [MetricEntry]
    let chartEntries: [MetricEntry]
    let streakEntries: [MetricEntry]
    let dynamicTypeSize: DynamicTypeSize
    let totalWidth: CGFloat
    let totalHeight: CGFloat

    var body: some View {
        LandscapeSplitLayout(
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            sidebar: { sidebarPanel },
            content: { mainPanel }
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
                entries: viewModel.calendarEntries(monthEntries, metrics: metrics),
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

    private var mainPanel: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ScreenSectionHeader(title: "Trends")
                    .padding(.horizontal, 16)

                InsightsChartSection(
                    selectedChartType: $selectedChartType,
                    selectedFilter: viewModel.selectedFilter,
                    entries: chartEntries,
                    metrics: metrics,
                    minChartHeight: min(320, totalHeight * 0.38)
                )
                .padding(.horizontal, 16)

                InsightsDayEntriesSection(
                    viewModel: viewModel,
                    metrics: metrics,
                    entries: monthEntries,
                    streakEntries: streakEntries
                )
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
            .adaptiveScrollInset()
        }
    }
}
