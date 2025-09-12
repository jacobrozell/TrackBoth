import SwiftUI

// MARK: - StatCard Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with background circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            // Value with emphasis
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
            
            // Title
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    HStack(spacing: 20) {
        StatCard(
            title: "Habits",
            value: "5",
            icon: "checkmark.circle.fill",
            color: .green
        )
        
        StatCard(
            title: "Vices",
            value: "2",
            icon: "xmark.circle.fill",
            color: .red
        )
    }
    .padding()
}
