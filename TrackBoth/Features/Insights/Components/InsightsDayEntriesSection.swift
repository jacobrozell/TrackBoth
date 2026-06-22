import SwiftUI
import SwiftData

// MARK: - Insights Day Entries Section
struct InsightsDayEntriesSection: View {
    @Bindable var viewModel: HistoryViewModel
    let metrics: [Metric]
    let entries: [MetricEntry]
    let streakEntries: [MetricEntry]

    var body: some View {
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
