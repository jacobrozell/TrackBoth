import SwiftUI

// MARK: - Weekly Date Navigation Component
struct WeeklyDateNavigationView: View {
    @Binding var selectedDate: Date
    let canGoBack: Bool
    let canGoForward: Bool
    let isCurrentWeek: Bool
    
    var body: some View {
        HStack {
            Button {
                if canGoBack {
                    selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(canGoBack ? .currentPrimary : .currentSecondaryText)
            }
            .disabled(!canGoBack)
            
            Spacer()
            
            Button {
                // This will be handled by parent view
            } label: {
                VStack(spacing: 2) {
                    Text(weekDisplayText)
                        .font(.headline)
                        .foregroundColor(.currentText)
                    Text(weekRangeText)
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                }
            }
            
            Spacer()
            
            Button {
                if canGoForward {
                    selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(canGoForward ? .currentPrimary : .currentSecondaryText)
            }
            .disabled(!canGoForward)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var weekDisplayText: String {
        if isCurrentWeek {
            return "This Week"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let startOfWeek = CalendarHelper.startOfWeek(for: selectedDate)
            return formatter.string(from: startOfWeek)
        }
    }
    
    private var weekRangeText: String {
        let startOfWeek = CalendarHelper.startOfWeek(for: selectedDate)
        let endOfWeek = CalendarHelper.endOfWeek(for: selectedDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
}