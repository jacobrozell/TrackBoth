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
        }
        .onAppear {
            logger.info("MotivationsView appeared", category: .ui)
        }
        .sheet(item: $viewModel.motivationSheet) { sheet in
            switch sheet {
            case .editWhy(let metric):
                EditWhySheet(metric: metric)
            case .addNote(let metric):
                AddMotivationView(metrics: metrics, preselectedMetric: metric)
            }
        }
        .sheet(isPresented: $viewModel.showingAddMetric) {
            AddMetricView()
        }
    }

    private var noHabitsEmptyState: some View {
        EmptyStateView(
            icon: "plus.circle.fill",
            title: "Nothing to Track Yet",
            subtitle: "Add a vice on Track first — then set your why and save notes for tough days.",
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
        ScrollView {
            LazyVStack(
                spacing: 16,
                pinnedViews: dynamicTypeSize.usesAccessibilityLayout ? [] : [.sectionHeaders]
            ) {
                if !vices.isEmpty {
                    Section {
                        ForEach(vices, id: \.id) { metric in
                            metricCard(for: metric)
                        }
                    } header: {
                        AdaptiveSectionHeader(
                            title: "Your vices",
                            subtitle: "Why you're staying clean — and notes from hard days",
                            icon: "shield.fill",
                            iconColor: Color.currentPrimary
                        )
                    }
                }

                if !habits.isEmpty {
                    Section {
                        ForEach(habits, id: \.id) { metric in
                            metricCard(for: metric)
                        }
                    } header: {
                        AdaptiveSectionHeader(
                            title: "Habits",
                            subtitle: "Optional — your why and reflections while building the habit",
                            icon: "checkmark.circle.fill",
                            iconColor: Color.currentSuccess
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .adaptiveScrollInset()
        }
        .id("motivations-\(idPrefix)-\(Int(geometry?.size.width ?? 0))-\(Int(geometry?.size.height ?? 0))")
    }

    private func metricCard(for metric: Metric) -> some View {
        MetricMotivationCardView(
            metric: metric,
            notes: viewModel.notes(for: metric, entries: entries),
            onEditWhy: { viewModel.presentEditWhy(for: metric) },
            onAddNote: { viewModel.presentAddNote(for: metric) }
        )
    }
}

#Preview {
    MotivationsView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
