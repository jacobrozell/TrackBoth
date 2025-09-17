import SwiftUI
import Charts

// MARK: - BarChartView Component
struct BarChartView: View {
    let filter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    @State private var animateChart = false
    
    private var weeklyData: [WeeklyData] {
        let startTime = Date()
        let calendar = CalendarHelper.calendar
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate) ?? endDate
        
        var weeklyCounts: [String: Int] = [:]
        
        for entry in entries {
            if entry.date >= startDate && entry.date <= endDate && matchesFilter(entry: entry) {
                // For positive habits: count when value == true (completed)
                // For vices: count when value == false (avoided)
                let metric = metrics.first { $0.id == entry.metricID }
                let isVice = metric?.habitType == .vice
                let shouldCount = isVice ? !entry.value : entry.value
                
                if shouldCount {
                    let weekStart = CalendarHelper.startOfWeek(for: entry.date)
                    let weekKey = DateFormatter.weekFormatter.string(from: weekStart)
                    weeklyCounts[weekKey, default: 0] += 1
                }
            }
        }
        
        let result = weeklyCounts.map { week, count in
            WeeklyData(week: week, count: count)
        }.sorted { $0.week < $1.week }
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Bar chart data calculation", duration: duration)
        logger.debug("Bar chart data calculated - Filter: \(filter), Data points: \(result.count)", category: .performance)
        
        return result
    }
    
    private func matchesFilter(entry: MetricEntry) -> Bool {
        FilterUtils.matchesFilter(filter, entry: entry, metrics: metrics)
    }
    
    private var chartTitle: String {
        switch filter {
        case .allVices:
            return "Weekly Avoidance"
        case .allHabits:
            return "Weekly Completion"
        case .all:
            return "Weekly Progress"
        case .specific(let metric):
            return metric.habitType == .vice ? "Weekly Avoidance" : "Weekly Completion"
        }
    }
    
    private var emptyStateMessage: String {
        switch filter {
        case .allVices:
            return "Avoid vices to see weekly patterns"
        case .allHabits:
            return "Complete habits to see weekly patterns"
        case .all:
            return "Track habits to see weekly patterns"
        case .specific(let metric):
            return metric.habitType == .vice ? "Avoid this vice to see weekly patterns" : "Complete this habit to see weekly patterns"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(chartTitle)
                    .font(.headline)
                    .foregroundColor(.currentText)
                Spacer()
                if weeklyData.count < 2 {
                    Text("Getting started...")
                        .font(.caption)
                        .foregroundColor(.currentWarning)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.currentWarning.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            if weeklyData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.currentSecondaryText.opacity(0.6))
                    
                    Text(emptyStateMessage)
                        .foregroundColor(.currentSecondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
            } else if weeklyData.count < 2 {
                VStack(spacing: 12) {
                    Chart(weeklyData) { data in
                        BarMark(
                            x: .value("Week", data.week),
                            y: .value("Count", data.count)
                        )
                        .foregroundStyle(Color.currentPrimary.gradient)
                    }
                    .frame(height: 120)
                    .opacity(animateChart ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateChart)
                    
                    Text("Keep it up! More weeks will show patterns")
                        .font(.caption)
                        .foregroundColor(.currentSuccess)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Chart(weeklyData) { data in
                        BarMark(
                            x: .value("Week", data.week),
                            y: .value("Count", data.count)
                        )
                        .foregroundStyle(Color.currentPrimary.gradient)
                    }
                    .frame(height: 180)
                    .opacity(animateChart ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateChart)
                    
                    // Weekly insights
                    if let bestWeek = weeklyData.max(by: { $0.count < $1.count }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.currentWarning)
                            Text("Best week: \(bestWeek.count) completions")
                                .font(.caption)
                                .foregroundColor(.currentSecondaryText)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.currentBackground)
        .cornerRadius(12)
        .onAppear {
            logger.debug("BarChartView appeared - Filter: \(filter), Entries: \(entries.count)", category: .ui)
            animateChart = true
        }
    }
}

#Preview {
    BarChartView(
        filter: .all,
        entries: [],
        metrics: []
    )
}
