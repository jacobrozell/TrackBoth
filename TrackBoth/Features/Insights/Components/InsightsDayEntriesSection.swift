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
                emptyDayContent
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(dayEntries) { entry in
                        HistoryEntryCardView(entry: entry, metrics: metrics, entries: streakEntries)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var emptyDayContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(emptyDayMessage)
                .bodySmall()
                .foregroundStyle(Color.currentSecondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            if CalendarHelper.isToday(viewModel.selectedDate) {
                Button {
                    HapticFeedback.medium()
                    AppEvent.post(.switchToTrack)
                } label: {
                    Label("Go to Track", systemImage: "checkmark.circle.fill")
                        .button()
                }
                .buttonStyle(CardPressButtonStyle())
                .foregroundStyle(Color.currentPrimary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
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
