import SwiftUI

struct MetricChipStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bodyMedium()
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isSelected ? 
                        LinearGradient(colors: [Color.currentAccent, Color.currentAccent.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [Color.currentSecondaryBackground, Color.currentSecondaryBackground.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )
            )
            .foregroundColor(isSelected ? .white : Color.currentText)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isSelected ? Color.clear : Color.currentSecondaryText.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .shadow(
                color: isSelected ? Color.currentAccent.opacity(0.3) : .clear, 
                radius: isSelected ? 8 : 0, 
                x: 0, 
                y: isSelected ? 4 : 0
            )
    }
}

// MARK: - Reactive Filter Button
/// A reactive filter button that automatically updates when themes change
struct ReactiveFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(dynamicTypeSize.usesAccessibilityLayout ? .subheadline : .body)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .padding(.horizontal, dynamicTypeSize.usesAccessibilityLayout ? 16 : 20)
                .padding(.vertical, dynamicTypeSize.usesAccessibilityLayout ? 10 : 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isSelected ? 
                            LinearGradient(colors: [Color.currentAccent, Color.currentAccent.opacity(0.8)], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [Color.currentSecondaryBackground, Color.currentSecondaryBackground.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                        )
                )
                .foregroundColor(isSelected ? .white : Color.currentText)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(isSelected ? Color.clear : Color.currentSecondaryText.opacity(0.3), lineWidth: 1)
                )
                .shadow(
                    color: isSelected ? Color.currentAccent.opacity(0.3) : .clear, 
                    radius: isSelected ? 8 : 0, 
                    x: 0, 
                    y: isSelected ? 4 : 0
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.0 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
