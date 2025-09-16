import SwiftUI
import SwiftData

// MARK: - MotivationView
/// View for managing motivation content and browsing motivation feed
struct MotivationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = MotivationViewModel()
    @State private var showingAddMetric = false


    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    if metrics.isEmpty {
                        // No habits at all - need to create habits first
                        EmptyStateView(
                            icon: "plus.circle.fill",
                            title: "No Habits Yet",
                            subtitle: "Create your first habit to start building motivation and tracking your progress",
                            actionTitle: "Create Your First Habit",
                            action: {
                                logger.logUserAction("Add habit button tapped from motivation")
                                showingAddMetric = true
                            }
                        )
                    } else if viewModel.viceMetrics(metrics).isEmpty {
                        // Has habits but no vices - need to create a vice
                        EmptyStateView(
                            icon: "heart.text.square",
                            title: "No Vices to Motivate",
                            subtitle: "Add a vice to start building your motivation library and staying accountable",
                            actionTitle: "Add Your First Vice",
                            action: {
                                logger.logUserAction("Add vice button tapped from motivation")
                                showingAddMetric = true
                            }
                        )
                    } else if !viewModel.hasAnyMotivations(metrics, entries: entries) {
                        // Has vices but no motivations - need to add motivations
                        EmptyStateView(
                            icon: "book.closed",
                            title: "No Motivation Yet",
                            subtitle: "Start avoiding your vices and add motivation to build your inspiration library",
                            actionTitle: "Add Your First Motivation",
                            action: {
                                logger.logUserAction("Add motivation button tapped")
                                viewModel.showAddMotivation()
                            }
                        )
                    } else {
                        if geometry.size.width > geometry.size.height {
                            // Landscape layout
                            HStack(spacing: 0) {
                                // Left side - Metric picker
                                VStack(spacing: 16) {
                                    if viewModel.viceMetrics(metrics).count > 1 {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Filter by Vice")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color.currentSecondaryText)

                                            VStack(spacing: 8) {
                                                Button("All Vices") {
                                                    viewModel.selectMetric(nil)
                                                }
                                                .buttonStyle(MetricChipStyle(isSelected: viewModel.selectedMetric == nil))

                                                ForEach(viewModel.viceMetrics(metrics)) { metric in
                                                    Button(metric.name) {
                                                        viewModel.selectMetric(metric)
                                                    }
                                                    .buttonStyle(MetricChipStyle(isSelected: viewModel.selectedMetric?.id == metric.id))
                                                }
                                            }
                                        }
                                    }

                                    Spacer()
                                }
                                .frame(width: min(200, geometry.size.width * 0.25))
                                .padding(.horizontal, 16)
                                .background(Color.currentSecondaryBackground.opacity(0.3))

                                Divider()
                                    .frame(height: geometry.size.height)

                                // Right side - Motivation feed
                                ScrollView {
                                    LazyVStack(spacing: 20) {
                                        // Show primary motivations first with section header
                                        if !viewModel.primaryMotivations(metrics).isEmpty {
                                            VStack(alignment: .leading, spacing: 16) {
                                                HStack {
                                                    Image(systemName: "star.fill")
                                                        .foregroundColor(Color.currentWarning)
                                                        .font(.system(size: 16))
                                                    Text("Primary Motivations")
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundColor(Color.currentText)
                                                    Spacer()
                                                }
                                                .padding(.horizontal, 20)

                                                ForEach(viewModel.primaryMotivations(metrics)) { metric in
                                                    PrimaryMotivationCardView(metric: metric)
                                                }
                                            }
                                        }

                                        // Then show daily motivations with section header
                                        if !viewModel.dailyMotivations(entries).isEmpty {
                                            VStack(alignment: .leading, spacing: 16) {
                                                if !viewModel.primaryMotivations(metrics).isEmpty {
                                                    HStack {
                                                        Image(systemName: "clock")
                                                            .foregroundColor(Color.currentSecondaryText)
                                                            .font(.system(size: 16))
                                                        Text("Daily Motivations")
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(Color.currentText)
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal, 20)
                                                    .padding(.top, 8)
                                                }

                                                ForEach(viewModel.dailyMotivations(entries)) { entry in
                                                    MotivationCardView(entry: entry, metrics: metrics)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                                }
                            }
                        }else {
                            // Portrait layout
                            VStack(spacing: 0) {
                                // Metric picker
                                if viewModel.viceMetrics(metrics).count > 1 {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            Button("All Vices") {
                                                viewModel.selectMetric(nil)
                                            }
                                            .buttonStyle(MetricChipStyle(isSelected: viewModel.selectedMetric == nil))

                                            ForEach(viewModel.viceMetrics(metrics)) { metric in
                                                Button(metric.name) {
                                                    viewModel.selectMetric(metric)
                                                }
                                                .buttonStyle(MetricChipStyle(isSelected: viewModel.selectedMetric?.id == metric.id))
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
                                        if !viewModel.primaryMotivations(metrics).isEmpty {
                                            VStack(alignment: .leading, spacing: 16) {
                                                HStack {
                                                    Image(systemName: "star.fill")
                                                        .foregroundColor(Color.currentWarning)
                                                        .font(.system(size: 16))
                                                    Text("Primary Motivations")
                                                        .font(.system(size: 18, weight: .semibold))
                                                        .foregroundColor(Color.currentText)
                                                    Spacer()
                                                }
                                                .padding(.horizontal, 20)

                                                ForEach(viewModel.primaryMotivations(metrics)) { metric in
                                                    PrimaryMotivationCardView(metric: metric)
                                                }
                                            }
                                        }

                                        // Then show daily motivations with section header
                                        if !viewModel.dailyMotivations(entries).isEmpty {
                                            VStack(alignment: .leading, spacing: 16) {
                                                if !viewModel.primaryMotivations(metrics).isEmpty {
                                                    HStack {
                                                        Image(systemName: "clock")
                                                            .foregroundColor(Color.currentSecondaryText)
                                                            .font(.system(size: 16))
                                                        Text("Daily Motivations")
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(Color.currentText)
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal, 20)
                                                    .padding(.top, 8)
                                                }

                                                ForEach(viewModel.dailyMotivations(entries)) { entry in
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
                }
                .navigationTitle("Motivation")
                .onAppear {
                    logger.info("MotivationView appeared", category: .ui)
                    logger.debug("Motivation data - Vice metrics: \(viewModel.viceMetrics(metrics).count), Motivation entries: \(viewModel.motivationEntries(entries).count)", category: .ui)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.showSettings()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showingAddMotivation) {
                    AddMotivationView(metrics: viewModel.viceMetrics(metrics))
                }
                .sheet(isPresented: $viewModel.showingSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $showingAddMetric) {
                    AddMetricView()
                }
            }
        }
    }
}

#Preview {
    MotivationView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
