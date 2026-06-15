import SwiftUI

// MARK: - StatCard Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var compact: Bool = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.isCompactLandscape) private var isCompactLandscape

    private var iconSize: CGFloat {
        if compact && dynamicTypeSize.usesAccessibilityLayout { return 28 }
        return compact ? 36 : 48
    }
    private var verticalPadding: CGFloat { compact ? 12 : 20 }
    private var horizontalPadding: CGFloat {
        if compact && dynamicTypeSize.usesAccessibilityLayout { return 12 }
        return compact ? 8 : 16
    }
    private var contentSpacing: CGFloat { compact ? 8 : 16 }

    private var usesReadableTitleStyle: Bool {
        dynamicTypeSize.usesExpandedChrome || isCompactLandscape
    }

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
                .font(compact ? (dynamicTypeSize.usesAccessibilityLayout ? .title2 : .title3) : .title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.currentText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Group {
                if usesReadableTitleStyle {
                    Text(title)
                        .font(compact ? .caption : .subheadline)
                        .foregroundColor(Color.currentText.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(title)
                        .font(compact ? .caption2 : .caption)
                        .foregroundColor(Color.currentText.opacity(0.65))
                        .textCase(.uppercase)
                        .tracking(0.8)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: compact ? .infinity : nil)
        .padding(.vertical, dynamicTypeSize.usesAccessibilityLayout ? verticalPadding + 4 : verticalPadding)
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
