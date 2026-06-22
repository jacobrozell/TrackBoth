import SwiftUI
import SwiftData
import UIKit

// MARK: - InsightsView
/// Combined calendar history + trend charts.
struct InsightsView: View {
    @State private var viewModel = HistoryViewModel()
    @State private var selectedChartType: ChartType = .line
    @State private var mode: InsightsViewMode = .calendar
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.deviceLayout) private var deviceLayout

    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @Query private var streakEntries: [MetricEntry]

    @State private var showingExportSheet = false
    @State private var exportData: Data?
    @State private var exportFormat: ChartExportUtility.ExportFormat = .png
    @State private var isExporting = false
    @State private var showingExportError = false

    init() {
        _metrics = QueryDescriptors.allMetrics
        _entries = QueryDescriptors.entriesForChartLookback()
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
                    insightsLayout
                }
            }
            .themedBackground()
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.currentBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !metrics.isEmpty, metrics.contains(where: \.hasBeenLogged) {
                        exportMenu
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            logger.info("InsightsView appeared", category: .ui)
        }
        .sheet(isPresented: $viewModel.showingAddMetric) {
            AddMetricView()
        }
        .sheet(isPresented: $showingExportSheet) {
            if let exportData {
                ShareSheet(activityItems: createShareItems(from: exportData))
                    .onDisappear { cleanupTempFiles() }
            }
        }
        .alert("Export Failed", isPresented: $showingExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This chart could not be exported. Try again, or use a different chart type.")
        }
    }

    @ViewBuilder
    private var insightsLayout: some View {
        switch deviceLayout {
        case .padLandscape:
            GeometryReader { geometry in
                InsightsPadLandscapeLayout(
                    selectedChartType: $selectedChartType,
                    viewModel: viewModel,
                    metrics: metrics,
                    monthEntries: monthEntries,
                    chartEntries: entries,
                    streakEntries: streakEntries,
                    dynamicTypeSize: dynamicTypeSize,
                    totalWidth: geometry.size.width,
                    totalHeight: geometry.size.height
                )
            }
        default:
            InsightsCompactLayout(
                mode: $mode,
                selectedChartType: $selectedChartType,
                viewModel: viewModel,
                metrics: metrics,
                monthEntries: monthEntries,
                chartEntries: entries,
                streakEntries: streakEntries,
                dynamicTypeSize: dynamicTypeSize
            )
        }
    }

    /// Entries within the month of the selected calendar date.
    private var monthEntries: [MetricEntry] {
        let calendar = CalendarHelper.calendar
        guard let interval = calendar.dateInterval(of: .month, for: viewModel.selectedDate) else {
            return entries
        }
        return entries.filter { $0.date >= interval.start && $0.date < interval.end }
    }

    @ViewBuilder
    private var exportMenu: some View {
        Menu {
            Button("Export chart as PNG") {
                exportFormat = .png
                exportCurrentChart()
            }
            .disabled(isExporting)

            Button("Export chart as PDF") {
                exportFormat = .pdf
                exportCurrentChart()
            }
            .disabled(isExporting)
        } label: {
            if isExporting {
                ProgressView().scaleEffect(0.8)
            } else {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .disabled(isExporting)
        .accessibilityLabel("Export chart")
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

    // MARK: - Chart export

    private func exportCurrentChart() {
        isExporting = true
        let chartTitle = ChartCopy.title(chartType: selectedChartType, filter: viewModel.selectedFilter)
        let chartView = chartExportView

        let exportView = ChartExportWrapper(chartView: chartView, title: chartTitle)

        Task {
            let result = await ChartExportUtility.exportViewAsync(
                exportView,
                format: exportFormat,
                size: CGSize(width: 800, height: 600)
            )

            await MainActor.run {
                isExporting = false
                exportData = result
                if result != nil {
                    showingExportSheet = true
                } else {
                    showingExportError = true
                }
            }
        }
    }

    @ViewBuilder
    private var chartExportView: some View {
        switch selectedChartType {
        case .line:
            LineChartView(filter: viewModel.selectedFilter, entries: entries, metrics: metrics)
        case .bar:
            BarChartView(filter: viewModel.selectedFilter, entries: entries, metrics: metrics)
        case .heatmap:
            HeatmapView(filter: viewModel.selectedFilter, entries: entries, metrics: metrics)
        case .quantity:
            QuantityChartView(filter: viewModel.selectedFilter, entries: entries, metrics: metrics)
        }
    }

    private func createShareItems(from data: Data) -> [Any] {
        switch exportFormat {
        case .png:
            if let image = UIImage(data: data) { return [image] }
            return [data]
        case .pdf:
            let fileName = "TrackBoth_Chart_\(Date().timeIntervalSince1970).pdf"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            do {
                try data.write(to: tempURL)
                return [tempURL]
            } catch {
                return [data]
            }
        }
    }

    private func cleanupTempFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        guard let tempFiles = try? FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil) else {
            return
        }
        for file in tempFiles where file.lastPathComponent.hasPrefix("TrackBoth_Chart_") && file.pathExtension == "pdf" {
            try? FileManager.default.removeItem(at: file)
        }
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
