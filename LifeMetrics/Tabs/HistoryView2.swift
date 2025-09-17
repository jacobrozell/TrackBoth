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
struct HistoryEntryCardView: View {
    let entry: MetricEntry
    let metrics: [Metric]
    
    @State private var showingDetails = false
    
    private var metric: Metric? {
        metrics.first { $0.id == entry.metricID }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: entry.date, relativeTo: Date())
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: entry.date)
    }
    
    private var isSuccess: Bool {
        // For habits: value=true means completed (success)
        // For vices: value=false means avoided (success)
        guard let metric = metric else { return false }
        return metric.habitType == .positive ? entry.value : !entry.value
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    if let metric = metric {
                        HStack(spacing: 8) {
                            Image(systemName: metric.habitType.icon)
                                .foregroundColor(metric.habitType == .positive ? .currentSuccess : .currentError)
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 20)
                            
                            Text(metric.name)
                                .font(.headline)
                                .foregroundColor(.currentText)
                        }
                    }
                    
                    Text("\(dayOfWeek) • \(timeAgo)")
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                        .padding(.leading, 28) // Align with metric name
                }
                
                Spacer()
                
                // Success indicator
                Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isSuccess ? Color.currentSuccess : Color.currentError)
                    .font(.system(size: 20))
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            // Details and motivation
            VStack(alignment: .leading, spacing: 8) {
                if let details = entry.details, !details.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Details")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.currentSecondaryText)
                        Text(details)
                            .font(.body)
                            .foregroundColor(.currentText)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                if let motivation = entry.motivation, !motivation.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Motivation")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.currentSecondaryText)
                        Text(motivation)
                            .font(.body)
                            .foregroundColor(.currentText)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                if let quantityString = entry.quantityString {
                    HStack {
                        Text("Quantity:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.currentSecondaryText)
                        Text(quantityString)
                            .font(.caption)
                            .foregroundColor(.currentText)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
            // Bottom accent
            Rectangle()
                .fill(isSuccess ? Color.currentSuccess.opacity(0.3) : Color.currentError.opacity(0.3))
                .frame(height: 3)
                .cornerRadius(1.5)
        }
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("History entry for \(metric?.name ?? "Unknown"): \(isSuccess ? "Success" : "Not completed")")
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            HistoryEntryDetailView(entry: entry, metric: metric)
        }
    }
}

// MARK: - HistoryEntryDetailView
struct HistoryEntryDetailView: View {
    let entry: MetricEntry
    let metric: Metric?
    
    @Environment(\.dismiss) private var dismiss
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: entry.date)
    }
    
    private var isSuccess: Bool {
        guard let metric = metric else { return false }
        return metric.habitType == .positive ? entry.value : !entry.value
    }
    
    private var statusText: String {
        guard let metric = metric else { return "Unknown" }
        if metric.habitType == .positive {
            return entry.value ? "Completed" : "Not Completed"
        } else {
            return entry.value ? "Not Avoided" : "Avoided"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        if let metric = metric {
                            HStack(spacing: 12) {
                                Image(systemName: metric.habitType.icon)
                                    .foregroundColor(metric.habitType == .positive ? .currentSuccess : .currentError)
                                    .font(.system(size: 24, weight: .medium))
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(metric.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.currentText)
                                    
                                    Text(dayOfWeek)
                                        .font(.subheadline)
                                        .foregroundColor(.currentSecondaryText)
                                }
                                
                                Spacer()
                                
                                // Status indicator
                                VStack(alignment: .trailing, spacing: 4) {
                                    Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isSuccess ? Color.currentSuccess : Color.currentError)
                                        .font(.system(size: 24))
                                    
                                    Text(statusText)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(isSuccess ? Color.currentSuccess : Color.currentError)
                                }
                            }
                        }
                        
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(.currentSecondaryText)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Status Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.currentText)
                        
                        HStack {
                            Text(statusText)
                                .font(.body)
                                .foregroundColor(.currentText)
                            
                            Spacer()
                            
                            Text(entry.value ? "Yes" : "No")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.currentSecondaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.currentSecondaryBackground)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Quantity Section
                    if let quantityString = entry.quantityString {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quantity")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.currentText)
                            
                            HStack {
                                Text(quantityString)
                                    .font(.body)
                                    .foregroundColor(.currentText)
                                
                                Spacer()
                                
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.currentAccent)
                                    .font(.system(size: 16))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.currentSecondaryBackground)
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Details Section
                    if let details = entry.details, !details.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Details")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.currentText)
                            
                            Text(details)
                                .font(.body)
                                .foregroundColor(.currentText)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.currentSecondaryBackground)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Motivation Section
                    if let motivation = entry.motivation, !motivation.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Motivation")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.currentText)
                            
                            Text(motivation)
                                .font(.body)
                                .foregroundColor(.currentText)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.currentSecondaryBackground)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.currentPrimary)
                }
            }
        }
    }
}

#Preview {
    HistoryView2()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
