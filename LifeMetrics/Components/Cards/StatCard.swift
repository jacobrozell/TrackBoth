import SwiftUI

// MARK: - StatCard Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon with modern gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.2),
                                color.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            // Value with modern typography
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color.currentText)
                .minimumScaleFactor(0.7)
            
            // Title with improved styling
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundColor(Color.currentSecondaryText)
                .textCase(.uppercase)
                .tracking(0.8)
                .frame(height: 16)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.currentSecondaryBackground)
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.3),
                            color.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
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
