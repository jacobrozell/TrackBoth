import SwiftUI

// MARK: - ChartControlsView Component
struct ChartControlsView: View {
    @Binding var selectedFilter: MetricFilter
    @Binding var selectedChartType: ChartType
    let metrics: [Metric]
    let isLandscape: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Filter picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Filter Data")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.currentSecondaryText)
                    .padding(.horizontal)
                
                if isLandscape {
                    // Landscape: vertical list (sidebar)
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            filterButtons
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // Portrait: horizontal chips row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            filterButtons
                        }
                        .padding(.horizontal)
                    }
                }
            }

            // Chart type picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Chart Type")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.currentSecondaryText)
                    .padding(.horizontal)
                
                Picker("Chart Type", selection: $selectedChartType) {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color.currentSecondaryBackground.opacity(0.5))
    }
    
    @ViewBuilder
    private var filterButtons: some View {
        // All filter
        FilterButton(
            filter: .all,
            isSelected: selectedFilter == .all
        ) {
            selectedFilter = .all
        }

        // All Habits filter
        FilterButton(
            filter: .allHabits,
            isSelected: selectedFilter == .allHabits
        ) {
            selectedFilter = .allHabits
        }

        // All Vices filter
        FilterButton(
            filter: .allVices,
            isSelected: selectedFilter == .allVices
        ) {
            selectedFilter = .allVices
        }

        // Individual metrics
        ForEach(metrics) { metric in
            FilterButton(
                filter: .specific(metric),
                isSelected: selectedFilter == .specific(metric)
            ) {
                selectedFilter = .specific(metric)
            }
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
