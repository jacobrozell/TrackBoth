import SwiftUI
import SwiftData

// MARK: - HomeView
/// Redesigned Home view per homePageRedesign TODO/spec
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]

    // Reuse existing VM for business logic and state
    @State private var viewModel = HomeViewModel()

    // UI State
    @State private var showingLoggingSheetForMetric: Metric? = nil
    @State private var showingRowOptions: Bool = false
    @State private var hasDemoData: Bool = DemoDataGenerator.hasDemoData()
    @StateObject private var themeManager = ThemeManager.shared

    // MARK: - Derived values
    private var weekDays: [Date] {
        // Show last 7 days ending today (no future dates)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -6 + offset, to: today)
        }
    }

    private var habits: [Metric] { metrics.filter { $0.habitType == .positive } }
    private var vices: [Metric] { metrics.filter { $0.habitType == .vice } }

    private func completedCount(for metrics: [Metric]) -> Int {
        viewModel.todayCompleted(from: metrics, entries: entries)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if metrics.isEmpty {
                    EmptyStateView(
                        icon: "plus.circle.fill",
                        title: "No Habits Yet",
                        subtitle: "Start tracking your habits and vices to build a better you",
                        actionTitle: "Add Your First Habit",
                        action: { viewModel.showAddMetric() }
                    )
                    .background(Color.currentBackground)
                } else if geometry.size.width > geometry.size.height {
                    // Landscape: Left (stats + week), Right (list)
                    HStack(spacing: 0) {
                        leftPanel
                            .background(Color.currentSecondaryBackground)

                        Divider()

                        rightPanel
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.currentBackground)
                            .overlay(alignment: .bottomTrailing) {
                                FloatingActionButton { viewModel.showAddMetric() }
                            }
                    }
                } else {
                    // Portrait: Header (stats + week), then list + FAB
                    VStack(spacing: 0) {
                        VStack(spacing: 12) {
                            quickStatsRow
                            weekMiniCalendar
                            HStack {
                                Button(showingRowOptions ? "Done" : "Edit") {
                                    showingRowOptions.toggle()
                                }
                                .font(.caption)
                                .foregroundColor(Color.currentPrimary)

                                Spacer()

                                if !viewModel.isToday {
                                    Button("Today") { viewModel.goToToday() }
                                        .font(.caption)
                                        .foregroundColor(Color.currentPrimary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.currentSecondaryBackground)

                        sectionsList
                            .overlay(alignment: .bottomTrailing) {
                                FloatingActionButton { viewModel.showAddMetric() }
                            }
                    }
                }
            }
            .themedBackground()
            .navigationTitle("TrackBoth")
            .toolbar {
                if metrics.isEmpty || hasDemoData {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            hasDemoData ? DemoDataGenerator.clearDemoData(modelContext: modelContext) : DemoDataGenerator.generateDemoData(modelContext: modelContext)
                            hasDemoData.toggle()
                        } label: {
                            Text(hasDemoData ? "Clear Demo" : "Try Demo")
                                .font(.caption)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showSettings()
                    } label: { Image(systemName: "gear") }
                }
            }
            .onAppear {
                // Clamp selectedDate to today if in the future
                let today = Calendar.current.startOfDay(for: Date())
                if viewModel.selectedDate > today {
                    viewModel.selectedDate = today
                }
            }
            .sheet(item: $viewModel.metricToEdit) { metric in
                EditMetricView(metric: metric)
            }
            .sheet(isPresented: $viewModel.showingAddMetric) {
                AddMetricView()
            }
            .sheet(isPresented: $viewModel.showingSettings) {
                SettingsView()
                    .onAppear {
                        logger.info("SettingsView sheet presented")
                    }
            }
            .sheet(item: $showingLoggingSheetForMetric) { metric in
                LoggingSheet(metric: metric, selectedDate: viewModel.selectedDate)
            }
        }
    }

    // MARK: - Panels
    private var leftPanel: some View {
        VStack(spacing: 12) {
            quickStatsRow
                .padding(.horizontal)
                .padding(.top, 8)

            Spacer(minLength: 0)

            weekMiniCalendar
        }
        .padding()
    }

    private var rightPanel: some View {
        VStack(spacing: 0) {
            // Simple header mirroring week context
            HStack {
                Text(weekHeaderTitle)
                    .font(.headline)
                    .foregroundColor(Color.currentText)
                Spacer()
                Button(showingRowOptions ? "Done" : "Edit") {
                    showingRowOptions.toggle()
                }
                .font(.caption)
                .foregroundColor(Color.currentPrimary)
                if !viewModel.isToday {
                    Button("Today") { viewModel.goToToday() }
                        .font(.caption)
                        .foregroundColor(Color.currentPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            sectionsList
        }
    }

    // MARK: - Components
    private var quickStatsRow: some View {
        let totalHabits = viewModel.totalHabits(from: metrics)
        let totalVices = viewModel.totalVices(from: metrics)
        let activeStreaks = viewModel.activeStreaks(from: metrics, entries: entries)
        let todayCompleted = viewModel.todayCompleted(from: metrics, entries: entries)

        return HStack(spacing: 12) {
            if totalHabits > 0 {
                StatCard(title: "Habits", value: "\(totalHabits)", icon: "checkmark.circle.fill", color: Color.currentSuccess)
            }
            if totalVices > 0 {
                StatCard(title: "Vices", value: "\(totalVices)", icon: "xmark.circle.fill", color: Color.currentError)
            }
            if activeStreaks > 0 {
                StatCard(title: "Streaks", value: "\(activeStreaks)", icon: "flame.fill", color: Color.currentWarning)
            }
            StatCard(title: "Today", value: "\(todayCompleted)/\(metrics.count)", icon: "calendar", color: Color.currentPrimary)
        }
    }

    private var weekMiniCalendar: some View {
        HStack(spacing: 8) {
            ForEach(weekDays, id: \.self) { day in
                let isSelected = Calendar.current.isDate(day, inSameDayAs: viewModel.selectedDate)
                let isToday = Calendar.current.isDateInToday(day)
                VStack(spacing: 4) {
                    Text(shortWeekday(for: day))
                        .font(.caption2)
                        .foregroundColor(Color.currentSecondaryText)
                        .frame(height: 12)
                    Text(dayOfMonth(for: day))
                        .font(.subheadline)
                        .monospacedDigit()
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? Color.currentBackground : Color.currentText)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.currentPrimary : (isToday ? Color.currentPrimary.opacity(0.12) : Color.clear))
                        )
                }
                .frame(width: 36)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectedDate = day
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.currentAccent.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.currentAccent.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var sectionsList: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                Section(header: sectionHeader(title: "Habits", items: habits)) {
                    ForEach(habits) { metric in
                        CompactMetricRow(metric: metric, selectedDate: viewModel.selectedDate, showOptions: showingRowOptions) {
                            // primary toggle
                            viewModel.toggleMetricCompletion(metric, in: modelContext, entries: entries)
                        } onLog: {
                            showingLoggingSheetForMetric = metric
                        } onEdit: {
                            viewModel.showEditMetric(metric)
                        } onDelete: {
                            viewModel.metricToDelete = metric
                            viewModel.showingDeleteConfirmation = true
                        }
                    }
                }

                Section(header: sectionHeader(title: "Vices", items: vices)) {
                    ForEach(vices) { metric in
                        CompactMetricRow(metric: metric, selectedDate: viewModel.selectedDate, showOptions: showingRowOptions) {
                            viewModel.toggleMetricCompletion(metric, in: modelContext, entries: entries)
                        } onLog: {
                            showingLoggingSheetForMetric = metric
                        } onEdit: {
                            viewModel.showEditMetric(metric)
                        } onDelete: {
                            viewModel.metricToDelete = metric
                            viewModel.showingDeleteConfirmation = true
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .alert("Delete Habit", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { viewModel.metricToDelete = nil }
            Button("Delete", role: .destructive) { viewModel.deleteMetric(in: modelContext, entries: entries) }
        } message: {
            if let metric = viewModel.metricToDelete {
                Text("Are you sure you want to delete '\(metric.name)'? This will also delete all associated entries and cannot be undone.")
            }
        }
    }

    private func sectionHeader(title: String, items: [Metric]) -> some View {
        let completed = completedCount(for: items)
        return HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.currentText)
            Spacer()
            Text("\(completed)/\(items.count) today")
                .font(.caption)
                .foregroundColor(Color.currentSecondaryText)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(Color.currentSecondaryBackground)
    }

    // MARK: - Helpers
    private var weekHeaderTitle: String {
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d"
        return df.string(from: viewModel.selectedDate)
    }

    private func shortWeekday(for date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "E"
        return df.string(from: date)
    }

    private func dayOfMonth(for date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df.string(from: date)
    }
}

// MARK: - CompactMetricRow


#Preview {
    HomeView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
