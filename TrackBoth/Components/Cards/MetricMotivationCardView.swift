import SwiftUI

// MARK: - Metric Motivation Card
/// One habit or vice with its pinned "why" and dated notes.
struct MetricMotivationCardView: View {
    let metric: Metric
    let notes: [MetricEntry]
    let onEditWhy: () -> Void
    let onAddNote: () -> Void

    private var trimmedWhy: String? {
        guard let text = metric.primaryMotivation?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return nil }
        return text
    }

    private var accentColor: Color {
        metric.habitType == .vice ? Color.currentWarning : Color.currentSuccess
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            whyBlock

            if !notes.isEmpty {
                notesBlock
            }

            actionButtons
        }
        .padding(16)
        .metricCardStyle()
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(accentColor.opacity(0.85))
                .frame(width: 4)
                .padding(.vertical, 4)
        }
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: metric.habitType.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(accentColor)
                .frame(width: 28, height: 28)
                .background(accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(metric.name)
                    .font(.headline)
                    .foregroundStyle(Color.currentText)

                Text(metric.habitType == .vice ? "Vice" : "Habit")
                    .font(.caption)
                    .foregroundStyle(Color.currentSecondaryText)
            }

            Spacer(minLength: 0)
        }
    }

    private var whyBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Your why", systemImage: "lightbulb.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(accentColor)

            if let why = trimmedWhy {
                Text(why)
                    .font(.body)
                    .foregroundStyle(Color.currentText)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(emptyWhyCopy)
                    .font(.subheadline)
                    .foregroundStyle(Color.currentSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.currentBackground.opacity(0.6), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var emptyWhyCopy: String {
        metric.habitType == .vice
            ? "Add the reason you want to quit — we'll show it when you're about to log a slip."
            : "Optional — why this habit matters to you."
    }

    @ViewBuilder
    private var notesBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Past notes", systemImage: "text.quote")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.currentSecondaryText)

            VStack(spacing: 0) {
                ForEach(Array(notes.enumerated()), id: \.element.id) { index, entry in
                    MotivationNoteRow(entry: entry, habitType: metric.habitType)

                    if index < notes.count - 1 {
                        Divider()
                            .padding(.leading, 4)
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: onEditWhy) {
                Label(trimmedWhy == nil ? "Set your why" : "Edit your why", systemImage: "lightbulb")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(accentColor)

            Button(action: onAddNote) {
                Label("Add note", systemImage: "square.and.pencil")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(Color.currentPrimary)
        }
    }
}

// MARK: - Motivation Note Row
struct MotivationNoteRow: View {
    let entry: MetricEntry
    let habitType: HabitType

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
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
                Text(dateLabel)
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
        .accessibilityLabel("Note from \(dateLabel): \(entry.motivation ?? "")")
    }
}
