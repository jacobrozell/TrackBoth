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
    @Environment(\.usesSidebarSplit) private var usesSidebarSplit
    @Environment(\.isCompactLandscape) private var isCompactLandscape
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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

                Group {
                    if metrics.isEmpty {
                        EmptyStateView(
                            icon: "plus.circle.fill",
                            title: "No Habits Yet",
                            subtitle: "Start tracking your habits and vices to build a better you",
                            actionTitle: "Add Your First Habit",
                            action: { viewModel.showAddMetric() }
                        )
                    } else if usesSidebarSplit {
                        GeometryReader { geometry in
                            LandscapeSplitLayout(
                                totalWidth: geometry.size.width,
                                totalHeight: geometry.size.height,
                                sidebar: { leftPanel },
                                content: { rightPanel }
                            )
                            .tabBarFloatingActionButton(isLandscape: true) {
                                viewModel.showAddMetric()
                            }
                        }
                    } else {
                        GeometryReader { geometry in
                            VStack(spacing: 0) {
                                ScrollView {
                                    LazyVStack(
                                        spacing: 16,
                                        pinnedViews: dynamicTypeSize.usesAccessibilityLayout ? [] : [.sectionHeaders]
                                    ) {
                                        homeHeader
                                        metricsSections
                                    }
                                    .adaptiveScrollInset()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                            .adaptiveFloatingActionButton {
                                viewModel.showAddMetric()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle("TrackBoth")
            .adaptiveNavigationBarTitleDisplayMode(isCompactLandscape: isCompactLandscape)
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
            .alert("Delete Habit", isPresented: $viewModel.showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { viewModel.metricToDelete = nil }
                Button("Delete", role: .destructive) { viewModel.deleteMetric(in: modelContext, entries: entries) }
            } message: {
                if let metric = viewModel.metricToDelete {
                    Text("Are you sure you want to delete '\(metric.name)'? This will also delete all associated entries and cannot be undone.")
                }
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
        VStack(spacing: dynamicTypeSize.usesAccessibilityLayout ? 8 : 12) {
            if dynamicTypeSize.usesAccessibilityLayout {
                weekHeaderRow
                quickStatsRow
                weekMiniCalendar
            } else {
                quickStatsRow
                weekMiniCalendar
                weekHeaderRow
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, dynamicTypeSize.usesAccessibilityLayout ? 4 : 8)
        .background(Color.currentSecondaryBackground)
    }

    private var weekHeaderRow: some View {
        Group {
            if dynamicTypeSize.usesAccessibilityLayout {
                VStack(alignment: .leading, spacing: 6) {
                    Text(weekHeaderTitle)
                        .font(.subheadline)
                        .foregroundColor(Color.currentSecondaryText)
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
            } else {
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

            ScrollView {
                sectionsList
                    .adaptiveScrollInset()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Components
    @ViewBuilder
    private var quickStatsRow: some View {
        let totalHabits = viewModel.totalHabits(from: metrics)
        let totalVices = viewModel.totalVices(from: metrics)
        let activeStreaks = viewModel.activeStreaks(from: metrics, entries: entries)
        let todayCompleted = viewModel.todayCompleted(from: metrics, entries: entries)
        let fixedCardWidth: CGFloat = isCompactLandscape ? 76 : 88

        if dynamicTypeSize.usesAccessibilityLayout {
            LazyVGrid(
                columns: [GridItem(.flexible())],
                spacing: 10
            ) {
                quickStatCards(
                    totalHabits: totalHabits,
                    totalVices: totalVices,
                    activeStreaks: activeStreaks,
                    todayCompleted: todayCompleted,
                    fixedWidth: nil
                )
            }
            .frame(maxWidth: .infinity)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: isCompactLandscape ? 8 : 10) {
                    quickStatCards(
                        totalHabits: totalHabits,
                        totalVices: totalVices,
                        activeStreaks: activeStreaks,
                        todayCompleted: todayCompleted,
                        fixedWidth: fixedCardWidth
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func quickStatCards(
        totalHabits: Int,
        totalVices: Int,
        activeStreaks: Int,
        todayCompleted: Int,
        fixedWidth: CGFloat?
    ) -> some View {
        if totalHabits > 0 {
            statCard(title: "Habits", value: "\(totalHabits)", icon: "checkmark.circle.fill", color: Color.currentSuccess, width: fixedWidth)
        }
        if totalVices > 0 {
            statCard(title: "Vices", value: "\(totalVices)", icon: "xmark.circle.fill", color: Color.currentError, width: fixedWidth)
        }
        if activeStreaks > 0 {
            statCard(title: "Streaks", value: "\(activeStreaks)", icon: "flame.fill", color: Color.currentWarning, width: fixedWidth)
        }
        statCard(title: "Today", value: "\(todayCompleted)/\(metrics.count)", icon: "calendar", color: Color.currentPrimary, width: fixedWidth)
    }

    private var weekMiniCalendar: some View {
        WeekMiniCalendarRow(
            days: weekDays,
            selectedDate: viewModel.selectedDate,
            usesAccessibilityLayout: dynamicTypeSize.usesAccessibilityLayout,
            onSelect: { viewModel.selectedDate = $0 }
        )
    }

    @ViewBuilder
    private func statCard(title: String, value: String, icon: String, color: Color, width: CGFloat?) -> some View {
        let card = StatCard(title: title, value: value, icon: icon, color: color, compact: true)
        if let width {
            card.frame(width: width)
        } else {
            card.frame(maxWidth: .infinity)
        }
    }

    private var sectionsList: some View {
        metricsSections
    }

    private var metricsSections: some View {
        LazyVStack(
            spacing: 16,
            pinnedViews: dynamicTypeSize.usesAccessibilityLayout ? [] : [.sectionHeaders]
        ) {
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
    }

    private func sectionHeader(title: String, items: [Metric]) -> some View {
        let completed = completedCount(for: items)
        return Group {
            if dynamicTypeSize.usesAccessibilityLayout {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color.currentText)
                    Text("\(completed)/\(items.count) today")
                        .font(.subheadline)
                        .foregroundColor(Color.currentSecondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color.currentText)
                    Spacer()
                    Text("\(completed)/\(items.count) today")
                        .font(.caption)
                        .foregroundColor(Color.currentSecondaryText)
                }
            }
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

}

// MARK: - WeekMiniCalendarRow
private struct WeekMiniCalendarRow: View {
    let days: [Date]
    let selectedDate: Date
    let usesAccessibilityLayout: Bool
    let onSelect: (Date) -> Void

    @ScaledMetric(relativeTo: .caption) private var dayBadgeSize: CGFloat = 28

    var body: some View {
        Group {
            if usesAccessibilityLayout {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(days, id: \.self) { day in
                            dayCell(for: day)
                                .frame(minWidth: dayBadgeSize + 16)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } else {
                HStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        dayCell(for: day)
                    }
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

    @ViewBuilder
    private func dayCell(for day: Date) -> some View {
        let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(day)

        VStack(spacing: 4) {
            Text(weekdayLabel(for: day))
                .font(.caption2)
                .foregroundColor(Color.currentSecondaryText)
                .lineLimit(1)
                .minimumScaleFactor(usesAccessibilityLayout ? 1 : 0.8)
                .padding(.top, usesAccessibilityLayout ? 2 : 0)

            Text(dayNumber(for: day))
                .font(.caption)
                .monospacedDigit()
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? Color.currentBackground : Color.currentText)
                .frame(minWidth: dayBadgeSize, minHeight: dayBadgeSize)
                .background(
                    Circle()
                        .fill(isSelected ? Color.currentPrimary : (isToday ? Color.currentPrimary.opacity(0.12) : Color.clear))
                )
        }
        .padding(.vertical, usesAccessibilityLayout ? 4 : 0)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { onSelect(day) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel(for: day, isSelected: isSelected))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func weekdayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = usesAccessibilityLayout ? "EEEEE" : "EEE"
        return formatter.string(from: date)
    }

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func accessibilityLabel(for date: Date, isSelected: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        let prefix = isSelected ? "Selected, " : ""
        return "\(prefix)\(formatter.string(from: date))"
    }
}

// MARK: - CompactMetricRow


#Preview {
    HomeView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
