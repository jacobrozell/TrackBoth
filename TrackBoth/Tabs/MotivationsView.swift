import SwiftUI
import SwiftData

// MARK: - MotivationsView
struct MotivationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = MotivationViewModel()
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init() {
        _metrics = QueryDescriptors.allMetrics
        _entries = QueryDescriptors.entriesWithMotivation
    }

    var body: some View {
        MetricTabShell(title: "Motivation") { geometry, usesSplit in
            Group {
                if metrics.isEmpty {
                    noHabitsEmptyState
                } else if !viewModel.hasAnyMotivations(metrics, entries: entries) {
                    noMotivationsEmptyState
                } else {
                    FilteredSplitTabLayout(
                        geometry: geometry,
                        usesSplit: usesSplit,
                        filterMetrics: metrics,
                        selectedFilter: $viewModel.selectedFilter,
                        landscapeFABAction: { viewModel.showingAddMotivation = true },
                        portraitFABAction: { viewModel.showingAddMotivation = true }
                    ) {
                        motivationsScrollContent(idPrefix: usesSplit ? "landscape" : "portrait", geometry: geometry)
                    }
                }
            }
        }
        .adaptiveAddButton(isEmpty: !viewModel.hasAnyMotivations(metrics, entries: entries), label: "Add Motivation") {
            viewModel.showingAddMotivation = true
        }
        .onAppear {
            logger.info("MotivationsView appeared", category: .ui)
        }
        .sheet(isPresented: $viewModel.showingAddMetric) {
            AddMetricView()
        }
        .sheet(isPresented: $viewModel.showingAddMotivation) {
            AddMotivationView(metrics: metrics)
        }
    }

    private var noHabitsEmptyState: some View {
        EmptyStateView(
            icon: "plus.circle.fill",
            title: "Nothing to Track Yet",
            subtitle: "Add habits and vices on Track, then write motivations to stay accountable.",
            actionTitle: "Add Habit or Vice",
            action: { viewModel.showAddMetric() }
        )
        .background(Color.currentBackground)
    }

    private var noMotivationsEmptyState: some View {
        EmptyStateView(
            icon: "book.closed",
            title: "No Motivations Yet",
            subtitle: "Start building your motivation library to stay accountable and inspired.",
            actionTitle: "Add Motivation",
            action: { viewModel.showingAddMotivation = true }
        )
        .background(Color.currentBackground)
    }

    @ViewBuilder
    private func motivationsScrollContent(idPrefix: String, geometry: GeometryProxy?) -> some View {
        let primaryMotivations = viewModel.primaryMotivations(metrics)
        let dailyMotivations = viewModel.dailyMotivations(entries, metrics: metrics)

        ScrollView {
            LazyVStack(
                spacing: 16,
                pinnedViews: dynamicTypeSize.usesAccessibilityLayout ? [] : [.sectionHeaders]
            ) {
                if !primaryMotivations.isEmpty {
                    Section(header: AdaptiveSectionHeader(
                        title: "Primary Motivations",
                        subtitle: "Your core reasons for your habits",
                        icon: "star.fill",
                        iconColor: Color.currentWarning
                    )) {
                        ForEach(primaryMotivations) { metric in
                            PrimaryMotivationCardView(metric: metric)
                        }
                    }
                }

                if !dailyMotivations.isEmpty {
                    Section(header: AdaptiveSectionHeader(
                        title: "Daily Motivations",
                        subtitle: "Recent motivation entries",
                        icon: "clock",
                        iconColor: Color.currentSecondaryText
                    )) {
                        ForEach(dailyMotivations) { entry in
                            DailyMotivationCardView(entry: entry, metrics: metrics)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .adaptiveScrollInset()
        }
        .id("motivations-\(idPrefix)-\(Int(geometry?.size.width ?? 0))-\(Int(geometry?.size.height ?? 0))")
    }
}

#Preview {
    MotivationsView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
