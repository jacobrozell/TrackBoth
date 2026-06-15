import SwiftUI
import SwiftData


// MARK: - MotivationsView2
/// Redesigned Motivation view per motivation-view-redesign-spec
struct MotivationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = MotivationViewModel()
    @State private var showingAddMotivation = false
    @State private var selectedFilter: MetricFilter = .all
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.usesSidebarSplit) private var usesSidebarSplit
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Computed Properties
    private var filteredMetrics: [Metric] {
        FilterUtils.filteredMetrics(selectedFilter, in: metrics)
    }
    
    private var primaryMotivations: [Metric] {
        let startTime = Date()
        let result = filteredMetrics.filter { metric in
            metric.primaryMotivation != nil && !metric.primaryMotivation!.isEmpty
        }
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Primary motivations filtering", duration: duration)
        logger.debug("Primary motivations filtered - Filter: \(selectedFilter.displayName), Result: \(result.count)", category: .business)
        return result
    }
    
    private var dailyMotivations: [MetricEntry] {
        let startTime = Date()
        let motivationEntries = entries.filter { entry in
            entry.motivation != nil && !entry.motivation!.isEmpty
        }
        let result = FilterUtils.filteredEntries(selectedFilter, entries: motivationEntries, metrics: metrics)
        
        let sortedResult = result.sorted { $0.date > $1.date }
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Daily motivations filtering", duration: duration)
        logger.debug("Daily motivations filtered - Filter: \(selectedFilter.displayName), Result: \(sortedResult.count)", category: .business)
        return sortedResult
    }
    
    private var hasAnyMotivations: Bool {
        let hasPrimary = metrics.contains { $0.primaryMotivation != nil && !$0.primaryMotivation!.isEmpty }
        let hasDaily = entries.contains { $0.motivation != nil && !$0.motivation!.isEmpty }
        return hasPrimary || hasDaily
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                Group {
                if metrics.isEmpty {
                    // No habits/vices - need to create one first
                    EmptyStateView(
                        icon: "plus.circle.fill",
                        title: "No Habits Yet",
                        subtitle: "Start tracking your habits and vices to build a better you",
                        actionTitle: "Add Your First Habit",
                        action: {
                            logger.logUserAction("Add habit button tapped from motivation")
                            viewModel.showAddMetric()
                        }
                    )
                    .background(Color.currentBackground)
                } else if !hasAnyMotivations {
                    // Has habits/vices but no motivations - show empty state with FAB
                    ZStack {
                        EmptyStateView(
                            icon: "book.closed",
                            title: "No Motivations Yet",
                            subtitle: "Start building your motivation library to stay accountable and inspired."
                        )
                        .background(Color.currentBackground)
                        
                        // FAB overlay
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                FloatingActionButton {
                                    logger.logUserAction("Add motivation button tapped from empty state")
                                    showingAddMotivation = true
                                }
                                .accessibilityLabel("Add Motivation")
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
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
                        logger.logUserAction("Add motivation button tapped")
                        showingAddMotivation = true
                    }
                } else {
                    // Portrait layout
                    VStack(spacing: 0) {
                        if metrics.count > 0 {
                            MetricFilterChipRow(metrics: metrics, selectedFilter: $selectedFilter)
                        }

                        ScrollView {
                            LazyVStack(
                                spacing: 16,
                                pinnedViews: dynamicTypeSize.usesAccessibilityLayout ? [] : [.sectionHeaders]
                            ) {
                                // Primary Motivations Section
                                if !primaryMotivations.isEmpty {
                                    Section(header: AdaptiveSectionHeader(
                                        title: "Primary Motivations",
                                        subtitle: "Your core reasons for your habits",
                                        icon: "star.fill",
                                        iconColor: Color.currentWarning
                                    )) {
                                        ForEach(primaryMotivations) { metric in
                                            PrimaryMotivationCardView2(metric: metric)
                                        }
                                    }
                                }

                                // Daily Motivations Section
                                if !dailyMotivations.isEmpty {
                                    Section(header: AdaptiveSectionHeader(
                                        title: "Daily Motivations",
                                        subtitle: "Recent motivation entries",
                                        icon: "clock",
                                        iconColor: Color.currentSecondaryText
                                    )) {
                                        ForEach(dailyMotivations) { entry in
                                            DailyMotivationCardView2(entry: entry, metrics: metrics)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .adaptiveScrollInset()
                        }
                        .id("motivations-portrait-\(geometry.size.width)-\(geometry.size.height)")
                    }
                    .adaptiveFloatingActionButton {
                        logger.logUserAction("Add motivation button tapped")
                        showingAddMotivation = true
                    }
                }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            }
            .themedBackground()
            .navigationTitle("Motivation")
            .adaptiveNavigationBarTitleDisplayMode()
            .adaptiveAddButton(isEmpty: !hasAnyMotivations, label: "Add Motivation") {
                logger.logUserAction("Add motivation button tapped")
                showingAddMotivation = true
            }
            .onAppear {
                logger.info("MotivationsView2 appeared", category: .ui)
                logger.debug("Motivation data - Total metrics: \(metrics.count), Primary motivations: \(primaryMotivations.count), Daily motivations: \(dailyMotivations.count)", category: .ui)
            }
            .sheet(isPresented: $viewModel.showingAddMetric) {
                AddMetricView()
            }
            .sheet(isPresented: $showingAddMotivation) {
                AddMotivationView2(metrics: metrics)
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
            Spacer(minLength: 0)
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
                        // Primary Motivations Section
                        if !primaryMotivations.isEmpty {
                            Section(header: AdaptiveSectionHeader(
                                title: "Primary Motivations",
                                subtitle: "Your core reasons for your habits",
                                icon: "star.fill",
                                iconColor: Color.currentWarning
                            )) {
                                ForEach(primaryMotivations) { metric in
                                    PrimaryMotivationCardView2(metric: metric)
                                }
                            }
                        }

                        // Daily Motivations Section
                        if !dailyMotivations.isEmpty {
                            Section(header: AdaptiveSectionHeader(
                                title: "Daily Motivations",
                                subtitle: "Recent motivation entries",
                                icon: "clock",
                                iconColor: Color.currentSecondaryText
                            )) {
                                ForEach(dailyMotivations) { entry in
                                    DailyMotivationCardView2(entry: entry, metrics: metrics)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .adaptiveScrollInset()
                }
                .id("motivations-landscape-\(geometry.size.width)-\(geometry.size.height)")
            }
        }
    }

    // MARK: - Components
}

// MARK: - PrimaryMotivationCardView2
struct PrimaryMotivationCardView2: View {
    let metric: Metric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: metric.habitType.icon)
                            .foregroundColor(metric.habitType == .positive ? .currentSuccess : .currentError)
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 20)
                        
                        Text(metric.name)
                            .font(.headline)
                            .foregroundColor(.currentText)
                        
                        // Star indicator for primary motivation
                        Image(systemName: "star.fill")
                            .foregroundColor(.currentWarning)
                            .font(.system(size: 14))
                    }
                    
                    Text("Primary Motivation")
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                        .padding(.leading, 28) // Align with metric name
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            // Primary motivation text
            Text(metric.primaryMotivation ?? "")
                .font(.body)
                .foregroundColor(.currentText)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            
            // Bottom accent
            Rectangle()
                .fill(Color.currentWarning.opacity(0.3))
                .frame(height: 3)
                .cornerRadius(1.5)
        }
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Primary motivation for \(metric.name): \(metric.primaryMotivation ?? "")")
    }
}

