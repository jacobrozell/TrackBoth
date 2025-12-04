import SwiftUI
import SwiftData


// MARK: - GoalsView2
/// Redesigned Goals view following Home/Motivations design patterns
struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @Query private var goals: [Goal]
    @State private var viewModel = GoalsViewModel()
    @State private var selectedDate = Date()
    @State private var selectedFilter: MetricFilter = .all
    @StateObject private var themeManager = ThemeManager.shared

    // MARK: - Computed Properties
    private var filteredMetrics: [Metric] {
        let metricsWithGoals = viewModel.metricsWithGoals(metrics)
        
        switch selectedFilter {
        case .all:
            return metricsWithGoals
        case .allHabits:
            return metricsWithGoals.filter { $0.habitType == .positive }
        case .allVices:
            return metricsWithGoals.filter { $0.habitType == .vice }
        case .specific(let selectedMetric):
            return metricsWithGoals.filter { $0.id == selectedMetric.id }
        }
    }
    
    private var booleanGoals: [Metric] {
        filteredMetrics.filter { GoalUtils.hasGoals(ofType: .boolean, in: $0) }
    }
    
    private var quantityGoals: [Metric] {
        filteredMetrics.filter { GoalUtils.hasGoals(ofType: .quantity, in: $0) }
    }
    
    private var habitsWithGoals: [Metric] {
        filteredMetrics.filter { $0.habitType == .positive }
    }
    
    private var vicesWithGoals: [Metric] {
        filteredMetrics.filter { $0.habitType == .vice }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if metrics.isEmpty {
                    EmptyStateView(
                        icon: "plus.circle.fill",
                        title: "No Habits Yet",
                        subtitle: "Create your first habit to start tracking your progress and building better routines",
                        actionTitle: "Create Your First Habit",
                        action: {
                            logger.logUserAction("Add habit button tapped from goals")
                            viewModel.showingAddMetric = true
                        }
                    )
                    .background(Color.currentBackground)
                } else if viewModel.metricsWithGoals(metrics).isEmpty {
                    EmptyStateView(
                        icon: "target",
                        title: "No Goals Set",
                        subtitle: "Create goals for your habits and vices to track your progress and stay motivated",
                        actionTitle: "Create Your First Goal",
                        action: {
                            logger.logUserAction("Add goal button tapped from empty state")
                            viewModel.showingAddGoal = true
                        }
                    )
                    .background(Color.currentBackground)
                } else if geometry.size.width > geometry.size.height {
                    // Landscape layout
                    HStack(spacing: 0) {
                        leftPanel
                            .background(Color.currentSecondaryBackground)

                        Divider()

                        rightPanel
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.currentBackground)
                            .overlay(alignment: .bottomTrailing) {
                                FloatingActionButton {
                                    logger.logUserAction("Add goal button tapped")
                                    viewModel.showingAddGoal = true
                                }
                            }
                    }
                } else {
                    // Portrait layout
                    VStack(spacing: 0) {
                        // Filter chips
                        if viewModel.metricsWithGoals(metrics).count > 0 {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    // All filter
                                    ReactiveFilterButton(
                                        title: "All",
                                        isSelected: selectedFilter == .all
                                    ) {
                                        selectedFilter = .all
                                    }
                                    
                                    // All Habits filter
                                    ReactiveFilterButton(
                                        title: "All Habits",
                                        isSelected: selectedFilter == .allHabits
                                    ) {
                                        selectedFilter = .allHabits
                                    }
                                    
                                    // All Vices filter
                                    ReactiveFilterButton(
                                        title: "All Vices",
                                        isSelected: selectedFilter == .allVices
                                    ) {
                                        selectedFilter = .allVices
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.vertical, 8)
                            .background(Color.currentSecondaryBackground)
                        }

                        // Goals content
                        ScrollView {
                            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                                // Boolean Goals Section
                                if !booleanGoals.isEmpty {
                                    Section(header: sectionHeader(
                                        title: "Completion Goals",
                                        icon: "target",
                                        iconColor: Color.currentPrimary,
                                        subtitle: "Complete or avoid goals"
                                    )) {
                                        ForEach(booleanGoals) { metric in
                                            GoalCardView2(metric: metric, selectedDate: selectedDate, entries: entries, goals: goals)
                                        }
                                    }
                                }

                                // Quantity Goals Section
                                if !quantityGoals.isEmpty {
                                    Section(header: sectionHeader(
                                        title: "Quantity Goals",
                                        icon: "chart.bar.fill",
                                        iconColor: Color.currentAccent,
                                        subtitle: "Track measurable progress"
                                    )) {
                                        ForEach(quantityGoals) { metric in
                                            GoalCardView2(metric: metric, selectedDate: selectedDate, entries: entries, goals: goals)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .id("goals-portrait-\(geometry.size.width)-\(geometry.size.height)")
                        .overlay(alignment: .bottomTrailing) {
                            FloatingActionButton {
                                logger.logUserAction("Add goal button tapped")
                                viewModel.showingAddGoal = true
                            }
                        }
                    }
                }
            }
            .themedBackground()
            .navigationTitle("Goals")
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
                logger.info("GoalsView2 appeared", category: .ui)
                logger.debug("Goals data - Total metrics: \(metrics.count), Metrics with goals: \(viewModel.metricsWithGoals(metrics).count)", category: .ui)
            }
            .sheet(isPresented: $viewModel.showingAddGoal) {
                AddGoalView()
                    .onAppear {
                        logger.info("AddGoalView sheet presented")
                    }
            }
            .sheet(isPresented: $viewModel.showingSettings) {
                SettingsView()
                    .onAppear {
                        logger.info("SettingsView sheet presented")
                    }
            }
            .sheet(isPresented: $viewModel.showingAddMetric) {
                AddMetricView()
                    .onAppear {
                        logger.info("AddMetricView sheet presented")
                    }
            }
        }
    }

    // MARK: - Panels
    private var leftPanel: some View {
        VStack(spacing: 12) {
            // Filter section
            VStack(alignment: .leading, spacing: 8) {
                Text("Filter Goals")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.currentSecondaryText)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        // All filter
                        ReactiveFilterButton(
                            title: "All",
                            isSelected: selectedFilter == .all
                        ) {
                            selectedFilter = .all
                        }
                        
                        // All Habits filter
                        ReactiveFilterButton(
                            title: "All Habits",
                            isSelected: selectedFilter == .allHabits
                        ) {
                            selectedFilter = .allHabits
                        }
                        
                        // All Vices filter
                        ReactiveFilterButton(
                            title: "All Vices",
                            isSelected: selectedFilter == .allVices
                        ) {
                            selectedFilter = .allVices
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Spacer(minLength: 0)
        }
        .padding()
    }

    private var rightPanel: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                        // Boolean Goals Section
                        if !booleanGoals.isEmpty {
                            Section(header: sectionHeader(
                                title: "Completion Goals",
                                icon: "target",
                                iconColor: Color.currentPrimary,
                                subtitle: "Complete or avoid goals"
                            )) {
                                ForEach(booleanGoals) { metric in
                                    GoalCardView2(metric: metric, selectedDate: selectedDate, entries: entries, goals: goals)
                                }
                            }
                        }

                        // Quantity Goals Section
                        if !quantityGoals.isEmpty {
                            Section(header: sectionHeader(
                                title: "Quantity Goals",
                                icon: "chart.bar.fill",
                                iconColor: Color.currentAccent,
                                subtitle: "Track measurable progress"
                            )) {
                                ForEach(quantityGoals) { metric in
                                    GoalCardView2(metric: metric, selectedDate: selectedDate, entries: entries, goals: goals)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .id("goals-landscape-\(geometry.size.width)-\(geometry.size.height)")
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

// MARK: - GoalCardView2
struct GoalCardView2: View {
    let metric: Metric
    let selectedDate: Date
    let entries: [MetricEntry]
    let goals: [Goal]
    
    @State private var viewModel = GoalsViewModel()
    
    private var booleanGoals: [Goal] {
        goals.filter { $0.metric?.id == metric.id && $0.goalType == .boolean }
    }
    
    private var quantityGoals: [Goal] {
        goals.filter { $0.metric?.id == metric.id && $0.goalType == .quantity }
    }
    
    private var progress: Double {
        if !booleanGoals.isEmpty {
            return viewModel.goalProgress(for: metric, entries: entries, selectedDate: selectedDate).percentage / 100.0
        } else if !quantityGoals.isEmpty {
            return viewModel.quantityGoalProgress(for: metric, entries: entries, selectedDate: selectedDate).percentage
        }
        return 0.0
    }
    
    private var isCompleted: Bool {
        return progress >= 1.0
    }
    
    private var progressText: String {
        if !booleanGoals.isEmpty {
            let progressData = viewModel.goalProgress(for: metric, entries: entries, selectedDate: selectedDate)
            return "\(progressData.current)/\(progressData.target)"
        } else if !quantityGoals.isEmpty {
            let progressData = viewModel.quantityGoalProgress(for: metric, entries: entries, selectedDate: selectedDate)
            return "\(Int(progressData.current))/\(Int(progressData.target))"
        }
        return "0/0"
    }
    
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
                        
                        // Goal type indicator
                        if !booleanGoals.isEmpty {
                            Image(systemName: "target")
                                .foregroundColor(.currentPrimary)
                                .font(.system(size: 14))
                        } else if !quantityGoals.isEmpty {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.currentAccent)
                                .font(.system(size: 14))
                        }
                    }
                    
                    Text(booleanGoals.isEmpty ? "Quantity Goal" : "Completion Goal")
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                        .padding(.leading, 28) // Align with metric name
                }
                
                Spacer()
                
                // Progress indicator
                VStack(alignment: .trailing, spacing: 4) {
                    Text(progressText)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(isCompleted ? .currentSuccess : .currentText)
                    
                    Text(isCompleted ? "Completed" : "In Progress")
                        .font(.caption)
                        .foregroundColor(isCompleted ? .currentSuccess : .currentSecondaryText)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.currentSecondaryText)
                }
                
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: isCompleted ? .currentSuccess : .currentPrimary))
                    .scaleEffect(x: 1, y: 1.5)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
            // Goal details
            if !booleanGoals.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(booleanGoals, id: \.id) { goal in
                        HStack {
                            Text("\(goal.target) times per \(goal.period.displayName)")
                                .font(.caption)
                                .foregroundColor(.currentSecondaryText)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            } else if !quantityGoals.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(quantityGoals, id: \.id) { goal in
                        HStack {
                            Text("\(goal.target) \(goal.safeDefaultUnit) per \(goal.period.displayName)")
                                .font(.caption)
                                .foregroundColor(.currentSecondaryText)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            
            // Bottom accent
            Rectangle()
                .fill(isCompleted ? Color.currentSuccess.opacity(0.3) : Color.currentPrimary.opacity(0.3))
                .frame(height: 3)
                .cornerRadius(1.5)
        }
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Goal for \(metric.name): \(progressText) progress")
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [Metric.self, MetricEntry.self, Goal.self], inMemory: true)
}
