import SwiftUI
import SwiftData

// MARK: - Insights Compact Layout
/// iPhone + iPad portrait: segmented Calendar / Trends with shared filters.
struct InsightsCompactLayout: View {
    @Binding var mode: InsightsViewMode
    @Binding var selectedChartType: ChartType
    @Bindable var viewModel: HistoryViewModel
    let metrics: [Metric]
    let monthEntries: [MetricEntry]
    let chartEntries: [MetricEntry]
    let streakEntries: [MetricEntry]
    let dynamicTypeSize: DynamicTypeSize
    @Environment(\.deviceLayout) private var deviceLayout

    private var trendsChartMinHeight: CGFloat {
        switch deviceLayout {
        case .phoneLandscape:
            return 200
        case .padLandscape:
            return 300
        case .padPortrait:
            return 300
        case .phonePortrait:
            return 280
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("View", selection: $mode) {
                ForEach(InsightsViewMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            if !metrics.isEmpty {
                MetricFilterChipRow(
                    metrics: metrics,
                    selectedFilter: $viewModel.selectedFilter,
                    includeIndividualMetrics: true
                )
            }

            ScrollView {
                LazyVStack(spacing: 20, pinnedViews: dynamicTypeSize.usesAccessibilityLayout ? [] : [.sectionHeaders]) {
                    switch mode {
                    case .calendar:
                        calendarContent
                    case .trends:
                        trendsContent
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .adaptiveScrollInset()
            }
        }
    }

    @ViewBuilder
    private var calendarContent: some View {
        Section(header: ScreenSectionHeader(title: "Calendar")) {
            CalendarGridView(
                entries: viewModel.calendarEntries(monthEntries, metrics: metrics),
                selectedFilter: viewModel.selectedFilter,
                selectedDate: $viewModel.selectedDate,
                metrics: metrics
            )
            .padding(12)
            .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }

        InsightsDayEntriesSection(
            viewModel: viewModel,
            metrics: metrics,
            entries: monthEntries,
            streakEntries: streakEntries
        )
    }

    @ViewBuilder
    private var trendsContent: some View {
        Section(header: ScreenSectionHeader(title: "Trends")) {
            InsightsChartSection(
                selectedChartType: $selectedChartType,
                selectedFilter: viewModel.selectedFilter,
                entries: chartEntries,
                metrics: metrics,
                minChartHeight: trendsChartMinHeight
            )
            .padding(12)
            .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
