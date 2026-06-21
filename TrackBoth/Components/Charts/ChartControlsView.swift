import SwiftUI
import SwiftData

// MARK: - ChartControlsView Component
struct ChartControlsView: View {
    @Environment(\.isCompactLandscape) private var isCompactLandscape
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var selectedFilter: MetricFilter
    @Binding var selectedChartType: ChartType
    let metrics: [Metric]
    let isLandscape: Bool

    var body: some View {
        VStack(spacing: isCompactLandscape ? 10 : 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Filter Data")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.currentSecondaryText)
                    .padding(.horizontal)

                if isLandscape {
                    MetricFilterSidebar(
                        title: "Filter Data",
                        metrics: metrics,
                        selectedFilter: $selectedFilter
                    )
                } else {
                    MetricFilterChipRow(
                        metrics: metrics,
                        selectedFilter: $selectedFilter
                    )
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Chart Type")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.currentSecondaryText)
                    .padding(.horizontal)

                Picker("Chart Type", selection: $selectedChartType) {
                    ForEach(ChartType.availableInCurrentSurface, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onAppear(perform: normalizeChartType)
                .onChange(of: selectedChartType) { _, newValue in
                    if !ChartType.availableInCurrentSurface.contains(newValue) {
                        selectedChartType = .line
                    }
                }
            }
        }
        .padding(.vertical, isCompactLandscape ? 6 : 16)
        .background(Color.currentSecondaryBackground.opacity(0.5))
    }

    private func normalizeChartType() {
        if !ChartType.availableInCurrentSurface.contains(selectedChartType) {
            selectedChartType = .line
        }
    }
}

#Preview {
    ChartControlsView(
        selectedFilter: .constant(.all),
        selectedChartType: .constant(.line),
        metrics: [],
        isLandscape: false
    )
}
