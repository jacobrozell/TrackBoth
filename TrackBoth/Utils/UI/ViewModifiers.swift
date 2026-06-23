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
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(TrackBothMotion.quick, value: configuration.isPressed)
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
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(TrackBothMotion.quick, value: configuration.isPressed)
    }
}

// MARK: - Metric Card Style
struct MetricCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

/// Subtle press feedback for navigation cards and pill CTAs.
struct CardPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(TrackBothMotion.quick, value: configuration.isPressed)
    }
}

extension View {
    func metricCardStyle() -> some View {
        modifier(MetricCardModifier())
    }

    /// Exposes a spoken chart summary; hides decorative chart marks from VoiceOver.
    func chartVoiceOverSummary(_ summary: String) -> some View {
        accessibilityElement(children: .ignore)
            .accessibilityLabel(summary)
    }
}
