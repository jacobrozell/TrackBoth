import SwiftUI
import SwiftData
import UIKit

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
    @State private var isExporting = false
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geometry in
                    if metrics.isEmpty {
                        ChartsEmptyStateView()
                    } else {
                        if geometry.size.width > geometry.size.height {
                            // Landscape layout
                            HStack(spacing: 0) {
                                // Left side - Controls
                                VStack {
                                    ChartControlsView(
                                        selectedFilter: $selectedFilter,
                                        selectedChartType: $selectedChartType,
                                        metrics: metrics,
                                        isLandscape: true
                                    )
                                    Spacer()
                                }
                                .frame(width: min(320, geometry.size.width * 0.35))
                                .background(Color(.systemGray6).opacity(0.3))
                                
                                Divider()
                                    .frame(height: geometry.size.height)
                                
                                // Right side - Chart content
                                ChartContentView(
                                    selectedChartType: selectedChartType,
                                    selectedFilter: selectedFilter,
                                    entries: entries,
                                    metrics: metrics
                                )
                            }
                        } else {
                            // Portrait layout
                            VStack(spacing: 0) {
                                // Controls
                                ChartControlsView(
                                    selectedFilter: $selectedFilter,
                                    selectedChartType: $selectedChartType,
                                    metrics: metrics,
                                    isLandscape: false
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
                }
                .navigationTitle("Charts")
                .onAppear {
                    logger.info("ChartsView appeared", category: .ui)
                    logger.debug("Charts data - Metrics: \(metrics.count), Entries: \(entries.count), Filter: \(selectedFilter), ChartType: \(selectedChartType)", category: .ui)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if metrics.isEmpty {
                            Button("Try Demo Data") {
                                logger.logUserAction("Generate demo data")
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
                                        logger.logUserAction("Export chart as PNG")
                                        exportFormat = .png
                                        exportCurrentChart()
                                    }
                                    .disabled(isExporting)
                                    
                                    Button("Export as PDF") {
                                        logger.logUserAction("Export chart as PDF")
                                        exportFormat = .pdf
                                        exportCurrentChart()
                                    }
                                    .disabled(isExporting)
                                } label: {
                                    if isExporting {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                }
                                .disabled(isExporting)
                            }
                            
                            Button {
                                logger.logUserAction("Show settings")
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
                        ShareSheet(activityItems: createShareItems(from: exportData))
                            .onDisappear {
                                cleanupTempFiles()
                            }
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
    
    private func createShareItems(from data: Data) -> [Any] {
        switch exportFormat {
        case .png:
            // For PNG, create UIImage which works better with UIActivityViewController
            if let image = UIImage(data: data) {
                logger.info("Created UIImage for PNG sharing", category: .ui)
                return [image]
            } else {
                logger.error("Failed to create UIImage from PNG data", category: .ui)
                return [data]
            }
        case .pdf:
            // For PDF, use temporary file
            let fileName = "QuickLog_Chart_\(Date().timeIntervalSince1970).pdf"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try data.write(to: tempURL)
                logger.info("Created temporary PDF file for sharing: \(fileName)", category: .ui)
                return [tempURL]
            } catch {
                logger.error("Failed to create temporary PDF file for sharing: \(error)", category: .ui)
                return [data] // Fallback to raw data
            }
        }
    }
    
    private func cleanupTempFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            for file in tempFiles {
                if file.lastPathComponent.hasPrefix("QuickLog_Chart_") && file.pathExtension == "pdf" {
                    try FileManager.default.removeItem(at: file)
                    logger.info("Cleaned up temporary PDF file: \(file.lastPathComponent)", category: .ui)
                }
            }
        } catch {
            logger.error("Failed to cleanup temporary files: \(error)", category: .ui)
        }
    }
    
    private func exportCurrentChart() {
        logger.info("Starting chart export - Format: \(exportFormat)", category: .ui)
        let startTime = Date()
        
        isExporting = true
        
        // Create view on main thread
        let chartTitle = getChartTitle()
        let chartView = getCurrentChartView()
        
        let exportView = ChartExportWrapper(
            chartView: chartView,
            title: chartTitle
        )
        
        // Perform export on background queue to avoid blocking UI
        Task {
            let result = await ChartExportUtility.exportViewAsync(
                exportView,
                format: exportFormat,
                size: CGSize(width: 800, height: 600)
            )
            
            await MainActor.run {
                self.isExporting = false
                self.exportData = result
                
                let duration = Date().timeIntervalSince(startTime)
                logger.logPerformance("Chart export", duration: duration)
                logger.info("Chart export completed - Format: \(exportFormat), Title: \(chartTitle), Success: \(result != nil)", category: .ui)
                
                if let data = result {
                    logger.info("Chart export successful - Data size: \(data.count) bytes", category: .ui)
                    self.showingExportSheet = true
                } else {
                    logger.error("Chart export failed - no data generated", category: .ui)
                }
            }
        }
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
