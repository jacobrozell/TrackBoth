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
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }

                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
                .onAppear {
                    if selectedFilter == .all && !metrics.isEmpty {
                        selectedFilter = .all
                    }
                }
            }
        }
    }
}


#Preview {
    ChartsView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
