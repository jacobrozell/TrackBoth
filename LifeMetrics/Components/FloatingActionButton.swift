import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            HStack {
                Spacer()
                Button(action: {
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    action()
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
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
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = pressing
                    }
                }, perform: {})
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
        FloatingActionButton {
            print("Floating button tapped")
        }
    }
}
