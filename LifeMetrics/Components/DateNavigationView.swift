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
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
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
                    selectedDate = Date()
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



