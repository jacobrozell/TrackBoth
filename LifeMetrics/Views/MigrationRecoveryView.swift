import SwiftUI

// MARK: - Migration Recovery View
/// Shown when the app had to fall back to an in-memory store after a persistent store failure.
struct MigrationRecoveryView: View {
    let onExportTapped: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.currentWarning)
                Text("Couldn't load saved data")
                    .font(.headline)
                    .foregroundColor(.currentText)
            }

            Text("TrackBoth is running with temporary in-memory storage. Export your previous backup if you have one, or continue and add habits again.")
                .font(.subheadline)
                .foregroundColor(.currentSecondaryText)

            HStack {
                Button("Export Backup") { onExportTapped() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.currentPrimary)

                Spacer()

                Button("Dismiss") { onDismiss() }
                    .font(.subheadline)
                    .foregroundColor(.currentSecondaryText)
            }
        }
        .padding(16)
        .background(Color.currentSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .accessibilityIdentifier(AccessibilityIdentifiers.migrationRecoveryBanner)
    }
}
