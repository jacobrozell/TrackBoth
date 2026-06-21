import SwiftUI
import SwiftData

// MARK: - HistoryView
struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HistoryViewContent(viewModel: viewModel, dynamicTypeSize: dynamicTypeSize)
    }
}

// MARK: - HistoryViewContent
private struct HistoryViewContent: View {
    @Bindable var viewModel: HistoryViewModel
    let dynamicTypeSize: DynamicTypeSize
    @Environment(\.deviceLayout) private var deviceLayout

    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @Query private var streakEntries: [MetricEntry]

    init(viewModel: HistoryViewModel, dynamicTypeSize: DynamicTypeSize) {
        self.viewModel = viewModel
        self.dynamicTypeSize = dynamicTypeSize
        _metrics = QueryDescriptors.allMetrics
        _entries = QueryDescriptors.entriesInMonth(of: viewModel.selectedDate)
        _streakEntries = QueryDescriptors.entriesForStreakLookback()
    }

    var body: some View {
        NavigationStack {
            Group {
                if metrics.isEmpty {
                    noHabitsEmptyState
                } else if !metrics.contains(where: \.hasBeenLogged) {
                    noHistoryEmptyState
                } else {
                    historyLayout
                }
            }
            .themedBackground()
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.currentBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            logger.info("HistoryView appeared", category: .ui)
        }
        .sheet(isPresented: $viewModel.showingAddMetric) {
            AddMetricView()
        }
    }

    @ViewBuilder
    private var historyLayout: some View {
        switch deviceLayout {
        case .padLandscape:
            GeometryReader { geometry in
                HistoryPadLandscapeLayout(
                    viewModel: viewModel,
                    metrics: metrics,
                    entries: entries,
                    streakEntries: streakEntries,
                    dynamicTypeSize: dynamicTypeSize,
                    totalWidth: geometry.size.width,
                    totalHeight: geometry.size.height
                )
            }
        default:
            HistoryCompactLayout(
                viewModel: viewModel,
                metrics: metrics,
                entries: entries,
                streakEntries: streakEntries,
                dynamicTypeSize: dynamicTypeSize
            )
        }
    }

    private var noHabitsEmptyState: some View {
        EmptyStateView(
            icon: "plus.circle.fill",
            title: "No Habits or Vices Yet",
            subtitle: "Add what you want to build or break — then log each day on Track.",
            actionTitle: "Add Your First",
            action: { viewModel.showAddMetric() }
        )
        .background(Color.currentBackground)
    }

    private var noHistoryEmptyState: some View {
        EmptyStateView(
            icon: "hand.tap.fill",
            title: "No Logs Yet",
            subtitle: "Your habits and vices are ready. Go to Track and tap each row to log today.",
            actionTitle: "Go to Track",
            action: { AppEvent.post(.switchToTrack) }
        )
        .background(Color.currentBackground)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
