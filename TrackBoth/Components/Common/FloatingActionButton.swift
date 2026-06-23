import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            logger.logUserAction("Floating action button tapped")
            HapticFeedback.medium()
            action()
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.currentPrimary, Color.currentPrimary.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(
                    color: .black.opacity(0.3),
                    radius: isPressed ? 4 : 8,
                    x: 0,
                    y: isPressed ? 2 : 4
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(TrackBothMotion.quick) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityIdentifier(AccessibilityIdentifiers.fabAddMetric)
        .accessibilityLabel("Add")
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
        FloatingActionButton {
            logger.logUserAction("Floating action button tapped (preview)")
        }
    }
}
