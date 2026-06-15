import SwiftUI

// MARK: - MetricFilterMenu
/// Compact filter picker for larger text sizes.
struct MetricFilterMenu: View {
    let metrics: [Metric]
    @Binding var selectedFilter: MetricFilter
    var includeIndividualMetrics: Bool = true

    var body: some View {
        Menu {
            filterMenuItems
        } label: {
            HStack(spacing: 8) {
                Text("Filter: \(selectedFilter.displayName)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundColor(Color.currentSecondaryText)
            }
            .foregroundColor(Color.currentText)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.currentBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.currentSecondaryText.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
        }
        .accessibilityLabel("Filter metrics")
        .accessibilityValue(selectedFilter.displayName)
    }

    @ViewBuilder
    private var filterMenuItems: some View {
        Button("All") { selectedFilter = .all }
        Button("All Habits") { selectedFilter = .allHabits }
        Button("All Vices") { selectedFilter = .allVices }

        if includeIndividualMetrics {
            ForEach(metrics) { metric in
                Button(metric.name) { selectedFilter = .specific(metric) }
            }
        }
    }
}

// MARK: - MetricFilterBar
/// Shared filter UI for portrait and compact-landscape layouts (horizontal chips).
struct MetricFilterChipRow: View {
    @Environment(\.isCompactLandscape) private var isCompactLandscape
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let metrics: [Metric]
    @Binding var selectedFilter: MetricFilter
    var includeIndividualMetrics: Bool = true

    private var verticalPadding: CGFloat { isCompactLandscape ? 4 : 8 }
    private var usesCompactFilter: Bool { dynamicTypeSize.usesExpandedChrome }

    var body: some View {
        Group {
            if usesCompactFilter {
                MetricFilterMenu(
                    metrics: metrics,
                    selectedFilter: $selectedFilter,
                    includeIndividualMetrics: includeIndividualMetrics
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: isCompactLandscape ? 8 : 12) {
                        chipButtons
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.vertical, verticalPadding)
        .background(Color.currentSecondaryBackground)
    }

    @ViewBuilder
    private var chipButtons: some View {
        ReactiveFilterButton(title: "All", isSelected: selectedFilter == .all) {
            selectedFilter = .all
        }
        ReactiveFilterButton(title: "All Habits", isSelected: selectedFilter == .allHabits) {
            selectedFilter = .allHabits
        }
        ReactiveFilterButton(title: "All Vices", isSelected: selectedFilter == .allVices) {
            selectedFilter = .allVices
        }

        if includeIndividualMetrics {
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
}

// MARK: - MetricFilterSidebar
/// Vertical filter list for sidebar-split layouts (iPad / wide landscape).
struct MetricFilterSidebar: View {
    let title: String
    let metrics: [Metric]
    @Binding var selectedFilter: MetricFilter
    var includeIndividualMetrics: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.currentSecondaryText)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    filterButton(title: "All", isSelected: selectedFilter == .all) {
                        selectedFilter = .all
                    }
                    filterButton(title: "All Habits", isSelected: selectedFilter == .allHabits) {
                        selectedFilter = .allHabits
                    }
                    filterButton(title: "All Vices", isSelected: selectedFilter == .allVices) {
                        selectedFilter = .allVices
                    }

                    if includeIndividualMetrics {
                        ForEach(metrics) { metric in
                            filterButton(
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
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func filterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        ReactiveFilterButton(title: title, isSelected: isSelected, action: action)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
