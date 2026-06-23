import SwiftUI

// MARK: - EmptyStateView Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false
    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 56
    @ScaledMetric(relativeTo: .body) private var horizontalInset: CGFloat = 24
    
    init(
        icon: String = "plus.circle",
        title: String = "Nothing to track yet",
        subtitle: String = "Use the add button to create your first habit or vice.",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            emptyStateIcon

            Text(title)
                .h3()
                .foregroundColor(Color.currentText)

            Text(subtitle)
                .body()
                .foregroundColor(Color.currentSecondaryText)
                .multilineTextAlignment(.center)

            if let actionTitle = actionTitle, let action = action {
                Button {
                    HapticFeedback.medium()
                    action()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text(actionTitle)
                            .button()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.currentPrimary)
                    .clipShape(Capsule())
                }
                .buttonStyle(CardPressButtonStyle())
                .padding(.vertical)
            }
        }
        .trackBothEntrance(isVisible: isVisible, reduceMotion: reduceMotion)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, horizontalInset)
        .padding(.vertical)
        .onAppear { performEntrance() }
    }

    @ViewBuilder
    private var emptyStateIcon: some View {
        let iconView = Image(systemName: icon)
            .font(.system(size: iconSize))
            .foregroundColor(Color.currentSecondaryText)

        if reduceMotion {
            iconView
        } else {
            iconView.symbolEffect(.pulse, options: .repeating.speed(0.35), value: isVisible)
        }
    }

    private func performEntrance() {
        if reduceMotion {
            isVisible = true
            return
        }
        withAnimation(TrackBothMotion.spring) {
            isVisible = true
        }
    }
}

#Preview {
    EmptyStateView()
}
