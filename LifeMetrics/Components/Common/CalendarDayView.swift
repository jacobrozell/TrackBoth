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
    
    private var hasEntry: Bool {
        switch selectedFilter {
        case .all:
            return entries.contains { entry in
                entry.hasContent && (entry.value || entry.hasQuantity)
            }
        case .allHabits, .allVices:
            return entries.contains { entry in
                entry.hasContent && (entry.value || entry.hasQuantity)
            }
        case .specific(let metric):
            return entries.contains { entry in
                entry.metricID == metric.id && entry.hasContent && (entry.value || entry.hasQuantity)
            }
        }
    }
    
    private var entryWithDetails: MetricEntry? {
        switch selectedFilter {
        case .all:
            return entries.first { entry in
                (entry.value || entry.hasQuantity) && 
                ((entry.details != nil && !entry.details!.isEmpty) || entry.hasQuantity)
            }
        case .allHabits, .allVices:
            return entries.first { entry in
                (entry.value || entry.hasQuantity) && 
                ((entry.details != nil && !entry.details!.isEmpty) || entry.hasQuantity)
            }
        case .specific(let metric):
            return entries.first { entry in
                entry.metricID == metric.id && 
                (entry.value || entry.hasQuantity) && 
                ((entry.details != nil && !entry.details!.isEmpty) || entry.hasQuantity)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(dayNumber)
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isCurrentMonth ? Color.currentText : Color.currentSecondaryText)
            
            if hasEntry {
                // Show appropriate color based on entry type and metric type
                let entry = entries.first { entry in
                    entry.hasContent && (entry.value || entry.hasQuantity)
                }
                
                if let entry = entry, let metric = getMetric(for: entry) {
                    // Focus on boolean status - if they did it (value = true), show success color
                    if entry.value {
                        Circle()
                            .fill(metric.habitType == .positive ? Color.currentSuccess : Color.currentError)
                            .frame(width: 6, height: 6)
                    } else {
                        // For failed entries
                        Circle()
                            .fill(metric.habitType == .positive ? Color.currentError : Color.currentSuccess)
                            .frame(width: 6, height: 6)
                    }
                } else {
                    // Fallback
                    Circle()
                        .fill(Color.currentSuccess)
                        .frame(width: 6, height: 6)
                }
            } else if !entries.isEmpty {
                // Show red for entries that exist but don't meet hasEntry criteria
                Circle()
                    .fill(Color.currentError)
                    .frame(width: 6, height: 6)
            }
            
            // Show details or quantity if available
            if let entry = entryWithDetails {
                if let details = entry.details, !details.isEmpty {
                    Text(details)
                        .font(.caption2)
                        .foregroundColor(Color.currentSecondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 2)
                } else if let quantityString = entry.quantityString {
                    Text(quantityString)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(Color.currentSecondaryText)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 2)
                }
            }
        }
        .frame(minHeight: 40)
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
