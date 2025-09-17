import SwiftUI

// MARK: - Reusable View Modifiers

/// Card-style modifier for consistent card appearance
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.currentBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Section-style modifier for consistent section appearance
struct SectionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.currentSecondaryBackground)
            .cornerRadius(12)
    }
}

/// Empty state modifier for consistent empty state appearance
struct EmptyStateModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Button style for primary actions
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
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
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.currentSecondaryBackground)
            .foregroundColor(Color.currentText)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - View Extensions for Easy Access
extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    func sectionStyle() -> some View {
        modifier(SectionModifier())
    }
    
    func emptyStateStyle() -> some View {
        modifier(EmptyStateModifier())
    }
}
