import SwiftUI

// MARK: - Track Week Calendar
struct TrackWeekCalendar: View {
    let days: [Date]
    let selectedDate: Date
    let metrics: [Metric]
    let entries: [MetricEntry]
    let usesAccessibilityLayout: Bool
    let onSelect: (Date) -> Void

    @ScaledMetric(relativeTo: .caption) private var dayBadgeSize: CGFloat = 34

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var usesRelaxedLayout: Bool {
        dynamicTypeSize.usesRelaxedListLayout
    }

    var body: some View {
        Group {
            if usesRelaxedLayout {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(days, id: \.self) { day in
                            dayCell(for: day)
                                .frame(minWidth: dayBadgeSize + 20)
                        }
                    }
                }
            } else {
                HStack(spacing: 4) {
                    ForEach(days, id: \.self) { day in
                        dayCell(for: day)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(for day: Date) -> some View {
        let isSelected = CalendarHelper.isSameDay(day, selectedDate)
        let isToday = CalendarHelper.isToday(day)
        let completion = DayLogSummary.completionState(metrics: metrics, entries: entries, on: day)

        Button {
            HapticFeedback.selection()
            onSelect(day)
        } label: {
            VStack(spacing: 4) {
                Text(weekdayLabel(for: day))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? Color.currentPrimary : Color.currentSecondaryText)

                Text(dayNumber(for: day))
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .monospacedDigit()
                    .foregroundStyle(isSelected ? Color.white : Color.currentText)
                    .frame(width: dayBadgeSize, height: dayBadgeSize)
                    .background {
                        Circle()
                            .fill(isSelected ? Color.currentPrimary : (isToday ? Color.currentPrimary.opacity(0.12) : Color.clear))
                    }

                completionDot(for: completion, isSelected: isSelected)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel(for: day, isSelected: isSelected, completion: completion))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func completionDot(for completion: DayLogCompletionState, isSelected: Bool) -> some View {
        Circle()
            .fill(dotColor(for: completion, isSelected: isSelected))
            .frame(width: 5, height: 5)
            .opacity(completion == .none ? 0 : 1)
            .accessibilityHidden(true)
    }

    private func dotColor(for completion: DayLogCompletionState, isSelected: Bool) -> Color {
        switch completion {
        case .none:
            return .clear
        case .partial:
            return isSelected ? Color.white.opacity(0.85) : Color.currentWarning
        case .complete:
            return isSelected ? Color.white : Color.currentSuccess
        }
    }

    private func weekdayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = usesRelaxedLayout ? "EEEEE" : "EEE"
        return formatter.string(from: date)
    }

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func accessibilityLabel(
        for date: Date,
        isSelected: Bool,
        completion: DayLogCompletionState
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        let prefix = isSelected ? "Selected, " : ""
        let completionLabel: String
        switch completion {
        case .none: completionLabel = "nothing logged"
        case .partial: completionLabel = "partially logged"
        case .complete: completionLabel = "fully logged"
        }
        return "\(prefix)\(formatter.string(from: date)), \(completionLabel)"
    }
}