// MARK: - DailyMotivationCardView2
struct DailyMotivationCardView2: View {
    let entry: MetricEntry
    let metrics: [Metric]
    
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
    
    private var showsStatusBadge: Bool {
        guard metric != nil else { return false }
        return TrackingSemantics.isLoggedForDay(entry: entry)
    }

    private var isSuccess: Bool {
        guard let metric else { return false }
        return TrackingSemantics.isLoggedSuccess(habitType: metric.habitType, entry: entry)
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

                if showsStatusBadge {
                    Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isSuccess ? Color.currentSuccess : Color.currentError)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            // Motivation text
            Text(entry.motivation ?? "")
                .font(.body)
                .foregroundColor(.currentText)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            
            // Bottom accent
            Rectangle()
                .fill(
                    showsStatusBadge
                        ? (isSuccess ? Color.currentSuccess.opacity(0.3) : Color.currentError.opacity(0.3))
                        : Color.currentSecondaryText.opacity(0.2)
                )
                .frame(height: 3)
                .cornerRadius(1.5)
        }
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Daily motivation for \(metric?.name ?? "Unknown"): \(entry.motivation ?? "")")
    }
}

// MARK: - AddMotivationView2
struct AddMotivationView2: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var entries: [MetricEntry]
    let metrics: [Metric]
    
    @State private var selectedMetric: Metric?
    @State private var motivationText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add Motivation")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.currentText)
                        
                        Text("Write your own motivation to help you stay strong when struggling.")
                            .font(.body)
                            .foregroundColor(Color.currentSecondaryText)
                            .lineSpacing(2)
                    }
                    .padding(.top, 8)
                    
                    // Habit picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Habit")
                            .font(.headline)
                            .foregroundColor(Color.currentText)
                        
                        Picker("Habit", selection: $selectedMetric) {
                            Text("Choose a habit to motivate for").tag(nil as Metric?)
                            ForEach(metrics) { metric in
                                HStack(spacing: 12) {
                                    Image(systemName: metric.habitType.icon)
                                        .foregroundColor(metric.habitType == .positive ? Color.currentSuccess : Color.currentError)
                                        .font(.system(size: 16))
                                        .frame(width: 20)
                                    Text(metric.name)
                                        .font(.body)
                                }.tag(metric as Metric?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.currentSecondaryBackground)
                        )
                    }
                    
                    // Motivation text input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Motivation")
                            .font(.headline)
                            .foregroundColor(Color.currentText)
                        
                        TextEditor(text: $motivationText)
                            .frame(minHeight: 200)
                            .font(.body)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.currentSecondaryBackground)
                            )
                            .overlay(
                                // Placeholder text
                                Group {
                                    if motivationText.isEmpty {
                                        VStack {
                                            HStack {
                                                Text("Why is this habit important to you?")
                                                    .font(.body)
                                                    .foregroundColor(Color.currentSecondaryText)
                                                    .padding(.leading, 20)
                                                    .padding(.top, 24)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            )
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Add Motivation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.caption)
                    .foregroundColor(Color.currentPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMotivation()
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.currentPrimary)
                    .disabled(selectedMetric == nil || motivationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveMotivation() {
        guard let metric = selectedMetric else { return }
        
        let today = CalendarHelper.startOfDay(for: Date())
        MetricEntry.updateOrCreate(
            for: metric.id,
            date: today,
            motivation: motivationText.trimmingCharacters(in: .whitespacesAndNewlines),
            in: modelContext,
            entries: entries
        )
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    MotivationsView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
