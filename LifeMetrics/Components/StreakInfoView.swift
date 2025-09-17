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
        let isVice = metric?.habitType == .vice
        // For positive habits: success when value == true (completed)
        // For vices: success when value == false (avoided)
        return isVice ? !entry.value : entry.value
    }
    
    private func matchesFilter(entry: MetricEntry) -> Bool {
        FilterUtils.matchesFilter(filter, entry: entry, metrics: metrics)
    }
    
    private var currentStreak: Int {
        // Check if any metrics in the filter have entries
        let filteredMetrics = getFilteredMetrics()
        let hasLoggedMetrics = filteredMetrics.contains { metric in entries.contains(where: { $0.metricID == metric.id }) }
        
        if !hasLoggedMetrics {
            return 0 // No streak if no metrics have entries
        }
        
        return StreakUtils.calculateCurrentStreak(filteredEntries: filteredEntries)
    }
    
    private var longestStreak: Int {
        // Check if any metrics in the filter have entries
        let filteredMetrics = getFilteredMetrics()
        let hasLoggedMetrics = filteredMetrics.contains { metric in entries.contains(where: { $0.metricID == metric.id }) }
        
        if !hasLoggedMetrics {
            return 0 // No streak if no metrics have entries
        }
        
        return StreakUtils.calculateLongestStreak(filteredEntries: filteredEntries)
    }
    
    private func getFilteredMetrics() -> [Metric] {
        switch filter {
        case .all:
            return metrics
        case .allHabits:
            return metrics.filter { $0.habitType == .positive }
        case .allVices:
            return metrics.filter { $0.habitType == .vice }
        case .specific(let metric):
            return [metric]
        }
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
