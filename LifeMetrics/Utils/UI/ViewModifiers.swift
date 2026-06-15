import SwiftUI

// MARK: - Reusable View Modifiers

/// Button style for primary actions
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .button()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.currentPrimary)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

/// Button style for secondary actions
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .button()
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.currentSecondaryBackground)
            .foregroundColor(Color.currentText)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Metric Card Style
struct MetricCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.currentSecondaryBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func metricCardStyle() -> some View {
        modifier(MetricCardModifier())
    }
}
