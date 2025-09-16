import SwiftUI
import SwiftData

// MARK: - GoalsView
/// View for managing and tracking goal progress for habits and vices
struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @Query private var goals: [Goal]
    @State private var viewModel = GoalsViewModel()
    @State private var selectedDate = Date()
    @State private var showingAddMetric = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    if viewModel.metricsWithGoals(metrics).isEmpty {
                        VStack {
                            Spacer()
                            EmptyStateView(
                                icon: metrics.isEmpty ? "plus.circle.fill" : "target",
                                title: metrics.isEmpty ? "No Habits Yet" : "No Goals Set",
                                subtitle: metrics.isEmpty ? 
                                    "Create your first habit to start tracking your progress and building better routines" :
                                    "Create goals for your habits and vices to track your progress and stay motivated",
                                actionTitle: metrics.isEmpty ? "Create Your First Habit" : "Create Your First Goal",
                                action: {
                                    logger.logUserAction(metrics.isEmpty ? "Add habit button tapped" : "Add goal button tapped")
                                    if metrics.isEmpty {
                                        showingAddMetric = true
                                    } else {
                                        viewModel.showAddGoal()
                                    }
                                }
                            )
                            Spacer()
                        }
                        .onAppear {
                            logger.info("GoalsView empty state displayed")
                        }
                    } else {
                        if geometry.size.width > geometry.size.height {
                            // Landscape layout
                            HStack(spacing: 0) {
                                // Left side - Date Navigation and Summary Stats
                                VStack(spacing: 16) {
                                    dateNavigationSection
                                    summaryStatsSection
                                    Spacer()
                                }
                                .frame(width: min(300, geometry.size.width * 0.35))
                                .padding(.horizontal, 16)
                                .background(Color.currentSecondaryBackground.opacity(0.3))
                                
                                Divider()
                                    .frame(height: geometry.size.height)
                                
                                // Right side - Goals sections
                                ScrollView {
                                    VStack(spacing: 24) {
                                        // Boolean Goals Sections
                                        if !viewModel.habitsWithBooleanGoals(metrics).isEmpty || !viewModel.vicesWithBooleanGoals(metrics).isEmpty {
                                            booleanGoalsSection
                                        }
                                        
                                        // Quantity Goals Sections
                                        if !viewModel.habitsWithQuantityGoals(metrics).isEmpty || !viewModel.vicesWithQuantityGoals(metrics).isEmpty {
                                            quantityGoalsSection
                                        }
                                        
                                        // Add Goal Button
                                        addGoalButton
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 20)
                                }
                            }
                        } else {
                            // Portrait layout
                            ScrollView {
                                VStack(spacing: 24) {
                                    // Date Navigation Section
                                    dateNavigationSection
                                    
                                    // Summary Stats Section
                                    summaryStatsSection
                                    
                                    // Boolean Goals Sections
                                    if !viewModel.habitsWithBooleanGoals(metrics).isEmpty || !viewModel.vicesWithBooleanGoals(metrics).isEmpty {
                                        booleanGoalsSection
                                    }
                                    
                                    // Quantity Goals Sections
                                    if !viewModel.habitsWithQuantityGoals(metrics).isEmpty || !viewModel.vicesWithQuantityGoals(metrics).isEmpty {
                                        quantityGoalsSection
                                    }
                                    
                                    // Add Goal Button
                                    addGoalButton
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Goals")
            .onAppear {
                logger.info("GoalsView appeared")
                logger.debug("Metrics with goals count: \(viewModel.metricsWithGoals(metrics).count)", category: .data)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddGoal) {
                AddGoalView()
                    .onAppear {
                        logger.info("AddGoalView sheet presented")
                    }
            }
            .sheet(isPresented: $showingAddMetric) {
                AddMetricView()
                    .onAppear {
                        logger.info("AddMetricView sheet presented")
                    }
            }
        }
    }
    
    
    private var dateNavigationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Goal Period")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            WeeklyDateNavigationView(
                selectedDate: $selectedDate,
                canGoBack: true,
                canGoForward: !CalendarHelper.isSameWeek(selectedDate, Date()),
                isCurrentWeek: CalendarHelper.isSameWeek(selectedDate, Date())
            )
            
            // Period info
            HStack {
                Text(periodDescription)
                    .font(.subheadline)
                    .foregroundColor(Color.currentSecondaryText)
                Spacer()
                if !CalendarHelper.isSameWeek(selectedDate, Date()) {
                    Button("This Week") {
                        logger.logUserAction("This Week button tapped")
                        selectedDate = Date()
                    }
                    .font(.caption)
                    .foregroundColor(Color.currentPrimary)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private var periodDescription: String {
        let calendar = Calendar.current
        let startOfWeek = CalendarHelper.startOfWeek(for: selectedDate)
        let endOfWeek = CalendarHelper.endOfWeek(for: selectedDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        if calendar.isDate(selectedDate, inSameDayAs: Date()) {
            return "Current week: \(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
        } else {
            return "Week of: \(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
        }
    }
    
    
    private var summaryStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Goal Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Boolean Goals Summary
                    SummaryCard(
                        title: "Boolean Goals",
                        count: viewModel.habitsWithBooleanGoals(metrics).count + viewModel.vicesWithBooleanGoals(metrics).count,
                        completed: (viewModel.habitsWithBooleanGoals(metrics) + viewModel.vicesWithBooleanGoals(metrics)).filter { calculateProgress($0, for: selectedDate) >= 1.0 }.count,
                        color: Color.currentPrimary,
                        icon: "target"
                    )
                    
                    // Quantity Goals Summary
                    SummaryCard(
                        title: "Quantity Goals",
                        count: viewModel.habitsWithQuantityGoals(metrics).count + viewModel.vicesWithQuantityGoals(metrics).count,
                        completed: (viewModel.habitsWithQuantityGoals(metrics) + viewModel.vicesWithQuantityGoals(metrics)).filter { calculateQuantityProgress(for: $0, for: selectedDate) >= 1.0 }.count,
                        color: Color.currentAccent,
                        icon: "chart.bar.fill"
                    )
                }
                
                HStack(spacing: 16) {
                    // Habits Summary
                    SummaryCard(
                        title: "Habits",
                        count: viewModel.habitsWithGoals(metrics).count,
                        completed: viewModel.habitsWithGoals(metrics).filter { metric in
                            if GoalUtils.hasGoals(ofType: .quantity, in: metric) {
                                return calculateQuantityProgress(for: metric, for: selectedDate) >= 1.0
                            } else {
                                return calculateProgress(metric, for: selectedDate) >= 1.0
                            }
                        }.count,
                        color: Color.currentSuccess,
                        icon: "checkmark.circle.fill"
                    )
                    
                    // Vices Summary
                    SummaryCard(
                        title: "Vices",
                        count: viewModel.vicesWithGoals(metrics).count,
                        completed: viewModel.vicesWithGoals(metrics).filter { metric in
                            if GoalUtils.hasGoals(ofType: .quantity, in: metric) {
                                return calculateQuantityProgress(for: metric, for: selectedDate) >= 1.0
                            } else {
                                return calculateProgress(metric, for: selectedDate) >= 1.0
                            }
                        }.count,
                        color: Color.currentError,
                        icon: "xmark.circle.fill"
                    )
                }
            }
        }
        .padding(.top, 8)
    }
    
    private var booleanGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(Color.currentPrimary)
                    .font(.title2)
                
                Text("Boolean Goals")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(viewModel.habitsWithBooleanGoals(metrics).count + viewModel.vicesWithBooleanGoals(metrics).count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.currentPrimary)
                    .cornerRadius(8)
            }
            
            VStack(spacing: 16) {
                // Boolean Habits
                if !viewModel.habitsWithBooleanGoals(metrics).isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            
                            Text("Positive Habits")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(viewModel.habitsWithBooleanGoals(metrics).count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(6)
                        }
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.habitsWithBooleanGoals(metrics), id: \.id) { metric in
                                MultiGoalCardView(metric: metric, selectedDate: selectedDate, entries: entries, goals: goals)
                            }
                        }
                    }
                }
                
                // Boolean Vices
                if !viewModel.vicesWithBooleanGoals(metrics).isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                            
                            Text("Vices to Avoid")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(viewModel.vicesWithBooleanGoals(metrics).count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(6)
                        }
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.vicesWithBooleanGoals(metrics), id: \.id) { metric in
                                MultiGoalCardView(metric: metric, selectedDate: selectedDate, entries: entries, goals: goals)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var quantityGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Quantity Goals")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(viewModel.habitsWithQuantityGoals(metrics).count + viewModel.vicesWithQuantityGoals(metrics).count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple)
                    .cornerRadius(8)
            }
            
            VStack(spacing: 16) {
                // Quantity Habits
                if !viewModel.habitsWithQuantityGoals(metrics).isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            
                            Text("Positive Habits")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(viewModel.habitsWithQuantityGoals(metrics).count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(6)
                        }
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.habitsWithQuantityGoals(metrics), id: \.id) { metric in
                                MultiGoalCardView(metric: metric, selectedDate: selectedDate, entries: entries, goals: goals)
                            }
                        }
                    }
                }
                
                // Quantity Vices
                if !viewModel.vicesWithQuantityGoals(metrics).isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                            
                            Text("Vices to Avoid")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(viewModel.vicesWithQuantityGoals(metrics).count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(6)
                        }
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.vicesWithQuantityGoals(metrics), id: \.id) { metric in
                                MultiGoalCardView(metric: metric, selectedDate: selectedDate, entries: entries, goals: goals)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var addGoalButton: some View {
        Button {
            logger.logUserAction("Add goal floating button tapped")
            viewModel.showAddGoal()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color.currentPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add New Goal")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.currentPrimary)
                    
                    Text("Set a goal for any habit or vice")
                        .font(.caption)
                        .foregroundColor(Color.currentSecondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.currentPrimary)
            }
            .padding(16)
            .background(Color.currentPrimary.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.currentPrimary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func calculateProgress(_ metric: Metric, for date: Date = Date()) -> Double {
        let progress = viewModel.goalProgress(for: metric, entries: entries, selectedDate: date)
        return progress.percentage / 100.0
    }
    
    private func calculateCurrentProgress(for metric: Metric, for date: Date = Date()) -> Int {
        let progress = viewModel.goalProgress(for: metric, entries: entries, selectedDate: date)
        return progress.current
    }
    
    private func calculateQuantityProgress(for metric: Metric, for date: Date = Date()) -> Double {
        let progress = viewModel.quantityGoalProgress(for: metric, entries: entries, selectedDate: date)
        return progress.percentage
    }
}

// MARK: - Summary Card Component
struct SummaryCard: View {
    let title: String
    let count: Int
    let completed: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(completed)/\(count)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.currentText)
                    
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(Color.currentSecondaryText)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.currentText)
                
                if count > 0 {
                    let percentage = Double(completed) / Double(count)
                    ProgressView(value: percentage, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: color))
                        .scaleEffect(x: 1, y: 0.8)
                }
            }
        }
        .padding(16)
        .background(Color.appBackgroundSecondary)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [Metric.self, MetricEntry.self, Goal.self], inMemory: true)
}
