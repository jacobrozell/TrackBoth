import SwiftUI
import SwiftData

// MARK: - HomeView
/// Main view displaying habit tracking interface with stats, metrics list, and date navigation
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = HomeViewModel()
    
    // MARK: - Computed Properties
    private var totalHabits: Int {
        let count = viewModel.totalHabits(from: metrics)
        logger.debug("Total habits calculated: \(count)", category: .business)
        return count
    }
    
    private var totalVices: Int {
        let count = viewModel.totalVices(from: metrics)
        logger.debug("Total vices calculated: \(count)", category: .business)
        return count
    }
    
    private var activeStreaks: Int {
        let count = viewModel.activeStreaks(from: metrics, entries: entries)
        logger.debug("Active streaks calculated: \(count)", category: .business)
        return count
    }
    
    private var todayCompleted: Int {
        let count = viewModel.todayCompleted(from: metrics, entries: entries)
        logger.debug("Today completed calculated: \(count)", category: .business)
        return count
    }
    
    private var canGoBack: Bool {
        let canGo = viewModel.canGoBack
        logger.debug("Can go back: \(canGo)")
        return canGo
    }
    
    private var isToday: Bool {
        let today = viewModel.isToday
        logger.debug("Is today: \(today)")
        return today
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    if metrics.isEmpty {
                        VStack(spacing: 32) {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(spacing: 8) {
                                    Text("No Habits Yet")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text("Start tracking your habits and vices to build a better you")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                }
                            }
                            
                            Button {
                                logger.logUserAction("Add first habit button tapped")
                                viewModel.showAddMetric()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Your First Habit")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(25)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                    } else {
                        // Stats Overview Section
                        VStack(spacing: 12) {
                            // Date Navigation Header
                            HStack {
                                Button {
                                    logger.logUserAction("Previous day button tapped")
                                    viewModel.goToPreviousDay()
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(canGoBack ? .blue : .gray)
                                }
                                .disabled(!canGoBack)
                                
                                Spacer()
                                
                                Button {
                                    logger.logUserAction("Date picker button tapped")
                                    viewModel.showingDatePicker = true
                                } label: {
                                    VStack(spacing: 2) {
                                        Text(isToday ? "Today" : DateFormatter.dayFormatter.string(from: viewModel.selectedDate))
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(DateFormatter.dateFormatter.string(from: viewModel.selectedDate))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    logger.logUserAction("Next day button tapped")
                                    viewModel.goToNextDay()
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            // Today Button (right-aligned like Goals)
                            if !isToday {
                                HStack {
                                    Spacer()
                                    Button("Today") {
                                        logger.logUserAction("Today button tapped")
                                        viewModel.goToToday()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            // Quick Stats
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "Habits",
                                    value: "\(totalHabits)",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                                
                                StatCard(
                                    title: "Vices",
                                    value: "\(totalVices)",
                                    icon: "xmark.circle.fill",
                                    color: .red
                                )
                                
                                StatCard(
                                    title: "Streaks",
                                    value: "\(activeStreaks)",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                                
                                StatCard(
                                    title: "Today",
                                    value: "\(todayCompleted)/\(metrics.count)",
                                    icon: "calendar",
                                    color: .blue
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 16)
                        .background(Color(.systemGray6))
                        
                        // Habits List
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(metrics) { metric in
                                    UnifiedMetricRowView.enhanced(metric: metric, selectedDate: viewModel.selectedDate)
                                        .contextMenu {
                                            Button {
                                                viewModel.showEditMetric(metric)
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            Button(role: .destructive) {
                                                viewModel.showDeleteConfirmation(for: metric)
                                            } label: {
                                                Label("Delete Habit", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .overlay(alignment: .bottomTrailing) {
                            FloatingActionButton {
                                logger.logUserAction("Floating action button tapped")
                                viewModel.showAddMetric()
                            }
                        }
                    }
                }
                .navigationTitle("QuickLog")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            logger.logUserAction("Settings button tapped")
                            viewModel.showSettings()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .onAppear {
                    logger.info("HomeView appeared")
                    logger.debug("Metrics count: \(metrics.count), Entries count: \(entries.count)", category: .data)
                }
                .sheet(isPresented: $viewModel.showingAddMetric) {
                    AddMetricView()
                        .onAppear {
                            logger.info("AddMetricView sheet presented")
                        }
                }
                .sheet(item: $viewModel.metricToEdit) { metric in
                    EditMetricView(metric: metric)
                        .onAppear {
                            logger.info("EditMetricView sheet presented - Metric: \(metric.name)")
                        }
                }
                .sheet(isPresented: $viewModel.showingSettings) {
                    SettingsView()
                        .onAppear {
                            logger.info("SettingsView sheet presented")
                        }
                }
                .sheet(isPresented: $viewModel.showingDatePicker) {
                    DatePickerSheet(selectedDate: $viewModel.selectedDate)
                        .onAppear {
                            logger.info("DatePickerSheet presented")
                        }
                }
                .alert("Delete Habit", isPresented: $viewModel.showingDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {
                        viewModel.metricToDelete = nil
                    }
                    Button("Delete", role: .destructive) {
                        viewModel.deleteMetric(in: modelContext, entries: entries)
                    }
                } message: {
                    if let metric = viewModel.metricToDelete {
                        Text("Are you sure you want to delete '\(metric.name)'? This will also delete all associated entries and cannot be undone.")
                    }
                }
                .onAppear {
                    // Clean up any duplicate or empty entries on app launch
                    MetricEntry.cleanupEmptyEntries(in: modelContext, entries: entries)
                    // No migration needed; goals are embedded
                    try? modelContext.save()
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}