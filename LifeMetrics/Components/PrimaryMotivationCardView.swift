import SwiftUI

struct PrimaryMotivationCardView: View {
    let metric: Metric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with better spacing
            HStack(alignment: .top, spacing: 12) {
                // Metric info with improved layout
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: metric.safeHabitType.icon)
                            .foregroundColor(.red)
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 20)
                        
                        Text(metric.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // Star indicator for primary motivation
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                            .shadow(color: .yellow.opacity(0.3), radius: 2)
                    }
                    
                    Text("Primary Motivation")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.leading, 28) // Align with metric name
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Primary motivation text with better typography
            Text(metric.primaryMotivation ?? "")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            
            // Bottom accent with yellow for primary motivations
            Rectangle()
                .fill(Color.yellow.opacity(0.4))
                .frame(height: 4)
                .cornerRadius(2)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color.yellow.opacity(0.15), Color.yellow.opacity(0.05)], startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow.opacity(0.4), lineWidth: 2)
        )
        .shadow(
            color: .yellow.opacity(0.2), 
            radius: 12, 
            x: 0, 
            y: 4
        )
    }
}
