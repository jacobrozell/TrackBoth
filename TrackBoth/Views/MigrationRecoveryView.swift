import SwiftUI

// MARK: - Migration Recovery View
/// Shown when the app had to fall back to an in-memory store after a persistent store failure.
struct MigrationRecoveryView: View {
    let onExportTapped: () -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.currentWarning)
                Text("Couldn't load saved data")
                    .h4()
                    .foregroundColor(.currentText)
            }

            Text("TrackBoth is running with temporary in-memory storage. Your data will not be saved until you restart the app after fixing the issue. Export a backup if you have one, or continue and add habits again.")
                .bodySmall()
                .foregroundColor(.currentSecondaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button("Export Backup") {
                    HapticFeedback.medium()
                    onExportTapped()
                }
                .buttonSmall()
                .foregroundColor(.currentPrimary)

                Spacer()

                Button("Continue Anyway") {
                    HapticFeedback.light()
                    onDismiss()
                }
                .bodySmall()
                .foregroundColor(.currentSecondaryText)
            }
        }
        .padding(16)
        .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.currentWarning.opacity(isVisible ? 0.35 : 0.2), lineWidth: 1)
        }
        .trackBothEntrance(isVisible: isVisible, reduceMotion: reduceMotion)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Couldn't load saved data. Running with temporary storage. Export a backup or continue.")
        .accessibilityIdentifier(AccessibilityIdentifiers.migrationRecoveryBanner)
        .onAppear { performEntrance() }
    }

    private func performEntrance() {
        HapticFeedback.warning()
        if reduceMotion {
            isVisible = true
            return
        }
        withAnimation(TrackBothMotion.spring) {
            isVisible = true
        }
    }
}
