import SwiftUI

// MARK: - History Compact Layout
/// Single-column history for iPhone and iPad portrait.
struct HistoryCompactLayout: View {
    @Bindable var viewModel: HistoryViewModel
    let metrics: [Metric]
    let entries: [MetricEntry]
    let streakEntries: [MetricEntry]
    let dynamicTypeSize: DynamicTypeSize

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                if !metrics.isEmpty {
                    MetricFilterChipRow(
                        metrics: metrics,
                        selectedFilter: $viewModel.selectedFilter,
                        includeIndividualMetrics: true,
                        usesBarBackground: false
                    )
                }

                Section(header: ScreenSectionHeader(title: "Calendar")) {
                    CalendarGridView(
                        entries: viewModel.calendarEntries(entries, metrics: metrics),
                        selectedFilter: viewModel.selectedFilter,
                        selectedDate: $viewModel.selectedDate,
                        metrics: metrics
                    )
                    .padding(12)
                    .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                recentEntriesSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .adaptiveScrollInset()
        }
    }

    @ViewBuilder
    private var recentEntriesSection: some View {
        let recentEntries = viewModel.recentEntries(entries, metrics: metrics)
        if !recentEntries.isEmpty {
            Section(header: ScreenSectionHeader(
                title: "Recent",
                trailing: "\(min(recentEntries.count, 20))"
            )) {
                LazyVStack(spacing: 8) {
                    ForEach(recentEntries.prefix(20)) { entry in
                        HistoryEntryCardView(entry: entry, metrics: metrics, entries: streakEntries)
                    }
                }
            }
        }
    }
}
