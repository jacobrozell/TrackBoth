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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Chart Type", selection: $selectedChartType) {
                ForEach(ChartType.availableInCurrentSurface, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onAppear(perform: normalizeChartType)
            .onChange(of: selectedChartType) { oldValue, newValue in
                if oldValue != newValue {
                    HapticFeedback.selection()
                }
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
            .id(selectedChartType)
            .frame(minHeight: minChartHeight)
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
            .trackBothAnimation(TrackBothMotion.quick, value: selectedChartType, reduceMotion: reduceMotion)
        }
    }

    private func normalizeChartType() {
        if !ChartType.availableInCurrentSurface.contains(selectedChartType) {
            selectedChartType = .line
        }
    }
}
