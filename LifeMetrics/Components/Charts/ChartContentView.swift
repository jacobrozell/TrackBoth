import SwiftUI
import Charts

// MARK: - ChartContentView Component
struct ChartContentView: View {
    let selectedChartType: ChartType
    let selectedFilter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    // Main chart
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

                    // Additional content - layout differently for landscape
                    if geometry.size.width > geometry.size.height {
                        // Landscape: side-by-side layout
                        HStack(alignment: .top, spacing: 16) {
                            VStack(spacing: 16) {
                                MotivationalInsightsView(entries: entries, metrics: metrics, filter: selectedFilter)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 16) {
                                StreakInfoView(filter: selectedFilter, entries: entries, metrics: metrics)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        // Portrait: stacked layout
                        VStack(spacing: 16) {
                            MotivationalInsightsView(entries: entries, metrics: metrics, filter: selectedFilter)
                            StreakInfoView(filter: selectedFilter, entries: entries, metrics: metrics)
                        }
                    }
                }
                .padding()
            }
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
