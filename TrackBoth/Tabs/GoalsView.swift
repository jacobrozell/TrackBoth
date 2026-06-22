import SwiftUI
import SwiftData

// MARK: - GoalsView
struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = GoalsViewModel()
    @State private var selectedDate = Date()
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init() {
        _metrics = QueryDescriptors.allMetrics
        _entries = QueryDescriptors.entriesForGoalLookback()
    }

    private var metricsWithGoals: [Metric] {
        viewModel.metricsWithGoals(metrics)
    }

    private var filteredMetrics: [Metric] {
        viewModel.filteredMetricsWithGoals(metrics)
    }

    private var booleanGoals: [Metric] {
        viewModel.metricsWithGoals(filteredMetrics, goalType: .boolean)
    }

    private var quantityGoals: [Metric] {
        viewModel.metricsWithGoals(filteredMetrics, goalType: .quantity)
    }

    var body: some View {
        MetricTabShell(title: "Goals") { geometry, usesSplit in
            Group {
                if metrics.isEmpty {
                    noHabitsEmptyState
                } else if metricsWithGoals.isEmpty {
                    noGoalsEmptyState
                } else {
                    FilteredSplitTabLayout(
                        geometry: geometry,
                        usesSplit: usesSplit,
                        filterMetrics: metricsWithGoals,
                        selectedFilter: $viewModel.selectedFilter,
                        sidebarTitle: "Filter Goals",
                        includeIndividualMetrics: false,
                        landscapeFABAction: { viewModel.showingAddGoal = true },
                        portraitFABAction: { viewModel.showingAddGoal = true }
                    ) {
                        goalsScrollContent(idPrefix: usesSplit ? "landscape" : "portrait", geometry: geometry)
                    }
                }
            }
        }
        .adaptiveAddButton(isEmpty: metricsWithGoals.isEmpty, label: "Add Goal") {
            viewModel.showingAddGoal = true
        }
        .onAppear {
            logger.info("GoalsView appeared", category: .ui)
        }
        .sheet(isPresented: $viewModel.showingAddGoal) {
            AddGoalView()
        }
        .sheet(isPresented: $viewModel.showingAddMetric) {
            AddMetricView()
        }
    }

    private var noHabitsEmptyState: some View {
        EmptyStateView(
            icon: "plus.circle.fill",
            title: "Nothing to Track Yet",
            subtitle: "Add habits and vices on Track, then set goals to measure progress.",
            actionTitle: "Add Habit or Vice",
            action: { viewModel.showingAddMetric = true }
        )
        .background(Color.currentBackground)
    }

    private var noGoalsEmptyState: some View {
        EmptyStateView(
            icon: "target",
            title: "No Goals Set",
            subtitle: "Create goals for your habits and vices to track your progress and stay motivated",
            actionTitle: "Create Your First Goal",
            action: { viewModel.showingAddGoal = true }
        )
        .background(Color.currentBackground)
    }

    @ViewBuilder
    private func goalsScrollContent(idPrefix: String, geometry: GeometryProxy?) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                if !booleanGoals.isEmpty {
                    AdaptiveSectionHeader(
                        title: "Completion Goals",
                        subtitle: "Complete or avoid goals",
                        icon: "target",
                        iconColor: Color.currentPrimary
                    )
                    ForEach(booleanGoals) { metric in
                        GoalCardView(
                            metric: metric,
                            selectedDate: selectedDate,
                            entries: entries
                        )
                    }
                }

                if !quantityGoals.isEmpty {
                    AdaptiveSectionHeader(
                        title: "Quantity Goals",
                        subtitle: "Track measurable progress",
                        icon: "chart.bar.fill",
                        iconColor: Color.currentAccent
                    )
                    ForEach(quantityGoals) { metric in
                        GoalCardView(
                            metric: metric,
                            selectedDate: selectedDate,
                            entries: entries
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .adaptiveScrollInset()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .id("goals-\(idPrefix)-\(Int(geometry?.size.width ?? 0))-\(Int(geometry?.size.height ?? 0))")
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [Metric.self, MetricEntry.self, Goal.self], inMemory: true)
}
