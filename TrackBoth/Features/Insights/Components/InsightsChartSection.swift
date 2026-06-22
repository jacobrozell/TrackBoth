import SwiftUI
import SwiftData

// MARK: - Insights Chart Section
/// Chart type picker + chart canvas (filter is owned by parent).
struct InsightsChartSection: View {
    @Binding var selectedChartType: ChartType
    let selectedFilter: MetricFilter
    let entries: [MetricEntry]
    let metrics: [Metric]
    var minChartHeight: CGFloat = 240

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Chart Type", selection: $selectedChartType) {
                ForEach(ChartType.availableInCurrentSurface, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onAppear(perform: normalizeChartType)
            .onChange(of: selectedChartType) { _, newValue in
                if !ChartType.availableInCurrentSurface.contains(newValue) {
                    selectedChartType = .line
                }
            }

            ChartContentView(
                selectedChartType: selectedChartType,
                selectedFilter: selectedFilter,
                entries: entries,
                metrics: metrics
            )
            .frame(minHeight: minChartHeight)
        }
    }

    private func normalizeChartType() {
        if !ChartType.availableInCurrentSurface.contains(selectedChartType) {
            selectedChartType = .line
        }
    }
}
