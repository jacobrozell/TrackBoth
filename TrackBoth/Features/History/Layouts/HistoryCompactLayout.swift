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

                dayEntriesSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .adaptiveScrollInset()
        }
    }

    @ViewBuilder
    private var dayEntriesSection: some View {
        let dayEntries = viewModel.dayEntries(entries, metrics: metrics)
        Section(header: ScreenSectionHeader(
            title: viewModel.selectedDaySectionTitle(),
            trailing: dayEntries.isEmpty ? nil : entryCountLabel(dayEntries.count)
        )) {
            if dayEntries.isEmpty {
                Text(emptyDayMessage)
                    .font(.subheadline)
                    .foregroundStyle(Color.currentSecondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(dayEntries) { entry in
                        HistoryEntryCardView(entry: entry, metrics: metrics, entries: streakEntries)
                    }
                }
            }
        }
    }

    private var emptyDayMessage: String {
        if CalendarHelper.isToday(viewModel.selectedDate) {
            return "Nothing logged yet today. Switch to Track to log your habits and vices."
        }
        return "No entries on this day for the current filter."
    }

    private func entryCountLabel(_ count: Int) -> String {
        count == 1 ? "1 entry" : "\(count) entries"
    }
}
