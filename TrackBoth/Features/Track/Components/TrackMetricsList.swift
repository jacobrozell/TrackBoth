import SwiftUI
import SwiftData

// MARK: - TrackMetricsList
struct TrackMetricsList: View {
    let habits: [Metric]
    let vices: [Metric]
    let selectedDate: Date
    let showOptions: Bool
    let usesAccessibilityLayout: Bool
    let milestone: MilestoneAnnouncement?
    let onDismissMilestone: (() -> Void)?
    let completedCount: ([Metric]) -> Int
    let onToggle: (Metric) -> Void
    let onLog: (Metric) -> Void
    let onEdit: (Metric) -> Void
    let onDelete: (Metric) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        LazyVStack(
            spacing: 16,
            pinnedViews: usesAccessibilityLayout ? [] : [.sectionHeaders]
        ) {
            if ProductSurface.showsMilestoneBanners,
               let milestone,
               let onDismissMilestone {
                MilestoneBannerView(announcement: milestone, onDismiss: onDismissMilestone)
                    .padding(.horizontal, 4)
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .move(edge: .top).combined(with: .opacity)
                    )
            }

            if !habits.isEmpty {
                Section(header: TrackSectionHeader(
                    title: "Habits",
                    completedCount: completedCount(habits),
                    totalCount: habits.count
                )) {
                    ForEach(habits) { metric in
                        metricRow(for: metric)
                    }
                }
            }

            if !vices.isEmpty {
                Section(header: TrackSectionHeader(
                    title: "Vices",
                    completedCount: completedCount(vices),
                    totalCount: vices.count
                )) {
                    ForEach(vices) { metric in
                        metricRow(for: metric)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .trackBothAnimation(TrackBothMotion.celebrationSpring, value: milestone?.metricID, reduceMotion: reduceMotion)
    }

    private func metricRow(for metric: Metric) -> some View {
        TrackMetricRow(
            metric: metric,
            selectedDate: selectedDate,
            showOptions: showOptions,
            onToggle: { onToggle(metric) },
            onLog: { onLog(metric) },
            onEdit: { onEdit(metric) },
            onDelete: { onDelete(metric) }
        )
    }
}
