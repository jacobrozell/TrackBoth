import SwiftUI

// MARK: - EmptyStateView Component
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "plus.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No habits yet")
                .font(.title2)
                .fontWeight(.medium)

            Text("Tap the + button below to add your first habit")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView()
}
