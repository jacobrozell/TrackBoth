import SwiftUI
import SwiftData

// MARK: - ChartsView
/// View displaying various chart visualizations of habit tracking data
struct ChartsView: View {
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var selectedFilter: MetricFilter = .all
    @State private var selectedChartType: ChartType = .line
    @State private var showingAddMetric = false
    @State private var showingSettings = false
    @State private var showingExportSheet = false
    @State private var exportData: Data?
    @State private var exportFormat: ChartExportUtility.ExportFormat = .png
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if metrics.isEmpty {
                        ChartsEmptyStateView()
                    } else {
                        VStack(spacing: 0) {
                            // Controls
                            ChartControlsView(
                                selectedFilter: $selectedFilter,
                                selectedChartType: $selectedChartType,
                                metrics: metrics
                            )

                            Divider()

                            // Chart content
                            ChartContentView(
                                selectedChartType: selectedChartType,
                                selectedFilter: selectedFilter,
                                entries: entries,
                                metrics: metrics
                            )
                        }
                    }
                }
                .navigationTitle("Charts")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if metrics.isEmpty {
                            Button("Try Demo Data") {
                                DemoDataGenerator.generateDemoData(modelContext: modelContext)
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            if !metrics.isEmpty {
                                Menu {
                                    Button("Export as PNG") {
                                        exportFormat = .png
                                        exportCurrentChart()
                                    }
                                    
                                    Button("Export as PDF") {
                                        exportFormat = .pdf
                                        exportCurrentChart()
                                    }
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                            
                            Button {
                                showingSettings = true
                            } label: {
                                Image(systemName: "gear")
                            }
                        }
                    }
                }

                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $showingExportSheet) {
                    if let exportData = exportData {
                        ShareSheet(activityItems: [exportData])
                    }
                }
                .onAppear {
                    if selectedFilter == .all && !metrics.isEmpty {
                        selectedFilter = .all
                    }
                }
            }
        }
    }
    
    // MARK: - Export Functions
    
    private func exportCurrentChart() {
        let chartTitle = getChartTitle()
        let chartView = getCurrentChartView()
        
        let exportView = ChartExportWrapper(
            chartView: chartView,
            title: chartTitle
        )
        
        exportData = ChartExportUtility.exportView(
            exportView,
            format: exportFormat,
            size: CGSize(width: 800, height: 600)
        )
        
        showingExportSheet = true
    }
    
    private func getChartTitle() -> String {
        switch selectedChartType {
        case .line:
            switch selectedFilter {
            case .allVices: return "30-Day Avoidance Trend"
            case .allHabits: return "30-Day Completion Trend"
            case .all: return "30-Day Progress Trend"
            case .specific(let metric):
                return metric.safeHabitType == .vice ? "30-Day Avoidance Trend" : "30-Day Completion Trend"
            }
        case .bar:
            switch selectedFilter {
            case .allVices: return "Weekly Avoidance"
            case .allHabits: return "Weekly Completion"
            case .all: return "Weekly Progress"
            case .specific(let metric):
                return metric.safeHabitType == .vice ? "Weekly Avoidance" : "Weekly Completion"
            }
        case .heatmap:
            switch selectedFilter {
            case .allVices: return "90-Day Avoidance Heatmap"
            case .allHabits: return "90-Day Completion Heatmap"
            case .all: return "90-Day Progress Heatmap"
            case .specific(let metric):
                return metric.safeHabitType == .vice ? "90-Day Avoidance Heatmap" : "90-Day Completion Heatmap"
            }
        case .quantity:
            switch selectedFilter {
            case .allVices: return "Quantity Tracking - Vices"
            case .allHabits: return "Quantity Tracking - Habits"
            case .all: return "Quantity Tracking - All"
            case .specific(let metric):
                return "Quantity Tracking - \(metric.name)"
            }
        }
    }
    
    @ViewBuilder
    private func getCurrentChartView() -> some View {
        switch selectedChartType {
        case .line:
            LineChartView(
                filter: selectedFilter,
                entries: entries,
                metrics: metrics
            )
        case .bar:
            BarChartView(
                filter: selectedFilter,
                entries: entries,
                metrics: metrics
            )
        case .heatmap:
            HeatmapView(
                filter: selectedFilter,
                entries: entries,
                metrics: metrics
            )
        case .quantity:
            QuantityChartView(
                filter: selectedFilter,
                entries: entries,
                metrics: metrics
            )
        }
    }
}


#Preview {
    ChartsView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
