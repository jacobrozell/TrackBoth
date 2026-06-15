import SwiftUI
import SwiftData


// MARK: - HistoryView2
/// Redesigned History view following Home/Motivations/Goals design patterns
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = HistoryViewModel()
    @State private var selectedFilter: MetricFilter = .all
    @State private var selectedDate = Date()
    @State private var searchText = ""
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.usesSidebarSplit) private var usesSidebarSplit
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Computed Properties
    private var filteredMetrics: [Metric] {
        FilterUtils.filteredMetrics(selectedFilter, in: metrics)
    }
    
    private var filteredEntries: [MetricEntry] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let endOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.end ?? selectedDate
        
        var filtered = entries.filter { entry in
            entry.date >= startOfMonth && entry.date < endOfMonth
        }
        
        filtered = FilterUtils.filteredEntries(selectedFilter, entries: filtered, metrics: metrics)
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { entry in
                let details = entry.details?.lowercased() ?? ""
                let motivation = entry.motivation?.lowercased() ?? ""
                let searchLower = searchText.lowercased()
                return details.contains(searchLower) || motivation.contains(searchLower)
            }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    private var calendarEntries: [Date: [MetricEntry]] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let endOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.end ?? selectedDate
        
        var filtered = entries.filter { entry in
            entry.date >= startOfMonth && entry.date < endOfMonth
        }
        
        filtered = FilterUtils.filteredEntries(selectedFilter, entries: filtered, metrics: metrics)
        
        // Group by date
        return Dictionary(grouping: filtered) { entry in
            calendar.startOfDay(for: entry.date)
        }
    }
    
    private var hasAnyEntries: Bool {
        return !entries.isEmpty
    }
    
    // MARK: - Layout Views
    private var noHabitsEmptyState: some View {
        EmptyStateView(
            icon: "plus.circle.fill",
            title: "No Habits Yet",
            subtitle: "Start tracking your habits and vices to see your history",
            actionTitle: "Add Your First Habit",
            action: {
                logger.logUserAction("Add habit button tapped from history")
                viewModel.showAddMetric()
            }
        )
        .background(Color.currentBackground)
    }
    
    private var noHistoryEmptyState: some View {
        EmptyStateView(
            icon: "calendar.badge.exclamationmark",
            title: "No History Yet",
            subtitle: "Start logging your habits and vices to build your history",
            actionTitle: "Start Logging",
            action: {
                logger.logUserAction("Start logging button tapped from history")
                viewModel.showAddMetric()
            }
        )
        .background(Color.currentBackground)
    }
    
    private var landscapeLayout: some View {
        GeometryReader { geometry in
            LandscapeSplitLayout(
                totalWidth: geometry.size.width,
                totalHeight: geometry.size.height,
                sidebar: { leftPanel },
                content: { rightPanel }
            )
        }
    }
    
    private var portraitLayout: some View {
        VStack(spacing: 0) {
            // Filter chips
            if metrics.count > 0 {
                filterChipsView
            }

            // Search bar
//            searchBarView

            // History content
            historyContentView
        }
        .background(Color.currentBackground)
    }
    
    private var filterChipsView: some View {
        MetricFilterChipRow(metrics: metrics, selectedFilter: $selectedFilter)
    }
    
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.currentSecondaryText)

            TextField("Search details...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.currentSecondaryText)
                }
            }
        }
        .padding()
        .background(Color.currentSecondaryBackground)
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var historyContentView: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(
                    spacing: 16,
                    pinnedViews: dynamicTypeSize.usesAccessibilityLayout ? [] : [.sectionHeaders]
                ) {
                    // Calendar Section
                    Section(header: AdaptiveSectionHeader(
                        title: "Calendar View",
                        subtitle: "Monthly overview of your progress",
                        icon: "calendar",
                        iconColor: Color.currentPrimary
                    )) {
                        CalendarGridView(
                            entries: calendarEntries,
                            selectedFilter: selectedFilter,
                            selectedDate: $selectedDate,
                            metrics: metrics
                        )
                        .padding(.horizontal, 16)
                    }

                    // Recent Entries Section
                    if !filteredEntries.isEmpty {
                        Section(header: AdaptiveSectionHeader(
                            title: "Recent Entries",
                            subtitle: "Your latest activity",
                            icon: "clock",
                            iconColor: Color.currentSecondaryText
                        )) {
                            ForEach(filteredEntries.prefix(20)) { entry in
                                HistoryEntryCardView(entry: entry, metrics: metrics)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .adaptiveScrollInset()
            }
            .id("portrait-\(geometry.size.width)-\(geometry.size.height)")
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                Group {
                if metrics.isEmpty {
                    noHabitsEmptyState
                } else if !hasAnyEntries {
                    noHistoryEmptyState
                } else if TabBarLayout.shouldUseSidebarSplit(
                    size: geometry.size,
                    horizontal: horizontalSizeClass,
                    vertical: verticalSizeClass
                ) {
                    landscapeLayout
                } else {
                    portraitLayout
                }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            }
            .themedBackground()
            .navigationTitle("History")
            .adaptiveNavigationBarTitleDisplayMode()
            .onAppear {
                logger.info("HistoryView2 appeared", category: .ui)
                logger.debug("History data - Total metrics: \(metrics.count), Total entries: \(entries.count), Filter: \(selectedFilter.displayName)", category: .ui)
            }
            .sheet(isPresented: $viewModel.showingAddMetric) {
                AddMetricView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Panels
    private var leftPanel: some View {
        VStack(spacing: 12) {
            MetricFilterSidebar(
                title: "Filter by Habit",
                metrics: metrics,
                selectedFilter: $selectedFilter
            )
        }
        .padding()
    }

    private var rightPanel: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(
                        spacing: 16,
                        pinnedViews: dynamicTypeSize.usesAccessibilityLayout ? [] : [.sectionHeaders]
                    ) {
                        // Calendar Section
                        Section(header: AdaptiveSectionHeader(
                            title: "Calendar View",
                            subtitle: "Monthly overview of your progress",
                            icon: "calendar",
                            iconColor: Color.currentPrimary
                        )) {
                            CalendarGridView(
                                entries: calendarEntries,
                                selectedFilter: selectedFilter,
                                selectedDate: $selectedDate,
                                metrics: metrics
                            )
                            .padding(.horizontal, 16)
                        }

                        // Recent Entries Section
                        if !filteredEntries.isEmpty {
                            Section(header: AdaptiveSectionHeader(
                                title: "Recent Entries",
                                subtitle: "Your latest activity",
                                icon: "clock",
                                iconColor: Color.currentSecondaryText
                            )) {
                                ForEach(filteredEntries.prefix(20)) { entry in
                                    HistoryEntryCardView(entry: entry, metrics: metrics)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .adaptiveScrollInset()
                }
                .id("landscape-\(geometry.size.width)-\(geometry.size.height)")
            }
        }
    }

    // MARK: - Components
}

// MARK: - HistoryEntryCardView


#Preview {
    HistoryView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
