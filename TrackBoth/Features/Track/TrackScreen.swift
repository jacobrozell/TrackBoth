import SwiftUI
import SwiftData

// MARK: - TrackScreen
/// Daily tracking surface — routes to explicit iPhone/iPad layout variants.
struct TrackScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.deviceLayout) private var deviceLayout
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]

    @State private var viewModel = HomeViewModel()
    @State private var showingLoggingSheetForMetric: Metric?
    @State private var showingRowOptions = false
    @State private var activeMilestone: MilestoneAnnouncement?

    init() {
        _metrics = QueryDescriptors.allMetrics
        _entries = QueryDescriptors.entriesForStreakLookback()
    }

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -6 + offset, to: today)
        }
    }

    private var habits: [Metric] { metrics.filter { $0.habitType == .positive } }
    private var vices: [Metric] { metrics.filter { $0.habitType == .vice } }

    private var usesInlineNavigation: Bool {
        deviceLayout == .phonePortrait || deviceLayout.isLandscape
    }

    private var usesToolbarAdd: Bool {
        deviceLayout == .phonePortrait
    }

    private var navigationTitle: String {
        "Track"
    }

    var body: some View {
        NavigationStack {
            Group {
                if metrics.isEmpty {
                    EmptyStateView(
                        icon: "plus.circle.fill",
                        title: "No Habits Yet",
                        subtitle: "Build good habits and break bad ones — add your first metric to get started",
                        actionTitle: "Add Your First Habit",
                        action: { viewModel.showAddMetric() }
                    )
                } else {
                    layoutContent
                }
            }
            .themedBackground()
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(usesInlineNavigation ? .inline : .large)
            .toolbar {
                if !metrics.isEmpty && usesToolbarAdd {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.showAddMetric()
                        } label: {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                        }
                        .accessibilityIdentifier(AccessibilityIdentifiers.fabAddMetric)
                        .accessibilityLabel("Add habit or vice")
                    }
                }
            }
            .toolbarBackground(Color.currentBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .adaptiveAddButton(isEmpty: metrics.isEmpty || usesToolbarAdd) {
                viewModel.showAddMetric()
            }
            .onAppear {
                WidgetSyncCoordinator.syncIfEnabled(context: modelContext)
                clampSelectedDate()
                refreshMilestoneBanner()
            }
            .onChange(of: entries.count) { _, _ in
                refreshMilestoneBanner()
            }
            .sheet(item: $viewModel.metricToEdit) { metric in
                EditMetricView(metric: metric)
            }
            .sheet(isPresented: $viewModel.showingAddMetric) {
                AddMetricView()
            }
            .sheet(item: $showingLoggingSheetForMetric, onDismiss: {
                refreshMilestoneBanner()
            }) { metric in
                LoggingSheet(metric: metric, selectedDate: viewModel.selectedDate)
            }
            .alert("Delete Habit", isPresented: $viewModel.showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { viewModel.metricToDelete = nil }
                Button("Delete", role: .destructive) {
                    viewModel.deleteMetric(in: modelContext, entries: entries)
                }
            } message: {
                if let metric = viewModel.metricToDelete {
                    Text("Are you sure you want to delete '\(metric.name)'? This will also delete all associated entries and cannot be undone.")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(TrackFABModifier(isEmpty: metrics.isEmpty, onAdd: { viewModel.showAddMetric() }))
    }

    @ViewBuilder
    private var layoutContent: some View {
        switch deviceLayout {
        case .phonePortrait:
            TrackPhonePortraitLayout(
                metrics: metrics,
                entries: entries,
                habits: habits,
                vices: vices,
                weekDays: weekDays,
                viewModel: viewModel,
                showingRowOptions: $showingRowOptions,
                activeMilestone: activeMilestone,
                usesAccessibilityLayout: dynamicTypeSize.usesAccessibilityLayout,
                onToggle: toggleMetric,
                onLog: { showingLoggingSheetForMetric = $0 },
                onEdit: { viewModel.showEditMetric($0) },
                onDelete: confirmDelete,
                onDismissMilestone: dismissMilestone,
                completedCount: completedCount
            )
        case .phoneLandscape:
            TrackPhoneLandscapeLayout(
                metrics: metrics,
                entries: entries,
                habits: habits,
                vices: vices,
                weekDays: weekDays,
                viewModel: viewModel,
                showingRowOptions: $showingRowOptions,
                activeMilestone: activeMilestone,
                usesAccessibilityLayout: dynamicTypeSize.usesAccessibilityLayout,
                onToggle: toggleMetric,
                onLog: { showingLoggingSheetForMetric = $0 },
                onEdit: { viewModel.showEditMetric($0) },
                onDelete: confirmDelete,
                onDismissMilestone: dismissMilestone,
                completedCount: completedCount
            )
        case .padPortrait:
            TrackPadPortraitLayout(
                metrics: metrics,
                entries: entries,
                habits: habits,
                vices: vices,
                weekDays: weekDays,
                viewModel: viewModel,
                showingRowOptions: $showingRowOptions,
                activeMilestone: activeMilestone,
                usesAccessibilityLayout: dynamicTypeSize.usesAccessibilityLayout,
                onToggle: toggleMetric,
                onLog: { showingLoggingSheetForMetric = $0 },
                onEdit: { viewModel.showEditMetric($0) },
                onDelete: confirmDelete,
                onDismissMilestone: dismissMilestone,
                completedCount: completedCount
            )
        case .padLandscape:
            GeometryReader { geometry in
                TrackPadLandscapeLayout(
                    metrics: metrics,
                    entries: entries,
                    habits: habits,
                    vices: vices,
                    weekDays: weekDays,
                    totalWidth: geometry.size.width,
                    totalHeight: geometry.size.height,
                    viewModel: viewModel,
                    showingRowOptions: $showingRowOptions,
                    activeMilestone: activeMilestone,
                    usesAccessibilityLayout: dynamicTypeSize.usesAccessibilityLayout,
                    onToggle: toggleMetric,
                    onLog: { showingLoggingSheetForMetric = $0 },
                    onEdit: { viewModel.showEditMetric($0) },
                    onDelete: confirmDelete,
                    onDismissMilestone: dismissMilestone,
                    completedCount: completedCount
                )
            }
        }
    }

    private func completedCount(for items: [Metric]) -> Int {
        viewModel.todayCompleted(from: items, entries: entries)
    }

    private func toggleMetric(_ metric: Metric) {
        viewModel.toggleMetricCompletion(metric, in: modelContext, entries: entries)
        refreshMilestoneBanner()
    }

    private func confirmDelete(_ metric: Metric) {
        viewModel.metricToDelete = metric
        viewModel.showingDeleteConfirmation = true
    }

    private func dismissMilestone() {
        guard let activeMilestone else { return }
        MilestoneStore.markAwarded(metricID: activeMilestone.metricID, threshold: activeMilestone.threshold)
        refreshMilestoneBanner()
    }

    private func clampSelectedDate() {
        let today = Calendar.current.startOfDay(for: Date())
        if viewModel.selectedDate > today {
            viewModel.selectedDate = today
        }
    }

    private func refreshMilestoneBanner() {
        guard ProductSurface.showsMilestoneBanners else {
            activeMilestone = nil
            return
        }
        activeMilestone = MilestoneEvaluator.firstPending(
            metrics: metrics,
            entries: entries,
            awardedLookup: MilestoneStore.awarded(for:)
        )
    }
}

private struct TrackFABModifier: ViewModifier {
    @Environment(\.deviceLayout) private var deviceLayout
    let isEmpty: Bool
    let onAdd: () -> Void

    func body(content: Content) -> some View {
        switch deviceLayout {
        case .phonePortrait:
            content
        case .phoneLandscape:
            content
        case .padLandscape:
            content.tabBarFloatingActionButton(isLandscape: true, action: onAdd)
        case .padPortrait:
            content.tabBarFloatingActionButton(isLandscape: false, action: onAdd)
        }
    }
}

#Preview {
    TrackScreen()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
