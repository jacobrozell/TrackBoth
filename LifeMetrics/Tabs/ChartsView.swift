import SwiftUI
import SwiftData
import UIKit

// MARK: - ChartsView
/// View displaying various chart visualizations of habit tracking data
struct ChartsView: View {
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = ChartsViewModel()
    @State private var showingExportSheet = false
    @State private var exportData: Data?
    @State private var exportFormat: ChartExportUtility.ExportFormat = .png
    @State private var isExporting = false
    @Environment(\.modelContext) private var modelContext

    init() {
        _metrics = QueryDescriptors.allMetrics
        _entries = QueryDescriptors.entriesForChartLookback()
    }

    var body: some View {
        MetricTabShell(title: "Charts") { geometry, usesSplit in
            Group {
                if metrics.isEmpty {
                    ChartsEmptyStateView()
                } else if usesSplit {
                    LandscapeSplitLayout(
                        totalWidth: geometry.size.width,
                        totalHeight: geometry.size.height,
                        sidebar: {
                            ChartControlsView(
                                selectedFilter: $viewModel.selectedFilter,
                                selectedChartType: $viewModel.selectedChartType,
                                metrics: metrics,
                                isLandscape: true
                            )
                        },
                        content: {
                            ChartContentView(
                                selectedChartType: viewModel.selectedChartType,
                                selectedFilter: viewModel.selectedFilter,
                                entries: entries,
                                metrics: metrics
                            )
                        }
                    )
                } else {
                    VStack(spacing: 0) {
                        ChartControlsView(
                            selectedFilter: $viewModel.selectedFilter,
                            selectedChartType: $viewModel.selectedChartType,
                            metrics: metrics,
                            isLandscape: false
                        )

                        Divider()

                        ChartContentView(
                            selectedChartType: viewModel.selectedChartType,
                            selectedFilter: viewModel.selectedFilter,
                            entries: entries,
                            metrics: metrics
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !metrics.isEmpty {
                    Menu {
                        Button("Export as PNG") {
                            exportFormat = .png
                            exportCurrentChart()
                        }
                        .disabled(isExporting)

                        Button("Export as PDF") {
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
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            if let exportData = exportData {
                ShareSheet(activityItems: createShareItems(from: exportData))
                    .onDisappear {
                        cleanupTempFiles()
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
            let fileName = "TrackBoth_Chart_\(Date().timeIntervalSince1970).pdf"
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
                if file.lastPathComponent.hasPrefix("TrackBoth_Chart_") && file.pathExtension == "pdf" {
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
        ChartCopy.title(chartType: viewModel.selectedChartType, filter: viewModel.selectedFilter)
    }
    
    @ViewBuilder
    private func getCurrentChartView() -> some View {
        switch viewModel.selectedChartType {
        case .line:
            LineChartView(
                filter: viewModel.selectedFilter,
                entries: entries,
                metrics: metrics
            )
        case .bar:
            BarChartView(
                filter: viewModel.selectedFilter,
                entries: entries,
                metrics: metrics
            )
        case .heatmap:
            HeatmapView(
                filter: viewModel.selectedFilter,
                entries: entries,
                metrics: metrics
            )
        case .quantity:
            QuantityChartView(
                filter: viewModel.selectedFilter,
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
