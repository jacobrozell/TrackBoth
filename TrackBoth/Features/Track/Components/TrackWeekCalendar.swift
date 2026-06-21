import SwiftUI

// MARK: - Track Week Calendar
struct TrackWeekCalendar: View {
    let days: [Date]
    let selectedDate: Date
    let usesAccessibilityLayout: Bool
    let onSelect: (Date) -> Void

    @ScaledMetric(relativeTo: .caption) private var dayBadgeSize: CGFloat = 34

    var body: some View {
        Group {
            if usesAccessibilityLayout {
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
        let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(day)

        Button {
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
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel(for: day, isSelected: isSelected))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func weekdayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = usesAccessibilityLayout ? "EEEEE" : "EEE"
        return formatter.string(from: date)
    }

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func accessibilityLabel(for date: Date, isSelected: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        let prefix = isSelected ? "Selected, " : ""
        return "\(prefix)\(formatter.string(from: date))"
    }
}
