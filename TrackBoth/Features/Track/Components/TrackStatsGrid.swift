import SwiftUI

// MARK: - Track Stat Tile
/// Compact dashboard stat for the Track tab — flat, native, scannable.
struct TrackStatTile: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

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
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
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
                    icon: "xmark.circle.fill",
                    tint: Color.currentError
                )
            }
            if activeStreaks > 0 {
                TrackStatTile(
                    title: "Active streaks",
                    value: "\(activeStreaks)",
                    icon: "flame.fill",
                    tint: Color.currentWarning
                )
            }
            TrackStatTile(
                title: "Logged today",
                value: "\(todayCompleted)/\(totalMetrics)",
                icon: "calendar",
                tint: Color.currentPrimary
            )
        }
        .frame(maxWidth: usesWideLayout ? 640 : .infinity)
    }
}
