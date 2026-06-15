import SwiftUI

// MARK: - StatCard Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var compact: Bool = false

    private var iconSize: CGFloat { compact ? 36 : 48 }
    private var verticalPadding: CGFloat { compact ? 12 : 20 }
    private var horizontalPadding: CGFloat { compact ? 8 : 16 }
    private var contentSpacing: CGFloat { compact ? 8 : 16 }

    var body: some View {
        VStack(spacing: contentSpacing) {
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
                    .frame(width: iconSize, height: iconSize)

                Image(systemName: icon)
                    .font(compact ? .body : .title2)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }

            Text(value)
                .font(compact ? AppTypography.h3 : AppTypography.h2)
                .foregroundColor(Color.currentText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(title)
                .captionSmall()
                .foregroundColor(Color.currentText.opacity(0.65))
                .textCase(.uppercase)
                .tracking(0.8)
                .frame(height: 16)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(maxWidth: compact ? nil : .infinity)
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
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
