import SwiftUI
import Charts

// MARK: - LineChartView Component
struct LineChartView: View {
    let filter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    @State private var animateChart = false
    
    private var chartData: [ChartDataPoint] {
        ChartDataProcessor.cumulativeSuccessTrend(filter: filter, entries: entries, metrics: metrics)
    }

    private var chartTitle: String {
        ChartCopy.title(chartType: .line, filter: filter)
    }

    private var emptyStateMessage: String {
        ChartCopy.emptyMessage(chartType: .line, filter: filter)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ChartHeaderRow(title: chartTitle) {
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
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .padding(.horizontal, 12)
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
