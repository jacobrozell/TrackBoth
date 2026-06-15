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
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.adaptiveLayoutMode) private var adaptiveLayoutMode
    @Environment(\.isCompactLandscape) private var isCompactLandscape

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
            ZStack(alignment: .top) {
                Color.currentBackground.ignoresSafeArea()

                GeometryReader { geometry in
                Group {
                    if metrics.isEmpty {
                        EmptyStateView(
                            icon: "plus.circle.fill",
                            title: "No Habits Yet",
                            subtitle: "Start tracking your habits and vices to build a better you",
                            actionTitle: "Add Your First Habit",
                            action: { viewModel.showAddMetric() }
                        )
                    } else if TabBarLayout.shouldUseSidebarSplit(
                        size: geometry.size,
                        horizontal: horizontalSizeClass,
                        vertical: verticalSizeClass
                    ) {
                        LandscapeSplitLayout(
                            totalWidth: geometry.size.width,
                            totalHeight: geometry.size.height,
                            sidebar: { leftPanel },
                            content: { rightPanel }
                        )
                        .tabBarFloatingActionButton(isLandscape: true) {
                            viewModel.showAddMetric()
                        }
                    } else {
                        VStack(spacing: 0) {
                            homeHeader

                            sectionsList
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .adaptiveFloatingActionButton {
                            viewModel.showAddMetric()
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                }
            }
            .navigationTitle("TrackBoth")
            .navigationBarTitleDisplayMode(isCompactLandscape ? .inline : .large)
            .accessibilityIdentifier(AccessibilityIdentifiers.tabHome)
            .toolbar {
                if ProductSurface.showsDemoData {
                    ToolbarItem(placement: .navigationBarLeading) {
                        DemoDataToolbarButton(metricsEmpty: metrics.isEmpty)
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showSettings()
                    } label: {
                        Image(systemName: "gear")
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.settingsButton)
                    .accessibilityLabel("Settings")
                }
            }
            .adaptiveAddButton(isEmpty: metrics.isEmpty) {
                viewModel.showAddMetric()
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Panels
    private var homeHeader: some View {
        Group {
            if isCompactLandscape {
                compactLandscapeHeader
            } else {
                portraitHeader
            }
        }
    }

    private var compactLandscapeHeader: some View {
        HStack(alignment: .top, spacing: 10) {
            quickStatsRow
                .frame(maxWidth: 300)

            VStack(spacing: 4) {
                weekHeaderRow
                weekMiniCalendar
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.currentSecondaryBackground)
    }

    private var portraitHeader: some View {
        VStack(spacing: 12) {
            quickStatsRow
            weekMiniCalendar
            weekHeaderRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.currentSecondaryBackground)
    }

    private var weekHeaderRow: some View {
        HStack {
            Button(showingRowOptions ? "Done" : "Edit") {
                showingRowOptions.toggle()
            }
            .caption()
            .foregroundColor(Color.currentPrimary)

            Spacer()

            Text(weekHeaderTitle)
                .caption()
                .foregroundColor(Color.currentSecondaryText)

            if !viewModel.isToday {
                Button("Today") { viewModel.goToToday() }
                    .caption()
                    .foregroundColor(Color.currentPrimary)
            }
        }
    }

    private var leftPanel: some View {
        VStack(spacing: 12) {
            sidebarStatsColumn
                .padding(.horizontal, 8)
                .padding(.top, 8)

            Spacer(minLength: 0)

            weekMiniCalendar
        }
        .padding()
    }

    private var sidebarStatsColumn: some View {
        let totalHabits = viewModel.totalHabits(from: metrics)
        let totalVices = viewModel.totalVices(from: metrics)
        let activeStreaks = viewModel.activeStreaks(from: metrics, entries: entries)
        let todayCompleted = viewModel.todayCompleted(from: metrics, entries: entries)

        return VStack(spacing: 8) {
            if totalHabits > 0 {
                StatCard(title: "Habits", value: "\(totalHabits)", icon: "checkmark.circle.fill", color: Color.currentSuccess, compact: true)
            }
            if totalVices > 0 {
                StatCard(title: "Vices", value: "\(totalVices)", icon: "xmark.circle.fill", color: Color.currentError, compact: true)
            }
            if activeStreaks > 0 {
                StatCard(title: "Streaks", value: "\(activeStreaks)", icon: "flame.fill", color: Color.currentWarning, compact: true)
            }
            StatCard(title: "Today", value: "\(todayCompleted)/\(metrics.count)", icon: "calendar", color: Color.currentPrimary, compact: true)
        }
        .frame(maxWidth: .infinity)
    }

    private var rightPanel: some View {
        VStack(spacing: 0) {
            // Simple header mirroring week context
            HStack {
                Text(weekHeaderTitle)
                    .h4()
                    .foregroundColor(Color.currentText)
                Spacer()
                Button(showingRowOptions ? "Done" : "Edit") {
                    showingRowOptions.toggle()
                }
                .caption()
                .foregroundColor(Color.currentPrimary)
                if !viewModel.isToday {
                    Button("Today") { viewModel.goToToday() }
                        .caption()
                        .foregroundColor(Color.currentPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            sectionsList
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Components
    private var quickStatsRow: some View {
        let totalHabits = viewModel.totalHabits(from: metrics)
        let totalVices = viewModel.totalVices(from: metrics)
        let activeStreaks = viewModel.activeStreaks(from: metrics, entries: entries)
        let todayCompleted = viewModel.todayCompleted(from: metrics, entries: entries)
        let cardWidth: CGFloat = isCompactLandscape ? 76 : 88

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: isCompactLandscape ? 8 : 10) {
                if totalHabits > 0 {
                    StatCard(title: "Habits", value: "\(totalHabits)", icon: "checkmark.circle.fill", color: Color.currentSuccess, compact: true)
                        .frame(width: cardWidth)
                }
                if totalVices > 0 {
                    StatCard(title: "Vices", value: "\(totalVices)", icon: "xmark.circle.fill", color: Color.currentError, compact: true)
                        .frame(width: cardWidth)
                }
                if activeStreaks > 0 {
                    StatCard(title: "Streaks", value: "\(activeStreaks)", icon: "flame.fill", color: Color.currentWarning, compact: true)
                        .frame(width: cardWidth)
                }
                StatCard(title: "Today", value: "\(todayCompleted)/\(metrics.count)", icon: "calendar", color: Color.currentPrimary, compact: true)
                    .frame(width: cardWidth)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var weekMiniCalendar: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                let isSelected = Calendar.current.isDate(day, inSameDayAs: viewModel.selectedDate)
                let isToday = Calendar.current.isDateInToday(day)
                VStack(spacing: 4) {
                    Text(shortWeekday(for: day))
                        .font(.caption2)
                        .foregroundColor(Color.currentSecondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(dayOfMonth(for: day))
                        .font(.caption)
                        .monospacedDigit()
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? Color.currentBackground : Color.currentText)
                        .frame(width: 26, height: 26)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.currentPrimary : (isToday ? Color.currentPrimary.opacity(0.12) : Color.clear))
                        )
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectedDate = day
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
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
            .adaptiveScrollInset()
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
