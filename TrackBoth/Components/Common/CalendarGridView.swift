import SwiftUI
import SwiftData

struct CalendarGridView: View {
    let entries: [Date: [MetricEntry]]
    let selectedFilter: MetricFilter
    @Binding var selectedDate: Date
    let metrics: [Metric]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .caption) private var dayCellWidth: CGFloat = 44

    private let calendar = CalendarHelper.calendar
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()

    private var usesRelaxedCalendar: Bool {
        dynamicTypeSize.usesRelaxedListLayout
    }

    private var currentMonth: Date {
        calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
    }

    private var monthDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }

        let endOfMonth = monthInterval.end
        let startOfCalendar = CalendarHelper.calendarStartForMonth(for: currentMonth)

        var days: [Date] = []
        var currentDay = startOfCalendar

        while currentDay < endOfMonth || days.count < 42 {
            days.append(currentDay)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay

            if days.count >= 42 { break }
        }

        return days
    }

    var body: some View {
        VStack(spacing: 0) {
            monthHeader
                .padding()

            weekdayHeaderRow
                .padding(.horizontal)

            calendarGridContainer
                .padding(.horizontal)
                .padding(.bottom, usesRelaxedCalendar ? 8 : 0)
        }
        .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private var monthHeader: some View {
        if usesRelaxedCalendar {
            VStack(spacing: 12) {
                Text(dateFormatter.string(from: currentMonth))
                    .h3()
                    .foregroundColor(.currentText)
                    .frame(maxWidth: .infinity)

                HStack {
                    monthNavigationButton(systemImage: "chevron.left", label: "Previous month", monthOffset: -1)
                    Spacer()
                    monthNavigationButton(systemImage: "chevron.right", label: "Next month", monthOffset: 1)
                }
            }
        } else {
            HStack {
                monthNavigationButton(systemImage: "chevron.left", label: "Previous month", monthOffset: -1)

                Spacer()

                Text(dateFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.currentText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                monthNavigationButton(systemImage: "chevron.right", label: "Next month", monthOffset: 1)
            }
        }
    }

    private func monthNavigationButton(systemImage: String, label: String, monthOffset: Int) -> some View {
        Button {
            withAnimation {
                selectedDate = calendar.date(byAdding: .month, value: monthOffset, to: selectedDate) ?? selectedDate
            }
        } label: {
            Image(systemName: systemImage)
                .foregroundColor(.currentPrimary)
                .frame(minWidth: 44, minHeight: 44)
        }
        .accessibilityLabel(label)
    }

    private var weekdayHeaderRow: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.currentSecondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var calendarGridContainer: some View {
        if usesRelaxedCalendar {
            ScrollView(.horizontal, showsIndicators: false) {
                calendarGrid
                    .frame(width: dayCellWidth * 7 + 6 * 4)
            }
        } else {
            calendarGrid
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(usesRelaxedCalendar ? .fixed(dayCellWidth) : .flexible(), spacing: 4),
                count: 7
            ),
            spacing: usesRelaxedCalendar ? 8 : 4
        ) {
            ForEach(monthDays, id: \.self) { date in
                CalendarDayView(
                    date: date,
                    entries: entries[date] ?? [],
                    selectedFilter: selectedFilter,
                    isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    metrics: metrics,
                        onSelect: {
                            HapticFeedback.selection()
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedDate = calendar.startOfDay(for: date)
                            }
                        }
                )
            }
        }
    }

    private var weekdaySymbols: [String] {
        CalendarHelper.calendar.shortWeekdaySymbols
    }
}
