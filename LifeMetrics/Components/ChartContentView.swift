import SwiftUI
import Charts

// MARK: - ChartContentView Component
struct ChartContentView: View {
    let selectedChartType: ChartType
    let selectedFilter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch selectedChartType {
                case .line:
                    LineChartView(
                        filter: selectedFilter,
                        entries: entries,
                        metrics: metrics
                    )

                case .bar:
                    BarChartView(
                        filter: selectedFilter,
                        entries: entries,
                        metrics: metrics
                    )

                case .heatmap:
                    HeatmapView(
                        filter: selectedFilter,
                        entries: entries,
                        metrics: metrics
                    )
                
                case .quantity:
                    QuantityChartView(
                        filter: selectedFilter,
                        entries: entries,
                        metrics: metrics
                    )
                }

                // Motivational insights
                MotivationalInsightsView(entries: entries, metrics: metrics, filter: selectedFilter)
                
                // Streak info
                StreakInfoView(filter: selectedFilter, entries: entries, metrics: metrics)
            }
            .padding()
        }
    }
}


#Preview {
    ChartContentView(
        selectedChartType: .line,
        selectedFilter: .all,
        entries: [],
        metrics: []
    )
}
