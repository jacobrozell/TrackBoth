import SwiftUI

// MARK: - StreakInfoView Component
struct StreakInfoView: View {
    let filter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    
    private var filteredEntries: [MetricEntry] {
        entries.filter { entry in
            matchesFilter(entry: entry) && isSuccessfulEntry(entry)
        }
    }
    
    private func isSuccessfulEntry(_ entry: MetricEntry) -> Bool {
        let metric = metrics.first { $0.id == entry.metricID }
        let isVice = metric?.safeHabitType == .vice
        // For positive habits: success when value == true (completed)
        // For vices: success when value == false (avoided)
        return isVice ? !entry.value : entry.value
    }
    
    private func matchesFilter(entry: MetricEntry) -> Bool {
        FilterUtils.matchesFilter(filter, entry: entry, metrics: metrics)
    }
    
    private var currentStreak: Int {
        StreakUtils.calculateCurrentStreak(filteredEntries: filteredEntries)
    }
    
    private var longestStreak: Int {
        StreakUtils.calculateLongestStreak(filteredEntries: filteredEntries)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak Stats")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currentStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading) {
                    Text("Longest")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(longestStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
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
