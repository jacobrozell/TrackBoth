import SwiftUI

// MARK: - StatCard Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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
