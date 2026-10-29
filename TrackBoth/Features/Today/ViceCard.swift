import SwiftUI

struct ViceCard: View {
    var model: ViceCardModel
    var calendar: Calendar
    var onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                HStack(spacing: Spacing.m) {
                    IconBadge(systemImage: model.iconName, tint: .tbBrand)
                    Text(model.name)
                        .font(.headline)
                        .foregroundStyle(Color.tbTextPrimary)
                        .multilineTextAlignment(.leading)
                }
                Text(RecoveryCopy.daysFree(model.daysFree))
                    .bigNumberStyle()
                    .foregroundStyle(Color.tbTextPrimary)
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    Text(model.clockLine(at: context.date, calendar: calendar))
                        .font(.subheadline)
                        .foregroundStyle(Color.tbTextSecondary)
                        .accessibilityHidden(true)
                }
                DayDots(states: model.week, labels: model.weekLabels)
                if let nextMilestone = model.nextMilestone {
                    Text(nextMilestone)
                        .font(.footnote)
                        .foregroundStyle(Color.tbTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.l)
            .background(Color.tbSurface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(AccessibilityIdentifiers.viceCard(model.id))
    }
}
