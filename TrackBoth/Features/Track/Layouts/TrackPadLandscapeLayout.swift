import SwiftUI

// MARK: - TrackPadLandscapeLayout
struct TrackPadLandscapeLayout: View {
    let metrics: [Metric]
    let entries: [MetricEntry]
    let habits: [Metric]
    let vices: [Metric]
    let weekDays: [Date]
    let totalWidth: CGFloat
    let totalHeight: CGFloat
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
        LandscapeSplitLayout(
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            sidebar: { sidebarPanel },
            content: { contentPanel }
        )
    }

    private var sidebarPanel: some View {
        ScrollView {
            VStack(spacing: 12) {
                TrackStatsGrid(
                    totalHabits: viewModel.totalHabits(from: metrics),
                    totalVices: viewModel.totalVices(from: metrics),
                    activeStreaks: viewModel.activeStreaks(from: metrics, entries: entries),
                    todayCompleted: viewModel.todayCompleted(from: metrics, entries: entries),
                    totalMetrics: metrics.count
                )
                .padding(.horizontal, 8)
                .padding(.top, 8)

                TrackWeekCalendar(
                    days: weekDays,
                    selectedDate: viewModel.selectedDate,
                    metrics: metrics,
                    entries: entries,
                    usesAccessibilityLayout: usesAccessibilityLayout,
                    onSelect: { viewModel.selectedDate = $0 }
                )
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }

    private var contentPanel: some View {
        VStack(spacing: 0) {
            TrackDashboardHeader(
                weekDays: weekDays,
                metrics: metrics,
                entries: entries,
                selectedDate: $viewModel.selectedDate,
                isToday: viewModel.isToday,
                todayCompleted: viewModel.todayCompleted(from: metrics, entries: entries),
                totalMetrics: metrics.count,
                showingRowOptions: showingRowOptions,
                usesAccessibilityLayout: usesAccessibilityLayout,
                showsWeekCalendar: false,
                onToggleEdit: { showingRowOptions.toggle() },
                onGoToToday: { viewModel.goToToday() }
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            ScrollView {
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
            }
            .adaptiveScrollInset()
        }
    }
}
