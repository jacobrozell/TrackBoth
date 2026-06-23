import SwiftUI

// MARK: - Track Dashboard Header
/// Week picker + day context for the Track tab.
struct TrackDashboardHeader: View {
    let weekDays: [Date]
    let metrics: [Metric]
    let entries: [MetricEntry]
    @Binding var selectedDate: Date
    let isToday: Bool
    let todayCompleted: Int
    let totalMetrics: Int
    let showingRowOptions: Bool
    var showsWeekCalendar: Bool = true
    let onToggleEdit: () -> Void
    let onGoToToday: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var usesRelaxedLayout: Bool {
        dynamicTypeSize.usesRelaxedListLayout
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showsWeekCalendar {
                TrackWeekCalendar(
                    days: weekDays,
                    selectedDate: selectedDate,
                    metrics: metrics,
                    entries: entries,
                    usesAccessibilityLayout: usesRelaxedLayout,
                    onSelect: { selectedDate = $0 }
                )
            }

            dayContextRow
        }
    }

    @ViewBuilder
    private var dayContextRow: some View {
        if usesRelaxedLayout {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayTitle)
                        .h3()
                        .foregroundStyle(Color.currentText)

                    Text(progressSubtitle)
                        .bodySmall()
                        .foregroundStyle(Color.currentSecondaryText)
                }

                HStack(spacing: 16) {
                    if !isToday {
                        Button("Today", action: onGoToToday)
                            .buttonSmall()
                    }

                    Button(showingRowOptions ? "Done" : "Edit", action: onToggleEdit)
                        .buttonSmall()
                }
            }
        } else {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayTitle)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.currentText)

                    Text(progressSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.currentSecondaryText)
                }

                Spacer(minLength: 12)

                if !isToday {
                    Button("Today", action: onGoToToday)
                        .font(.subheadline.weight(.medium))
                }

                Button(showingRowOptions ? "Done" : "Edit", action: onToggleEdit)
                    .font(.subheadline.weight(.medium))
            }
        }
    }

    private var dayTitle: String {
        if isToday { return "Today" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: selectedDate)
    }

    private var progressSubtitle: String {
        guard totalMetrics > 0 else { return "Add habits and vices to start logging" }
        let remaining = totalMetrics - todayCompleted
        if remaining == 0 { return "All \(totalMetrics) logged — nice work" }
        if remaining == 1 { return "\(todayCompleted) of \(totalMetrics) logged — 1 left" }
        return "\(todayCompleted) of \(totalMetrics) logged — \(remaining) left"
    }
}
