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
                .font(.headline)
                .foregroundColor(Color.currentText)

            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(Color.currentSecondaryText)
                    Text("\(currentStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.currentWarning)
                }

                VStack(alignment: .leading) {
                    Text("Longest")
                        .font(.caption)
                        .foregroundColor(Color.currentSecondaryText)
                    Text("\(longestStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.currentPrimary)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.currentBackground)
        .cornerRadius(12)
    }
}

#Preview {
    StreakInfoView(
        filter: .all,
        entries: [],
        metrics: []
    )
}
