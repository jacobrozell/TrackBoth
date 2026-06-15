import SwiftUI

// MARK: - EmptyStateView Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String = "plus.circle",
        title: String = "No habits yet",
        subtitle: String = "Tap the + button below to add your first habit",
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
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Color.currentSecondaryText)

            Text(title)
                .h3()
                .foregroundColor(Color.currentText)

            Text(subtitle)
                .body()
                .foregroundColor(Color.currentSecondaryText)
                .multilineTextAlignment(.center)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text(actionTitle)
                            .button()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.currentPrimary)
                    .cornerRadius(25)
                }
                .padding(.vertical)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical)
    }
}

#Preview {
    EmptyStateView()
}
