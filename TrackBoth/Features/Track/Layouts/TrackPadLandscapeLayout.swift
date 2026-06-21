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

            Spacer(minLength: 0)

            TrackWeekCalendar(
                days: weekDays,
                selectedDate: viewModel.selectedDate,
                usesAccessibilityLayout: usesAccessibilityLayout,
                onSelect: { viewModel.selectedDate = $0 }
            )
        }
        .padding()
    }

    private var contentPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Text(weekHeaderTitle)
                    .h4()
                    .foregroundColor(Color.currentText)
                Spacer()
                Button(showingRowOptions ? "Done" : "Edit") {
                    showingRowOptions.toggle()
                }
                .caption()
                .foregroundColor(Color.currentPrimary)
                if !viewModel.isToday {
                    Button("Today") { viewModel.goToToday() }
                        .caption()
                        .foregroundColor(Color.currentPrimary)
                }
            }
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
        }
    }

    private var weekHeaderTitle: String {
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d"
        return df.string(from: viewModel.selectedDate)
    }
}
