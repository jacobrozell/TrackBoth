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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.usesSidebarSplit) private var usesSidebarSplit
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var metricsWithGoals: [Metric] {
        viewModel.metricsWithGoals(metrics)
    }

    private var filteredMetrics: [Metric] {
        FilterUtils.filteredMetrics(selectedFilter, in: metricsWithGoals)
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
                Group {
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
                } else if metricsWithGoals.isEmpty {
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
                        logger.logUserAction("Add goal button tapped")
                        viewModel.showingAddGoal = true
                    }
                } else {
                    // Portrait layout
                    VStack(spacing: 0) {
                        if metricsWithGoals.count > 0 {
                            MetricFilterChipRow(
                                metrics: metricsWithGoals,
                                selectedFilter: $selectedFilter,
                                includeIndividualMetrics: false
                            )
                        }

                        ScrollView {
                            VStack(spacing: 16) {
                                if !booleanGoals.isEmpty {
                                    AdaptiveSectionHeader(
                                        title: "Completion Goals",
                                        subtitle: "Complete or avoid goals",
                                        icon: "target",
                                        iconColor: Color.currentPrimary
                                    )
                                    ForEach(booleanGoals) { metric in
                                        GoalCardView2(
                                            metric: metric,
                                            selectedDate: selectedDate,
                                            entries: entries,
                                            goals: goals
                                        )
                                    }
                                }

                                if !quantityGoals.isEmpty {
                                    AdaptiveSectionHeader(
                                        title: "Quantity Goals",
                                        subtitle: "Track measurable progress",
                                        icon: "chart.bar.fill",
                                        iconColor: Color.currentAccent
                                    )
                                    ForEach(quantityGoals) { metric in
                                        GoalCardView2(
                                            metric: metric,
                                            selectedDate: selectedDate,
                                            entries: entries,
                                            goals: goals
                                        )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .adaptiveScrollInset()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .id("goals-portrait-\(geometry.size.width)-\(geometry.size.height)")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .adaptiveFloatingActionButton {
                        logger.logUserAction("Add goal button tapped")
                        viewModel.showingAddGoal = true
                    }
                }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            }
            .themedBackground()
            .navigationTitle("Goals")
            .adaptiveNavigationBarTitleDisplayMode()
            .adaptiveAddButton(isEmpty: metricsWithGoals.isEmpty, label: "Add Goal") {
                logger.logUserAction("Add goal button tapped")
                viewModel.showingAddGoal = true
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
            .sheet(isPresented: $viewModel.showingAddMetric) {
                AddMetricView()
                    .onAppear {
                        logger.info("AddMetricView sheet presented")
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Panels
    private var leftPanel: some View {
        VStack(spacing: 12) {
            MetricFilterSidebar(
                title: "Filter Goals",
                metrics: metricsWithGoals,
                selectedFilter: $selectedFilter,
                includeIndividualMetrics: false
            )
            Spacer(minLength: 0)
        }
        .padding()
    }

    private var rightPanel: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        if !booleanGoals.isEmpty {
                            AdaptiveSectionHeader(
                                title: "Completion Goals",
                                subtitle: "Complete or avoid goals",
                                icon: "target",
                                iconColor: Color.currentPrimary
                            )
                            ForEach(booleanGoals) { metric in
                                GoalCardView2(
                                    metric: metric,
                                    selectedDate: selectedDate,
                                    entries: entries,
                                    goals: goals
                                )
                            }
                        }

                        if !quantityGoals.isEmpty {
                            AdaptiveSectionHeader(
                                title: "Quantity Goals",
                                subtitle: "Track measurable progress",
                                icon: "chart.bar.fill",
                                iconColor: Color.currentAccent
                            )
                            ForEach(quantityGoals) { metric in
                                GoalCardView2(
                                    metric: metric,
                                    selectedDate: selectedDate,
                                    entries: entries,
                                    goals: goals
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .adaptiveScrollInset()
                }
                .id("goals-landscape-\(geometry.size.width)-\(geometry.size.height)")
            }
        }
    }

    // MARK: - Components
}

// MARK: - GoalCardView2
struct GoalCardView2: View {
    let metric: Metric
    let selectedDate: Date
    let entries: [MetricEntry]
    let goals: [Goal]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var booleanGoals: [Goal] {
        goals.filter { $0.metric?.id == metric.id && $0.goalType == .boolean }
    }

    private var quantityGoals: [Goal] {
        goals.filter { $0.metric?.id == metric.id && $0.goalType == .quantity }
    }

    private var goalProgressResult: (current: Double, target: Double, percentage: Double) {
        if let goal = booleanGoals.first ?? quantityGoals.first {
            let result = GoalUtils.calculateGoalProgress(
                for: goal,
                metric: metric,
                entries: entries,
                selectedDate: selectedDate
            )
            return (result.current, result.target, result.percentage)
        }
        return (0, 0, 0)
    }

    private var progress: Double {
        goalProgressResult.percentage / 100.0
    }

    private var isCompleted: Bool {
        progress >= 1.0
    }

    private var progressText: String {
        let data = goalProgressResult
        if !booleanGoals.isEmpty {
            return "\(Int(data.current))/\(Int(data.target))"
        }
        if !quantityGoals.isEmpty {
            return "\(Int(data.current))/\(Int(data.target))"
        }
        return "0/0"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if dynamicTypeSize.usesAccessibilityLayout {
                accessibilityHeader
            } else {
                compactHeader
            }
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Goal for \(metric.name): \(progressText) progress")
    }

    private var compactHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            goalTypeIcon

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(metric.name)
                        .font(.headline)
                        .foregroundColor(.currentText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)
                    goalKindIcon
                }

                Text(goalKindLabel)
                    .font(.caption)
                    .foregroundColor(.currentSecondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            progressSummary(alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var accessibilityHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            goalTypeIcon

            Text(metric.name)
                .font(.headline)
                .foregroundColor(.currentText)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                goalKindIcon
                Text(goalKindLabel)
                    .font(.caption)
                    .foregroundColor(.currentSecondaryText)
            }

            progressSummary(alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var goalTypeIcon: some View {
        Image(systemName: metric.habitType.icon)
            .foregroundColor(metric.habitType == .positive ? .currentSuccess : .currentError)
            .font(.body)
            .frame(width: 24, height: 24)
    }

    @ViewBuilder
    private var goalKindIcon: some View {
        if !booleanGoals.isEmpty {
            Image(systemName: "target")
                .foregroundColor(.currentPrimary)
                .font(.caption)
        } else if !quantityGoals.isEmpty {
            Image(systemName: "chart.bar.fill")
                .foregroundColor(.currentAccent)
                .font(.caption)
        }
    }

    private var goalKindLabel: String {
        booleanGoals.isEmpty ? "Quantity Goal" : "Completion Goal"
    }

    private func progressSummary(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(progressText)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isCompleted ? .currentSuccess : .currentText)

            Text(isCompleted ? "Completed" : "In Progress")
                .font(.caption)
                .foregroundColor(isCompleted ? .currentSuccess : .currentSecondaryText)
        }
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [Metric.self, MetricEntry.self, Goal.self], inMemory: true)
}
