import SwiftUI

// MARK: - MilestoneBannerView
struct MilestoneBannerView: View {
    let announcement: MilestoneAnnouncement
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    private var iconName: String {
        announcement.habitType == .positive ? "flame.fill" : "checkmark.shield.fill"
    }

    private var iconColor: Color {
        announcement.habitType == .positive ? Color.currentWarning : Color.currentSuccess
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            milestoneIcon

            VStack(alignment: .leading, spacing: 4) {
                Text("Milestone reached")
                    .caption()
                    .foregroundColor(Color.currentSecondaryText)
                Text(announcement.message)
                    .bodyMedium()
                    .foregroundColor(Color.currentText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Button(action: dismiss) {
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
                .fill(Color.currentAccent.opacity(isVisible ? 0.12 : 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.currentAccent.opacity(isVisible ? 0.25 : 0.15), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (isVisible ? 0 : -16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(announcement.message)
        .onAppear {
            performEntrance()
            HapticFeedback.success()
        }
    }

    @ViewBuilder
    private var milestoneIcon: some View {
        let icon = Image(systemName: iconName)
            .font(.title2)
            .foregroundColor(iconColor)

        if reduceMotion {
            icon
        } else {
            icon.symbolEffect(.bounce, value: isVisible)
        }
    }

    private func performEntrance() {
        if reduceMotion {
            isVisible = true
            return
        }
        withAnimation(TrackBothMotion.celebrationSpring) {
            isVisible = true
        }
    }

    private func dismiss() {
        HapticFeedback.light()
        if reduceMotion {
            onDismiss()
            return
        }
        withAnimation(TrackBothMotion.quick) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            onDismiss()
        }
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
