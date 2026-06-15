import SwiftUI

// MARK: - FilterButton Component
struct FilterButton: View {
    let filter: MetricFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = filter.icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(filter.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.currentAccent : Color.currentSecondaryText.opacity(0.2))
            .foregroundColor(isSelected ? .white : Color.currentText)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    HStack {
        FilterButton(
            filter: .all,
            isSelected: true
        ) {
            // Action
        }
        
        FilterButton(
            filter: .allHabits,
            isSelected: false
        ) {
            // Action
        }
    }
    .padding()
}
