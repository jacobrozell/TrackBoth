import SwiftUI

// MARK: - StreakInfoView Component
struct StreakInfoView: View {
    let filter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]

    private var currentStreak: Int {
        StreakUtils.calculateFilterCurrentStreak(filter: filter, metrics: metrics, entries: entries)
    }

    private var longestStreak: Int {
        StreakUtils.calculateFilterLongestStreak(filter: filter, metrics: metrics, entries: entries)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak Stats")
                .h4()
                .foregroundColor(Color.currentText)

            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Current")
                        .caption()
                        .foregroundColor(Color.currentSecondaryText)
                    Text("\(currentStreak)")
                        .displaySmall()
                        .foregroundColor(Color.currentWarning)
                }

                VStack(alignment: .leading) {
                    Text("Longest")
                        .caption()
                        .foregroundColor(Color.currentSecondaryText)
                    Text("\(longestStreak)")
                        .displaySmall()
                        .foregroundColor(Color.currentPrimary)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.currentBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .chartVoiceOverSummary(
            ChartAccessibilitySummary.streakSummary(
                current: currentStreak,
                longest: longestStreak,
                filter: filter
            )
        )
    }
}

#Preview {
    StreakInfoView(
        filter: .all,
        entries: [],
        metrics: []
    )
}
