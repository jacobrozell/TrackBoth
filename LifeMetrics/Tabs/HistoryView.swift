import SwiftUI
import SwiftData

// MARK: - HistoryView
struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HistoryViewContent(viewModel: viewModel, dynamicTypeSize: dynamicTypeSize)
            .id(historyMonthKey(for: viewModel.selectedDate))
    }

    private func historyMonthKey(for date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return "\(year)-\(month)"
    }
}

// MARK: - HistoryViewContent
private struct HistoryViewContent: View {
    @Bindable var viewModel: HistoryViewModel
    let dynamicTypeSize: DynamicTypeSize

    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]

    init(viewModel: HistoryViewModel, dynamicTypeSize: DynamicTypeSize) {
        self.viewModel = viewModel
        self.dynamicTypeSize = dynamicTypeSize
        _metrics = QueryDescriptors.allMetrics
        _entries = QueryDescriptors.entriesInMonth(of: viewModel.selectedDate)
    }

    var body: some View {
        MetricTabShell(title: "History") { geometry, usesSplit in
            Group {
                if metrics.isEmpty {
                    noHabitsEmptyState
                } else if !metrics.contains(where: \.hasBeenLogged) {
                    noHistoryEmptyState
                } else {
                    FilteredSplitTabLayout(
                        geometry: geometry,
                        usesSplit: usesSplit,
                        filterMetrics: metrics,
                        selectedFilter: $viewModel.selectedFilter
                    ) {
                        historyScrollContent(idPrefix: usesSplit ? "landscape" : "portrait", geometry: geometry)
                    }
                }
            }
        }
        .onAppear {
            logger.info("HistoryView appeared", category: .ui)
        }
        .sheet(isPresented: $viewModel.showingAddMetric) {
            AddMetricView()
        }
    }

    private var noHabitsEmptyState: some View {
        EmptyStateView(
            icon: "plus.circle.fill",
            title: "No Habits Yet",
            subtitle: "Start tracking your habits and vices to see your history",
            actionTitle: "Add Your First Habit",
            action: { viewModel.showAddMetric() }
        )
        .background(Color.currentBackground)
    }

    private var noHistoryEmptyState: some View {
        EmptyStateView(
            icon: "calendar.badge.exclamationmark",
            title: "No History Yet",
            subtitle: "Start logging your habits and vices to build your history",
            actionTitle: "Start Logging",
            action: { viewModel.showAddMetric() }
        )
        .background(Color.currentBackground)
    }

    @ViewBuilder
    private func historyScrollContent(idPrefix: String, geometry: GeometryProxy) -> some View {
        let recentEntries = viewModel.recentEntries(entries, metrics: metrics)

        ScrollView {
            LazyVStack(
                spacing: 16,
                pinnedViews: dynamicTypeSize.usesAccessibilityLayout ? [] : [.sectionHeaders]
            ) {
                Section(header: AdaptiveSectionHeader(
                    title: "Calendar View",
                    subtitle: "Monthly overview of your progress",
                    icon: "calendar",
                    iconColor: Color.currentPrimary
                )) {
                    CalendarGridView(
                        entries: viewModel.calendarEntries(entries, metrics: metrics),
                        selectedFilter: viewModel.selectedFilter,
                        selectedDate: $viewModel.selectedDate,
                        metrics: metrics
                    )
                    .padding(.horizontal, 16)
                }

                if !recentEntries.isEmpty {
                    Section(header: AdaptiveSectionHeader(
                        title: "Recent Entries",
                        subtitle: "Your latest activity",
                        icon: "clock",
                        iconColor: Color.currentSecondaryText
                    )) {
                        ForEach(recentEntries.prefix(20)) { entry in
                            HistoryEntryCardView(entry: entry, metrics: metrics)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .adaptiveScrollInset()
        }
        .id("history-\(idPrefix)-\(geometry.size.width)-\(geometry.size.height)")
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
