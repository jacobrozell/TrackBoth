import SwiftUI

// MARK: - HeatmapView Component
struct HeatmapView: View {
    let filter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    @State private var animateChart = false
    
    private var heatmapData: [HeatmapData] {
        ChartDataProcessor.dailySuccessHeatmap(filter: filter, entries: entries, metrics: metrics)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(ChartCopy.title(chartType: .heatmap, filter: filter))
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
                    
                    Text(ChartCopy.emptyMessage(chartType: .heatmap, filter: filter))
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
        heatmapData.filter(\.completed).count
    }
}

#Preview {
    HeatmapView(
        filter: .all,
        entries: [],
        metrics: []
    )
}
