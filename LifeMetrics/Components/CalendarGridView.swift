import SwiftUI
import SwiftData

struct CalendarGridView: View {
    let entries: [Date: [MetricEntry]]
    let selectedFilter: MetricFilter
    @Binding var selectedDate: Date
    let metrics: [Metric]
    
    private let calendar = CalendarHelper.calendar
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
    
    private var currentMonth: Date {
        calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
    }
    
    private var monthDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        
        let endOfMonth = monthInterval.end
        
        // Get the calendar start date using CalendarHelper
        let startOfCalendar = CalendarHelper.calendarStartForMonth(for: currentMonth)
        
        var days: [Date] = []
        var currentDay = startOfCalendar
        
        while currentDay < endOfMonth || days.count < 42 { // 6 weeks max
            days.append(currentDay)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay
            
            if days.count >= 42 { break }
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Month header
            HStack {
                Button {
                    withAnimation {
                        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.currentPrimary)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.currentText)
                
                Spacer()
                
                Button {
                    withAnimation {
                        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.currentPrimary)
                }
            }
            .padding()
            
            // Weekday headers
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.currentSecondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(monthDays, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        entries: entries[date] ?? [],
                        selectedFilter: selectedFilter,
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        metrics: metrics
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}
