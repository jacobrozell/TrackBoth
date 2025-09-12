import SwiftUI

// MARK: - DateNavigationView Component
struct DateNavigationView: View {
    @Binding var selectedDate: Date
    let canGoBack: Bool
    let isToday: Bool
    
    var body: some View {
        HStack {
            Button {
                if canGoBack {
                    let oldDate = selectedDate
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    logger.logUserAction("Previous day navigation", details: "From \(DateFormatter.dateFormatter.string(from: oldDate)) to \(DateFormatter.dateFormatter.string(from: selectedDate))")
                } else {
                    logger.debug("Cannot navigate to previous day - already at earliest date")
                }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(canGoBack ? .blue : .gray)
            }
            .disabled(!canGoBack)
            
            Spacer()
            
            Button {
                // This will be handled by parent view
            } label: {
                VStack(spacing: 2) {
                    Text(isToday ? "Today" : DateFormatter.dayFormatter.string(from: selectedDate))
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(DateFormatter.dateFormatter.string(from: selectedDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                if !isToday {
                    let oldDate = selectedDate
                    selectedDate = Date()
                    logger.logUserAction("Navigate to today", details: "From \(DateFormatter.dateFormatter.string(from: oldDate)) to today")
                } else {
                    logger.debug("Already at today's date")
                }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(isToday ? .gray : .blue)
            }
            .disabled(isToday)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

#Preview {
    DateNavigationView(
        selectedDate: .constant(Date()),
        canGoBack: true,
        isToday: false
    )
}



