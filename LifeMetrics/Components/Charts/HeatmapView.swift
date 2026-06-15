import SwiftUI

// MARK: - HeatmapView Component
struct HeatmapView: View {
    let filter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    @State private var animateChart = false
    
    private var heatmapData: [HeatmapData] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -90, to: endDate) ?? endDate
        
        var data: [HeatmapData] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dayEntries = entries.filter { entry in
                calendar.isDate(entry.date, inSameDayAs: currentDate) &&
                matchesFilter(entry: entry)
            }
            
            let hasSuccessfulEntry = !FilterUtils.successfulEntries(filter, entries: dayEntries, metrics: metrics).isEmpty
            
            data.append(HeatmapData(
                date: currentDate,
                completed: hasSuccessfulEntry
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return data
    }
    
    private func matchesFilter(entry: MetricEntry) -> Bool {
        FilterUtils.matchesFilter(filter, entry: entry, metrics: metrics)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(heatmapTitle)
                    .font(.headline)
                    .foregroundColor(.currentText)
                Spacer()
                if completedDays < 7 {
                    Text("Building consistency...")
                        .font(.caption)
                        .foregroundColor(.currentWarning)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.currentWarning.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            if heatmapData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 40))
                        .foregroundColor(.currentSecondaryText.opacity(0.6))
                    
                    Text(emptyStateMessage)
                        .foregroundColor(.currentSecondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 13), spacing: 3) {
                        ForEach(heatmapData) { data in
                            Rectangle()
                                .fill(data.completed ? Color.currentSuccess : Color.currentSecondaryText.opacity(0.3))
                                .frame(height: 15)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 180)
                    .opacity(animateChart ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0).delay(0.3), value: animateChart)
                    
                    // Consistency insights
                    HStack(spacing: 16) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.currentSuccess)
                            Text("\(completedDays) days")
                                .font(.caption)
                                .foregroundColor(.currentSecondaryText)
                        }
                        
                        if completedDays > 0 {
                            HStack {
                                Image(systemName: "percent")
                                    .foregroundColor(.currentPrimary)
                                Text("\(Int(Double(completedDays) / Double(heatmapData.count) * 100))% consistency")
                                    .font(.caption)
                                    .foregroundColor(.currentSecondaryText)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color.currentBackground)
        .cornerRadius(12)
        .onAppear {
            animateChart = true
        }
    }
    
    private var completedDays: Int {
        heatmapData.filter { $0.completed }.count
    }
    
    private var heatmapTitle: String {
        switch filter {
        case .allVices:
            return "90-Day Avoidance Heatmap"
        case .allHabits:
            return "90-Day Completion Heatmap"
        case .all:
            return "90-Day Progress Heatmap"
        case .specific(let metric):
            return metric.habitType == .vice ? "90-Day Avoidance Heatmap" : "90-Day Completion Heatmap"
        }
    }
    
    private var emptyStateMessage: String {
        switch filter {
        case .allVices:
            return "Avoid vices to build your consistency map"
        case .allHabits:
            return "Complete habits to build your consistency map"
        case .all:
            return "Start tracking to build your consistency map"
        case .specific(let metric):
            return metric.habitType == .vice ? "Avoid this vice to build your consistency map" : "Complete this habit to build your consistency map"
        }
    }
}

#Preview {
    HeatmapView(
        filter: .all,
        entries: [],
        metrics: []
    )
}
