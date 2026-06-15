import SwiftUI
import Charts

// MARK: - LineChartView Component
struct LineChartView: View {
    let filter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    @State private var animateChart = false
    
    private var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        
        var data: [ChartDataPoint] = []
        var currentDate = startDate
        var cumulativeCount = 0
        
        while currentDate <= endDate {
            let dayEntries = entries.filter { entry in
                calendar.isDate(entry.date, inSameDayAs: currentDate) &&
                matchesFilter(entry: entry)
            }
            
            let dayHasSuccess = !FilterUtils.successfulEntries(filter, entries: dayEntries, metrics: metrics).isEmpty
            if dayHasSuccess {
                cumulativeCount += 1
            }

            data.append(ChartDataPoint(
                date: currentDate,
                value: cumulativeCount
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return data
    }
    
    private func matchesFilter(entry: MetricEntry) -> Bool {
        FilterUtils.matchesFilter(filter, entry: entry, metrics: metrics)
    }
    
    private var chartTitle: String {
        switch filter {
        case .allVices:
            return "30-Day Avoidance Trend"
        case .allHabits:
            return "30-Day Completion Trend"
        case .all:
            return "30-Day Progress Trend"
        case .specific(let metric):
            return metric.habitType == .vice ? "30-Day Avoidance Trend" : "30-Day Completion Trend"
        }
    }
    
    private var emptyStateMessage: String {
        switch filter {
        case .allVices:
            return "Avoid vices to see your progress"
        case .allHabits:
            return "Complete habits to see your progress"
        case .all:
            return "Start tracking to see your progress"
        case .specific(let metric):
            return metric.habitType == .vice ? "Avoid this vice to see your progress" : "Complete this habit to see your progress"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(chartTitle)
                    .font(.headline)
                    .foregroundColor(.currentText)
                Spacer()
                if chartData.count < 7 {
                    Text("Building momentum...")
                        .font(.caption)
                        .foregroundColor(.currentWarning)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.currentWarning.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            if chartData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.currentSecondaryText.opacity(0.6))
                    
                    Text(emptyStateMessage)
                        .foregroundColor(.currentSecondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
            } else if chartData.count < 3 {
                VStack(spacing: 12) {
                    Chart(chartData) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Count", dataPoint.value)
                        )
                        .foregroundStyle(Color.currentPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        AreaMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Count", dataPoint.value)
                        )
                        .foregroundStyle(Color.currentPrimary.opacity(0.2))
                    }
                    .frame(height: 120)
                    .opacity(animateChart ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0).delay(0.2), value: animateChart)
                    
                    Text("Great start! Keep going to see trends emerge")
                        .font(.caption)
                        .foregroundColor(.currentPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Chart(chartData) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Count", dataPoint.value)
                        )
                        .foregroundStyle(Color.currentPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        AreaMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Count", dataPoint.value)
                        )
                        .foregroundStyle(Color.currentPrimary.opacity(0.2))
                    }
                    .frame(height: 180)
                    .opacity(animateChart ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 1.0).delay(0.2), value: animateChart)
                    
                    // Progress insight
                    if let latest = chartData.last, let first = chartData.first {
                        let progress = latest.value - first.value
                        HStack {
                            Image(systemName: progress > 0 ? "arrow.up.right" : progress < 0 ? "arrow.down.right" : "minus")
                                .foregroundColor(progress > 0 ? .currentSuccess : progress < 0 ? .currentError : .currentSecondaryText)
                            Text("\(progress > 0 ? "+" : "")\(progress) habits since start")
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
            animateChart = true
        }
    }
}

#Preview {
    LineChartView(
        filter: .all,
        entries: [],
        metrics: []
    )
}
