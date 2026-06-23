import SwiftUI
import SwiftData

// MARK: - MotivationsView
struct MotivationsView: View {
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = MotivationViewModel()
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.deviceLayout) private var deviceLayout

    init() {
        _metrics = QueryDescriptors.allMetrics
        _entries = QueryDescriptors.entriesWithMotivation
    }

    private var vices: [Metric] {
        viewModel.viceDisplayMetrics(metrics)
    }

    private var habits: [Metric] {
        viewModel.habitDisplayMetrics(metrics)
    }

    var body: some View {
        MetricTabShell(title: "Motivation") { geometry, usesSplit in
            Group {
                if metrics.isEmpty {
                    noHabitsEmptyState
                } else if vices.isEmpty && habits.isEmpty {
                    filteredEmptyState
                } else {
                    FilteredSplitTabLayout(
                        geometry: geometry,
                        usesSplit: usesSplit,
                        filterMetrics: metrics,
                        selectedFilter: $viewModel.selectedFilter,
                        landscapeFABAction: nil,
                        portraitFABAction: nil
                    ) {
                        motivationsScrollContent(idPrefix: usesSplit ? "landscape" : "portrait", geometry: geometry)
                    }
                }
            }
            .navigationDestination(for: UUID.self) { metricID in
                if let metric = metrics.first(where: { $0.id == metricID }) {
                    MetricMotivationDetailView(metric: metric)
                }
            }
        }
        .onAppear {
            logger.info("MotivationsView appeared", category: .ui)
        }
        .sheet(isPresented: $viewModel.showingAddMetric) {
            AddMetricView()
        }
    }

    private var noHabitsEmptyState: some View {
        EmptyStateView(
            icon: "plus.circle.fill",
            title: "Nothing to Track Yet",
            subtitle: "Add a habit or vice on Track first — then set a primary motivation and log thoughts on hard days.",
            actionTitle: "Add Habit or Vice",
            action: { viewModel.showAddMetric() }
        )
        .background(Color.currentBackground)
    }

    private var filteredEmptyState: some View {
        EmptyStateView(
            icon: "line.3.horizontal.decrease.circle",
            title: "No Matches",
            subtitle: "Try a different filter to see motivations for other habits and vices.",
            actionTitle: nil,
            action: nil
        )
        .background(Color.currentBackground)
    }

    @ViewBuilder
    private func motivationsScrollContent(idPrefix: String, geometry: GeometryProxy?) -> some View {
        let pinSectionHeaders = !dynamicTypeSize.usesAccessibilityLayout && !deviceLayout.isLandscape
        let topPadding: CGFloat = deviceLayout.isLandscape ? 16 : 8

        ScrollView {
            LazyVStack(
                spacing: 12,
                pinnedViews: pinSectionHeaders ? [.sectionHeaders] : []
            ) {
                if !vices.isEmpty {
                    Section {
                        ForEach(vices, id: \.id) { metric in
                            metricLink(for: metric)
                        }
                    } header: {
                        sectionHeader(
                            title: "Your vices",
                            subtitle: "Each vice has one primary motivation. Tap to view all logged motivations and add new ones.",
                            icon: "shield.fill",
                            iconColor: Color.currentPrimary,
                            extraTopPadding: deviceLayout.isLandscape ? 8 : 0
                        )
                    }
                }

                if !habits.isEmpty {
                    Section {
                        ForEach(habits, id: \.id) { metric in
                            metricLink(for: metric)
                        }
                    } header: {
                        sectionHeader(
                            title: "Habits",
                            subtitle: "Optional primary motivation plus day-to-day reflections as you build the habit.",
                            icon: "checkmark.circle.fill",
                            iconColor: Color.currentSuccess,
                            extraTopPadding: deviceLayout.isLandscape ? 8 : 0
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, topPadding)
            .padding(.bottom, 8)
            .adaptiveScrollInset()
        }
        .id("motivations-\(idPrefix)-\(Int(geometry?.size.width ?? 0))-\(Int(geometry?.size.height ?? 0))")
    }

    private func sectionHeader(
        title: String,
        subtitle: String,
        icon: String,
        iconColor: Color,
        extraTopPadding: CGFloat
    ) -> some View {
        AdaptiveSectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor
        )
        .padding(.top, extraTopPadding)
    }

    private func metricLink(for metric: Metric) -> some View {
        NavigationLink(value: metric.id) {
            MetricMotivationCardView(
                metric: metric,
                loggedCount: viewModel.notes(for: metric, entries: entries).count
            )
        }
        .buttonStyle(CardPressButtonStyle())
        .accessibilityIdentifier("motivation_metric_\(metric.id.uuidString)")
    }
}

#Preview {
    MotivationsView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
