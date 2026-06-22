import SwiftUI

// MARK: - Track Stat Tile
/// Compact dashboard stat for the Track tab — flat, native, scannable.
struct TrackStatTile: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color
    /// Full phrase for VoiceOver when `title` is abbreviated for layout.
    var accessibilityTitle: String?

    @ScaledMetric(relativeTo: .caption) private var labelMinHeight: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var tileMinHeight: CGFloat = 52

    private var spokenTitle: String { accessibilityTitle ?? title }

    init(
        title: String,
        value: String,
        icon: String,
        tint: Color,
        accessibilityTitle: String? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.tint = tint
        self.accessibilityTitle = accessibilityTitle
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(Color.currentText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.currentSecondaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .allowsTightening(true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, minHeight: labelMinHeight, alignment: .topLeading)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: tileMinHeight, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(spokenTitle), \(value)")
    }
}

// MARK: - Track Stats Grid
struct TrackStatsGrid: View {
    let totalHabits: Int
    let totalVices: Int
    let activeStreaks: Int
    let todayCompleted: Int
    let totalMetrics: Int
    var usesWideLayout: Bool = false

    private var columns: [GridItem] {
        [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            if totalHabits > 0 {
                TrackStatTile(
                    title: "Habits",
                    value: "\(totalHabits)",
                    icon: "checkmark.circle.fill",
                    tint: Color.currentSuccess
                )
            }
            if totalVices > 0 {
                TrackStatTile(
                    title: "Vices",
                    value: "\(totalVices)",
                    icon: "shield.fill",
                    tint: Color.currentPrimary
                )
            }
            if activeStreaks > 0 {
                TrackStatTile(
                    title: "Streaks",
                    value: "\(activeStreaks)",
                    icon: "flame.fill",
                    tint: Color.currentWarning,
                    accessibilityTitle: "Active streaks"
                )
            }
            TrackStatTile(
                title: "Today",
                value: "\(todayCompleted)/\(totalMetrics)",
                icon: "calendar",
                tint: Color.currentPrimary,
                accessibilityTitle: "Logged today"
            )
        }
        .frame(maxWidth: usesWideLayout ? 640 : .infinity)
    }
}
