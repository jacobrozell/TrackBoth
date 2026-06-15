import SwiftUI

// MARK: - ChartControlsView Component
struct ChartControlsView: View {
    @Environment(\.isCompactLandscape) private var isCompactLandscape
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var selectedFilter: MetricFilter
    @Binding var selectedChartType: ChartType
    let metrics: [Metric]
    let isLandscape: Bool

    private var usesCompactFilter: Bool {
        dynamicTypeSize.usesExpandedChrome && !isLandscape
    }

    var body: some View {
        VStack(spacing: isCompactLandscape ? 10 : 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Filter Data")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.currentSecondaryText)
                    .padding(.horizontal)

                if isLandscape {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            filterButtons
                        }
                        .padding(.horizontal)
                    }
                    .id("controls-landscape")
                } else if usesCompactFilter {
                    MetricFilterMenu(
                        metrics: metrics,
                        selectedFilter: $selectedFilter
                    )
                    .padding(.vertical, 4)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            filterButtons
                        }
                        .padding(.horizontal)
                    }
                    .id("controls-portrait")
                }
            }

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
        .padding(.vertical, isCompactLandscape ? 6 : 16)
        .background(Color.currentSecondaryBackground.opacity(0.5))
    }

    @ViewBuilder
    private var filterButtons: some View {
        ReactiveFilterButton(title: MetricFilter.all.displayName, isSelected: selectedFilter == .all) {
            selectedFilter = .all
        }
        ReactiveFilterButton(title: MetricFilter.allHabits.displayName, isSelected: selectedFilter == .allHabits) {
            selectedFilter = .allHabits
        }
        ReactiveFilterButton(title: MetricFilter.allVices.displayName, isSelected: selectedFilter == .allVices) {
            selectedFilter = .allVices
        }

        ForEach(metrics) { metric in
            ReactiveFilterButton(
                title: metric.name,
                isSelected: {
                    if case .specific(let selected) = selectedFilter {
                        return selected.id == metric.id
                    }
                    return false
                }()
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
