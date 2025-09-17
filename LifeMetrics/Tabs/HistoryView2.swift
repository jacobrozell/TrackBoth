import SwiftUI
import SwiftData


// MARK: - HistoryView2
/// Redesigned History view following Home/Motivations/Goals design patterns
struct HistoryView2: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = HistoryViewModel()
    @State private var selectedFilter: MetricFilter = .all
    @State private var selectedDate = Date()
    @State private var searchText = ""
    @StateObject private var themeManager = ThemeManager.shared

    // MARK: - Computed Properties
    private var filteredMetrics: [Metric] {
        switch selectedFilter {
        case .all:
            return metrics
        case .allHabits:
            return metrics.filter { $0.habitType == .positive }
        case .allVices:
            return metrics.filter { $0.habitType == .vice }
        case .specific(let selectedMetric):
            return [selectedMetric]
        }
    }
    
    private var filteredEntries: [MetricEntry] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let endOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.end ?? selectedDate
        
        var filtered = entries.filter { entry in
            entry.date >= startOfMonth && entry.date < endOfMonth
        }
        
        // Apply metric filter
        switch selectedFilter {
        case .all:
            break
        case .allHabits:
            let habitMetricIDs = Set(metrics.filter { $0.habitType == .positive }.map { $0.id })
            filtered = filtered.filter { habitMetricIDs.contains($0.metricID) }
        case .allVices:
            let viceMetricIDs = Set(metrics.filter { $0.habitType == .vice }.map { $0.id })
            filtered = filtered.filter { viceMetricIDs.contains($0.metricID) }
        case .specific(let selectedMetric):
            filtered = filtered.filter { $0.metricID == selectedMetric.id }
        }
        
        
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
        
        // Apply metric filter
        switch selectedFilter {
        case .all:
            break
        case .allHabits:
            let habitMetricIDs = Set(metrics.filter { $0.habitType == .positive }.map { $0.id })
            filtered = filtered.filter { habitMetricIDs.contains($0.metricID) }
        case .allVices:
            let viceMetricIDs = Set(metrics.filter { $0.habitType == .vice }.map { $0.id })
            filtered = filtered.filter { viceMetricIDs.contains($0.metricID) }
        case .specific(let selectedMetric):
            filtered = filtered.filter { $0.metricID == selectedMetric.id }
        }
        
        // Group by date
        return Dictionary(grouping: filtered) { entry in
            calendar.startOfDay(for: entry.date)
        }
    }
    
    private var currentMetricFilter: MetricFilter {
        switch selectedFilter {
        case .all:
            return .all
        case .allHabits:
            return .allHabits
        case .allVices:
            return .allVices
        case .specific(let metric):
            return .specific(metric)
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
        HStack(spacing: 0) {
            leftPanel
                .background(Color.currentSecondaryBackground)

            Divider()

            rightPanel
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.currentBackground)
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All filter
                ReactiveFilterButton(
                    title: "All",
                    isSelected: selectedFilter == MetricFilter.all
                ) {
                    selectedFilter = .all
                }
                
                // All Habits filter
                ReactiveFilterButton(
                    title: "All Habits",
                    isSelected: selectedFilter == MetricFilter.allHabits
                ) {
                    selectedFilter = .allHabits
                }
                
                // All Vices filter
                ReactiveFilterButton(
                    title: "All Vices",
                    isSelected: selectedFilter == MetricFilter.allVices
                ) {
                    selectedFilter = .allVices
                }

                // Individual metrics
                ForEach(metrics) { metric in
                    ReactiveFilterButton(
                        title: metric.name,
                        isSelected: {
                            if case .specific(let selectedMetric) = selectedFilter {
                                return selectedMetric.id == metric.id
                            }
                            return false
                        }()
                    ) {
                        selectedFilter = .specific(metric)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Color.currentSecondaryBackground)
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
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                // Calendar Section
                Section(header: sectionHeader(
                    title: "Calendar View",
                    icon: "calendar",
                    iconColor: Color.currentPrimary,
                    subtitle: "Monthly overview of your progress"
                )) {
                    CalendarGridView(
                        entries: calendarEntries,
                        selectedFilter: currentMetricFilter,
                        selectedDate: $selectedDate,
                        metrics: metrics
                    )
                    .padding(.horizontal, 16)
                }

                // Recent Entries Section
                if !filteredEntries.isEmpty {
                    Section(header: sectionHeader(
                        title: "Recent Entries",
                        icon: "clock",
                        iconColor: Color.currentSecondaryText,
                        subtitle: "Your latest activity"
                    )) {
                        ForEach(filteredEntries.prefix(20)) { entry in
                            HistoryEntryCardView(entry: entry, metrics: metrics)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if metrics.isEmpty {
                    noHabitsEmptyState
                } else if !hasAnyEntries {
                    noHistoryEmptyState
                } else if geometry.size.width > geometry.size.height {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
            .themedBackground()
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showSettings()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .onAppear {
                logger.info("HistoryView2 appeared", category: .ui)
                logger.debug("History data - Total metrics: \(metrics.count), Total entries: \(entries.count), Filter: \(selectedFilter.displayName)", category: .ui)
            }
            .sheet(isPresented: $viewModel.showingAddMetric) {
                AddMetricView()
            }
            .sheet(isPresented: $viewModel.showingSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Panels
    private var leftPanel: some View {
        VStack(spacing: 12) {
            // Filter section
            VStack(alignment: .leading, spacing: 8) {
                Text("Filter by Habit")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.currentSecondaryText)

                VStack(spacing: 8) {
                    // All filter
                    ReactiveFilterButton(
                        title: "All",
                        isSelected: selectedFilter == MetricFilter.all
                    ) {
                        selectedFilter = .all
                    }
                    
                    // All Habits filter
                    ReactiveFilterButton(
                        title: "All Habits",
                        isSelected: selectedFilter == MetricFilter.allHabits
                    ) {
                        selectedFilter = .allHabits
                    }
                    
                    // All Vices filter
                    ReactiveFilterButton(
                        title: "All Vices",
                        isSelected: selectedFilter == MetricFilter.allVices
                    ) {
                        selectedFilter = .allVices
                    }

                    // Individual metrics
                    ForEach(metrics) { metric in
                        ReactiveFilterButton(
                            title: metric.name,
                            isSelected: {
                                if case .specific(let selectedMetric) = selectedFilter {
                                    return selectedMetric.id == metric.id
                                }
                                return false
                            }()
                        ) {
                            selectedFilter = .specific(metric)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Search bar
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

            Spacer(minLength: 0)
        }
        .padding()
    }

    private var rightPanel: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                    // Calendar Section
                    Section(header: sectionHeader(
                        title: "Calendar View",
                        icon: "calendar",
                        iconColor: Color.currentPrimary,
                        subtitle: "Monthly overview of your progress"
                    )) {
                        CalendarGridView(
                            entries: calendarEntries,
                            selectedFilter: currentMetricFilter,
                            selectedDate: $selectedDate,
                            metrics: metrics
                        )
                        .padding(.horizontal, 16)
                    }

                    // Recent Entries Section
                    if !filteredEntries.isEmpty {
                        Section(header: sectionHeader(
                            title: "Recent Entries",
                            icon: "clock",
                            iconColor: Color.currentSecondaryText,
                            subtitle: "Your latest activity"
                        )) {
                            ForEach(filteredEntries.prefix(20)) { entry in
                                HistoryEntryCardView(entry: entry, metrics: metrics)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Components
    private func sectionHeader(title: String, icon: String, iconColor: Color, subtitle: String) -> some View {
        HStack(spacing: 12) {
            // Icon with background circle
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.currentText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.currentSecondaryText)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.currentSecondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(iconColor.opacity(0.2), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityHeading(.h2)
    }
}

// MARK: - HistoryEntryCardView


#Preview {
    HistoryView2()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
