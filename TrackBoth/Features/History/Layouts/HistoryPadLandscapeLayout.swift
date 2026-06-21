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
        let dayEntries = viewModel.dayEntries(entries, metrics: metrics)

        return ScrollView {
            LazyVStack(spacing: 12) {
                ScreenSectionHeader(
                    title: viewModel.selectedDaySectionTitle(),
                    trailing: dayEntries.isEmpty ? nil : (dayEntries.count == 1 ? "1 entry" : "\(dayEntries.count) entries")
                )
                .padding(.horizontal, 16)

                if dayEntries.isEmpty {
                    Text(emptyDayMessage)
                        .font(.subheadline)
                        .foregroundStyle(Color.currentSecondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                } else {
                    ForEach(dayEntries) { entry in
                        HistoryEntryCardView(entry: entry, metrics: metrics, entries: streakEntries)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 8)
            .adaptiveScrollInset()
        }
    }

    private var emptyDayMessage: String {
        if CalendarHelper.isToday(viewModel.selectedDate) {
            return "Nothing logged yet today. Switch to Track to log your habits and vices."
        }
        return "No entries on this day for the current filter."
    }
}
