import SwiftUI
import SwiftData

// MARK: - MotivationView
/// View for managing motivation content and browsing motivation feed
struct MotivationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var selectedMetric: Metric?
    @State private var showingAddMotivation = false
    @State private var showingAddMetric = false
    @State private var showingSettings = false

    private var viceMetrics: [Metric] {
        metrics.filter { $0.safeHabitType == .vice }
    }

    private var motivationEntries: [MetricEntry] {
        let filteredEntries = entries.filter { entry in
            entry.motivation != nil && !entry.motivation!.isEmpty
        }

        if let selectedMetric = selectedMetric {
            return filteredEntries.filter { $0.metricID == selectedMetric.id }
        }

        return filteredEntries
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if viceMetrics.isEmpty {
                        VStack(spacing: 24) {
                            // Icon with background
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "heart.text.square")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 12) {
                                Text("No Vices to Motivate")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text("Add a vice to start building your motivation library")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 40)
                    } else if motivationEntries.isEmpty {
                        VStack(spacing: 24) {
                            // Icon with background
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "book.closed")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 12) {
                                Text("No Motivation Yet")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.primary)

                                Text("Start avoiding your vices and add motivation to build your inspiration library")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 40)
                    } else {
                        VStack(spacing: 0) {
                            // Metric picker
                            if viceMetrics.count > 1 {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        Button("All Vices") {
                                            selectedMetric = nil
                                        }
                                        .buttonStyle(MetricChipStyle(isSelected: selectedMetric == nil))

                                        ForEach(viceMetrics) { metric in
                                            Button(metric.name) {
                                                selectedMetric = metric
                                            }
                                            .buttonStyle(MetricChipStyle(isSelected: selectedMetric?.id == metric.id))
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.vertical, 8)
                            }

                            // Motivation feed with better spacing
                            ScrollView {
                                LazyVStack(spacing: 20) {
                                    // Show primary motivations first with section header
                                    let primaryMotivations = viceMetrics.filter { 
                                        $0.primaryMotivation != nil && !$0.primaryMotivation!.isEmpty 
                                    }
                                    if !primaryMotivations.isEmpty {
                                        VStack(alignment: .leading, spacing: 16) {
                                            HStack {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                                    .font(.system(size: 16))
                                                Text("Primary Motivations")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.primary)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 20)
                                            
                                            ForEach(primaryMotivations) { metric in
                                                PrimaryMotivationCardView(metric: metric)
                                            }
                                        }
                                    }

                                    // Then show daily motivations with section header
                                    let dailyMotivations = motivationEntries.filter { 
                                        $0.motivation != nil && !$0.motivation!.isEmpty 
                                    }.sorted { $0.date > $1.date }
                                    if !dailyMotivations.isEmpty {
                                        VStack(alignment: .leading, spacing: 16) {
                                            if !primaryMotivations.isEmpty {
                                                HStack {
                                                    Image(systemName: "clock")
                                                        .foregroundColor(.secondary)
                                                        .font(.system(size: 16))
                                                    Text("Daily Motivations")
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                }
                                                .padding(.horizontal, 20)
                                                .padding(.top, 8)
                                            }
                                            
                                            ForEach(dailyMotivations) { entry in
                                                MotivationCardView(entry: entry, metrics: metrics)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 20)
                            }
                        }
                    }
                }
                .navigationTitle("Motivation")
                .onAppear {
                    logger.info("MotivationView appeared", category: .ui)
                    logger.debug("Motivation data - Vice metrics: \(viceMetrics.count), Motivation entries: \(motivationEntries.count)", category: .ui)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showingAddMotivation) {
                    AddMotivationView(metrics: viceMetrics)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
            }
        }
    }
}

#Preview {
    MotivationView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}