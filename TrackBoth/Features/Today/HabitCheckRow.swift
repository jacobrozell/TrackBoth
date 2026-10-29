import SwiftUI

struct HabitCheckRow: View {
    var model: HabitRowModel
    var onToggle: () -> Void
    var onOpen: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.s) {
            Button(action: onToggle) {
                Image(systemName: model.isDoneToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(model.isDoneToday ? Color.tbHabit : Color.tbTextSecondary)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityIdentifiers.habitToggle(model.id))
            .accessibilityLabel(model.isDoneToday ? "\(model.name), done" : "\(model.name), not done")
            .sensoryFeedback(model.isDoneToday ? .success : .selection, trigger: model.isDoneToday)

            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(model.name)
                        .font(.body)
                        .foregroundStyle(Color.tbTextPrimary)
                        .multilineTextAlignment(.leading)
                    Text(RecoveryCopy.habitRun(model.run))
                        .font(.subheadline)
                        .foregroundStyle(Color.tbTextSecondary)
                    if model.isAtRisk {
                        Text(RecoveryCopy.dontMissTwice)
                            .font(.footnote)
                            .foregroundStyle(Color.tbSlip)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(rowLabel)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.s)
        .background(Color.tbSurface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }

    private var rowLabel: String {
        var label = "\(model.name), \(RecoveryCopy.habitRun(model.run))"
        if model.isAtRisk { label += ", \(RecoveryCopy.dontMissTwice)" }
        return label
    }
}
