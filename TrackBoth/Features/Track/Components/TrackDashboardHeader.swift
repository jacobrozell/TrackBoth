import SwiftUI

// MARK: - Track Dashboard Header
/// Week picker + day context for the Track tab.
struct TrackDashboardHeader: View {
    let weekDays: [Date]
    @Binding var selectedDate: Date
    let isToday: Bool
    let todayCompleted: Int
    let totalMetrics: Int
    let showingRowOptions: Bool
    let usesAccessibilityLayout: Bool
    var showsWeekCalendar: Bool = true
    let onToggleEdit: () -> Void
    let onGoToToday: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showsWeekCalendar {
                TrackWeekCalendar(
                    days: weekDays,
                    selectedDate: selectedDate,
                    usesAccessibilityLayout: usesAccessibilityLayout,
                    onSelect: { selectedDate = $0 }
                )
            }

            dayContextRow
        }
    }

    private var dayContextRow: some View {
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

    private var dayTitle: String {
        if isToday { return "Today" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: selectedDate)
    }

    private var progressSubtitle: String {
        guard totalMetrics > 0 else { return "Add habits and vices to start logging" }
        return "\(todayCompleted) of \(totalMetrics) logged"
    }
}
