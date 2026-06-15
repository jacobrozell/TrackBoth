import SwiftUI

// MARK: - MilestoneBannerView
struct MilestoneBannerView: View {
    let announcement: MilestoneAnnouncement
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: announcement.habitType == .positive ? "flame.fill" : "checkmark.shield.fill")
                .font(.title2)
                .foregroundColor(announcement.habitType == .positive ? Color.currentWarning : Color.currentSuccess)

            VStack(alignment: .leading, spacing: 4) {
                Text("Milestone reached")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.currentSecondaryText)
                Text(announcement.message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.currentText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(Color.currentSecondaryText)
                    .padding(6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss milestone")
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.currentAccent.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.currentAccent.opacity(0.25), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(announcement.message)
    }
}

#Preview {
    MilestoneBannerView(
        announcement: MilestoneAnnouncement(
            metricID: UUID(),
            metricName: "Exercise",
            habitType: .positive,
            threshold: 7
        ),
        onDismiss: {}
    )
    .padding()
}
