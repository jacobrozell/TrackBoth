import SwiftUI
import Charts

// MARK: - BarChartView Component
struct BarChartView: View {
    let filter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animateChart = false
    
    private var weeklyData: [WeeklyData] {
        ChartDataProcessor.weeklySuccessCounts(filter: filter, entries: entries, metrics: metrics)
    }

    private var chartTitle: String {
        ChartCopy.title(chartType: .bar, filter: filter)
    }

    private var emptyStateMessage: String {
        ChartCopy.emptyMessage(chartType: .bar, filter: filter)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ChartHeaderRow(title: chartTitle) {
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
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .padding(.horizontal, 12)
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
                    .chartReveal(isRevealed: animateChart, reduceMotion: reduceMotion, delay: 0.2)
                    .accessibilityHidden(true)
                    
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
                    .chartReveal(isRevealed: animateChart, reduceMotion: reduceMotion, delay: 0.2)
                    .accessibilityHidden(true)
                    
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
        .background(Color.currentBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .chartVoiceOverSummary(ChartAccessibilitySummary.barSummary(data: weeklyData, filter: filter))
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
