import SwiftUI
import SwiftData

struct CalendarDayView: View {
    let date: Date
    let entries: [MetricEntry]
    let selectedFilter: MetricFilter
    let isCurrentMonth: Bool
    let metrics: [Metric]

    private var dayNumber: String {
        Calendar.current.component(.day, from: date).description
    }

    private var isToday: Bool {
        CalendarHelper.isToday(date)
    }

    private func getMetric(for entry: MetricEntry) -> Metric? {
        metrics.first { $0.id == entry.metricID }
    }

    private var filteredEntries: [MetricEntry] {
        entries.filter { FilterUtils.matchesFilter(selectedFilter, entry: $0, metrics: metrics) }
    }

    private var displayEntry: MetricEntry? {
        if let successful = FilterUtils.successfulEntries(selectedFilter, entries: filteredEntries, metrics: metrics).first {
            return successful
        }
        return filteredEntries.first { entry in
            TrackingSemantics.isLoggedForDay(entry: entry) || entry.hasQuantity
        }
    }

    private var hasEntry: Bool {
        displayEntry != nil
    }

    private func dotColor(for entry: MetricEntry, metric: Metric) -> Color {
        if entry.hasQuantity, TrackingSemantics.isLoggedForDay(entry: entry) {
            return .currentPrimary
        }
        if TrackingSemantics.isLoggedSuccess(habitType: metric.habitType, entry: entry) {
            return .currentSuccess
        }
        if TrackingSemantics.isLoggedForDay(entry: entry) {
            return .currentError
        }
        return .currentSecondaryText
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(dayNumber)
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isCurrentMonth ? Color.currentText : Color.currentSecondaryText)

            if let entry = displayEntry, let metric = getMetric(for: entry) {
                Circle()
                    .fill(dotColor(for: entry, metric: metric))
                    .frame(width: 6, height: 6)
            } else if !filteredEntries.isEmpty {
                Circle()
                    .fill(Color.currentSecondaryText.opacity(0.4))
                    .frame(width: 6, height: 6)
            }

        }
        .frame(minHeight: 36)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? Color.currentAccent.opacity(0.2) : Color.clear)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(calendarAccessibilityLabel)
        .accessibilityAddTraits(isToday ? .isSelected : [])
    }

    private var calendarAccessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateText = formatter.string(from: date)
        if isToday { return "Today, \(dateText), \(hasEntry ? "has entries" : "no entries")" }
        return "\(dateText), \(hasEntry ? "has entries" : "no entries")"
    }
}
