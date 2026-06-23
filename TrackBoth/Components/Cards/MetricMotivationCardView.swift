import SwiftUI

// MARK: - Metric Motivation Summary Card
/// List row preview — tap to open primary motivation and all logged notes.
struct MetricMotivationCardView: View {
    let metric: Metric
    let loggedCount: Int

    private var trimmedPrimary: String? {
        guard let text = metric.primaryMotivation?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return nil }
        return text
    }

    private var accentColor: Color {
        metric.habitType == .vice ? Color.currentWarning : Color.currentSuccess
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: metric.habitType.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(accentColor)
                .frame(width: 32, height: 32)
                .background(accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(metric.name)
                        .h4()
                        .foregroundStyle(Color.currentText)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.currentSecondaryText)
                }

                if let primary = trimmedPrimary {
                    Text(primary)
                        .bodySmall()
                        .foregroundStyle(Color.currentSecondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(emptyPrimaryPreview)
                        .bodySmall()
                        .foregroundStyle(Color.currentSecondaryText)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    Label(primaryBadgeLabel, systemImage: trimmedPrimary == nil ? "pin.slash" : "pin.fill")
                        .caption()
                        .foregroundStyle(trimmedPrimary == nil ? Color.currentSecondaryText : accentColor)

                    if loggedCount > 0 {
                        Text(loggedCountLabel)
                            .caption()
                            .foregroundStyle(Color.currentSecondaryText)
                    }
                }
            }
        }
        .padding(16)
        .metricCardStyle()
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(accentColor.opacity(0.85))
                .frame(width: 4)
                .padding(.vertical, 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Opens primary motivation and logged motivations")
    }

    private var emptyPrimaryPreview: String {
        metric.habitType == .vice
            ? "Set your primary motivation"
            : "Optional primary motivation"
    }

    private var primaryBadgeLabel: String {
        trimmedPrimary == nil ? "No primary set" : "Primary set"
    }

    private var loggedCountLabel: String {
        loggedCount == 1 ? "1 logged" : "\(loggedCount) logged"
    }
}

// MARK: - Motivation Note Row
struct MotivationNoteRow: View {
    let entry: MetricEntry
    let habitType: HabitType

    private var dateTimeLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }

    private var showsStatusBadge: Bool {
        TrackingSemantics.isLoggedForDay(entry: entry)
    }

    private var isSuccess: Bool {
        TrackingSemantics.isLoggedSuccess(habitType: habitType, entry: entry)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateTimeLabel)
                    .font(.caption)
                    .foregroundStyle(Color.currentSecondaryText)

                Text(entry.motivation ?? "")
                    .font(.subheadline)
                    .foregroundStyle(Color.currentText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            if showsStatusBadge {
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(isSuccess ? Color.currentSuccess : Color.currentError)
                    .font(.body)
                    .accessibilityLabel(isSuccess ? "Successful day" : "Missed day")
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Motivation from \(dateTimeLabel): \(entry.motivation ?? "")")
    }
}
