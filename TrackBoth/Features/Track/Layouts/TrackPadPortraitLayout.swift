import SwiftUI

// MARK: - TrackPadPortraitLayout
struct TrackPadPortraitLayout: View {
    let metrics: [Metric]
    let entries: [MetricEntry]
    let habits: [Metric]
    let vices: [Metric]
    let weekDays: [Date]
    @Bindable var viewModel: HomeViewModel
    @Binding var showingRowOptions: Bool
    let activeMilestone: MilestoneAnnouncement?
    let usesAccessibilityLayout: Bool
    let onToggle: (Metric) -> Void
    let onLog: (Metric) -> Void
    let onEdit: (Metric) -> Void
    let onDelete: (Metric) -> Void
    let onDismissMilestone: () -> Void
    let completedCount: ([Metric]) -> Int

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    TrackDashboardHeader(
                        weekDays: weekDays,
                        metrics: metrics,
                        entries: entries,
                        selectedDate: $viewModel.selectedDate,
                        isToday: viewModel.isToday,
                        todayCompleted: viewModel.todayCompleted(from: metrics, entries: entries),
                        totalMetrics: metrics.count,
                        showingRowOptions: showingRowOptions,
                        onToggleEdit: { showingRowOptions.toggle() },
                        onGoToToday: { viewModel.goToToday() }
                    )

                    TrackStatsGrid(
                        totalHabits: viewModel.totalHabits(from: metrics),
                        totalVices: viewModel.totalVices(from: metrics),
                        activeStreaks: viewModel.activeStreaks(from: metrics, entries: entries),
                        todayCompleted: viewModel.todayCompleted(from: metrics, entries: entries),
                        totalMetrics: metrics.count,
                        usesWideLayout: true
                    )
                }
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)

                TrackMetricsList(
                    habits: habits,
                    vices: vices,
                    selectedDate: viewModel.selectedDate,
                    showOptions: showingRowOptions,
                    usesAccessibilityLayout: usesAccessibilityLayout,
                    milestone: activeMilestone,
                    onDismissMilestone: onDismissMilestone,
                    completedCount: completedCount,
                    onToggle: onToggle,
                    onLog: onLog,
                    onEdit: onEdit,
                    onDelete: onDelete
                )
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 16)
            .adaptiveScrollInset()
        }
    }
}
