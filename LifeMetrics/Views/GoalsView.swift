import SwiftUI
import SwiftData

// MARK: - GoalsView
/// View for managing and tracking goal progress for habits and vices
struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var showingAddGoal = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient to match home view
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                if metricsWithGoals.isEmpty {
                    emptyStateView
                        .onAppear {
                            logger.info("GoalsView empty state displayed")
                        }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Date Navigation Section
                            dateNavigationSection
                            
                            // Summary Stats Section
                            summaryStatsSection
                            
                            // Habits Section
                            if !habitsWithGoals.isEmpty {
                                habitsSection
                            }
                            
                            // Vices Section
                            if !vicesWithGoals.isEmpty {
                                vicesSection
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
            .navigationTitle("Goals")
            .onAppear {
                logger.info("GoalsView appeared")
                logger.debug("Metrics with goals count: \(metricsWithGoals.count)", category: .data)
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
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
                    .onAppear {
                        logger.info("AddGoalView sheet presented")
                    }
            }
        }
    }
    
    private var metricsWithGoals: [Metric] {
        metrics.filter { $0.goalPeriod != nil && $0.goalTarget != nil }
    }
    
    private var habitsWithGoals: [Metric] {
        metricsWithGoals.filter { $0.safeHabitType == .positive }
    }
    
    private var vicesWithGoals: [Metric] {
        metricsWithGoals.filter { $0.safeHabitType == .vice }
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
                isCurrentWeek: Calendar.current.isDate(selectedDate, inSameDayAs: Date())
            )
            
            // Period info
            HStack {
                Text(periodDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button("This Week") {
                    logger.logUserAction("This Week button tapped")
                    selectedDate = Date()
                }
                .font(.caption)
                .foregroundColor(.blue)
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
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
            Image(systemName: "target")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                }
            
                VStack(spacing: 8) {
                    Text("No Goals Set")
                .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
            
                    Text("Create goals for your habits and vices to track your progress and stay motivated")
                        .font(.body)
                        .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Button {
                logger.logUserAction("Add goal button tapped")
                showingAddGoal = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Your First Goal")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var summaryStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Goal Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Habits Summary
                SummaryCard(
                    title: "Habits",
                    count: habitsWithGoals.count,
                    completed: habitsWithGoals.filter { calculateProgress($0, for: selectedDate) >= 1.0 }.count,
                    color: .green,
                    icon: "checkmark.circle.fill"
                )
                
                // Vices Summary
                SummaryCard(
                    title: "Vices",
                    count: vicesWithGoals.count,
                    completed: vicesWithGoals.filter { calculateProgress($0, for: selectedDate) >= 1.0 }.count,
                    color: .red,
                    icon: "xmark.circle.fill"
                )
            }
        }
        .padding(.top, 8)
    }
    
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Positive Habits")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(habitsWithGoals.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(habitsWithGoals, id: \.id) { metric in
                    EnhancedGoalCardView(metric: metric, selectedDate: selectedDate, entries: entries)
                }
            }
        }
    }
    
    private var vicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("Vices to Avoid")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(vicesWithGoals.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(vicesWithGoals, id: \.id) { metric in
                    EnhancedGoalCardView(metric: metric, selectedDate: selectedDate, entries: entries)
                }
            }
        }
    }
    
    private var addGoalButton: some View {
        Button {
            logger.logUserAction("Add goal floating button tapped")
            showingAddGoal = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add New Goal")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text("Set a goal for any habit or vice")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(16)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func calculateProgress(_ metric: Metric, for date: Date = Date()) -> Double {
        guard let target = metric.goalTarget else { return 0 }
        
        let currentProgress = calculateCurrentProgress(for: metric, for: date)
        // For weekly view, we always show progress against the full week (7 days)
        let effectiveTarget = min(target, 7)
        
        return min(Double(currentProgress) / Double(effectiveTarget), 1.0)
    }
    
    private func calculateCurrentProgress(for metric: Metric, for date: Date = Date()) -> Int {
        // Always calculate progress for the week containing the selected date
        let startDate = CalendarHelper.startOfWeek(for: date)
        let endDate = CalendarHelper.endOfWeek(for: date)
        
        let relevantEntries = entries.filter { entry in
            entry.metricID == metric.id &&
            entry.date >= startDate &&
            entry.date <= endDate
        }
        
        if metric.safeHabitType == .positive {
            return relevantEntries.filter { $0.value }.count
        } else {
            return relevantEntries.filter { !$0.value }.count
        }
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
                        .foregroundColor(.primary)
                    
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if count > 0 {
                    let percentage = Double(completed) / Double(count)
                    ProgressView(value: percentage, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: color))
                        .scaleEffect(x: 1, y: 0.8)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Enhanced Goal Card Component
struct EnhancedGoalCardView: View {
    let metric: Metric
    let selectedDate: Date
    let entries: [MetricEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditGoal = false
    @State private var showingHistory = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with habit name and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                Image(systemName: metric.safeHabitType.icon)
                    .foregroundColor(metric.safeHabitType == .positive ? .green : .red)
                            .font(.title3)
                
                    Text(metric.name)
                        .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Text(goalDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                statusIndicator
            }
            
            // Progress visualization
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(progressText)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }
                
                // Enhanced progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: max(8, CGFloat(progressValue) * 200), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progressValue)
            }
            
            // Time remaining
            if let timeRemaining = timeRemainingText {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                Text(timeRemaining)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
            }
            
            // Success indicator for historical periods
            if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                historicalSuccessIndicator
            }
            
            // Action buttons
            HStack {
                Button("History") {
                    showingHistory = true
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(6)
                
                Spacer()
                
                Button("Edit Goal") {
                    showingEditGoal = true
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
        .sheet(isPresented: $showingEditGoal) {
            EditGoalView(metric: metric)
                .onAppear {
                    logger.info("EditGoalView sheet presented - Metric: \(metric.name)")
                }
        }
        .sheet(isPresented: $showingHistory) {
            GoalHistoryView(metric: metric, entries: entries)
                .onAppear {
                    logger.info("GoalHistoryView sheet presented - Metric: \(metric.name)")
                }
        }
    }
    
    private var statusIndicator: some View {
        VStack(spacing: 4) {
            if progressValue >= 1.0 {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Complete")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            } else if progressValue >= 0.7 {
                Image(systemName: "clock.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("On Track")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("Behind")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var borderColor: Color {
        if progressValue >= 1.0 {
            return .green.opacity(0.3)
        } else if progressValue >= 0.7 {
            return .orange.opacity(0.3)
        } else {
            return .red.opacity(0.3)
        }
    }
    
    private var historicalSuccessIndicator: some View {
        HStack {
            Image(systemName: wasGoalAchieved ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(wasGoalAchieved ? .green : .red)
                .font(.title3)
            
            Text(wasGoalAchieved ? "Goal achieved this week!" : "Goal not achieved this week")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(wasGoalAchieved ? .green : .red)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background((wasGoalAchieved ? Color.green : Color.red).opacity(0.1))
        .cornerRadius(8)
    }
    
    private var wasGoalAchieved: Bool {
        return progressValue >= 1.0
    }
    
    private var goalDescription: String {
        guard let period = metric.goalPeriod, let target = metric.goalTarget else {
            return "No goal set"
        }
        
        if metric.safeHabitType == .vice {
            return "Max \(target) days per \(period.displayName.lowercased())"
        } else {
            return "\(target) days per \(period.displayName.lowercased())"
        }
    }
    
    private var progressValue: Double {
        guard let target = metric.goalTarget else { return 0 }
        
        let currentProgress = calculateCurrentProgress()
        // For weekly view, we always show progress against the full week (7 days)
        let effectiveTarget = min(target, 7)
        
        return min(Double(currentProgress) / Double(effectiveTarget), 1.0)
    }
    
    private var progressText: String {
        guard let target = metric.goalTarget else { return "No target" }
        
        let currentProgress = calculateCurrentProgress()
        // For weekly view, we always show progress against the full week (7 days)
        let effectiveTarget = min(target, 7)
        
        return "\(currentProgress)/\(effectiveTarget)"
    }
    
    private var progressColor: Color {
        let progress = progressValue
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var timeRemainingText: String? {
        guard let period = metric.goalPeriod else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .weekly:
            let daysRemaining = CalendarHelper.daysRemainingInPeriod(.weekly, from: now)
            return "\(daysRemaining) days left this week"
        case .biWeekly:
            let daysRemaining = CalendarHelper.daysRemainingInPeriod(.biWeekly, from: now)
            return "\(daysRemaining) days left this period"
        case .monthly:
            if let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end {
                let daysRemaining = calendar.dateComponents([.day], from: now, to: endOfMonth).day ?? 0
                return "\(daysRemaining) days left this month"
            }
        case .yearly:
            if let endOfYear = calendar.dateInterval(of: .year, for: now)?.end {
                let daysRemaining = calendar.dateComponents([.day], from: now, to: endOfYear).day ?? 0
                return "\(daysRemaining) days left this year"
            }
        }
        
        return nil
    }
    
    private func calculateCurrentProgress() -> Int {
        // Always calculate progress for the week containing the selected date
        let startDate = CalendarHelper.startOfWeek(for: selectedDate)
        let endDate = CalendarHelper.endOfWeek(for: selectedDate)
        
        let relevantEntries = entries.filter { entry in
            entry.metricID == metric.id &&
            entry.date >= startDate &&
            entry.date <= endDate
        }
        
        if metric.safeHabitType == .positive {
            return relevantEntries.filter { $0.value }.count
        } else {
            return relevantEntries.filter { !$0.value }.count
        }
    }
}

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var metrics: [Metric]
    
    @State private var selectedMetric: Metric?
    @State private var selectedPeriod: GoalPeriod = .monthly
    @State private var customTarget: Int = 20
    @State private var selectedPreset: GoalPreset?
    
    var body: some View {
        NavigationView {
            Form {
                // Metric Selection
                Section {
                    Picker("Select Habit", selection: $selectedMetric) {
                        Text("Choose a habit...").tag(nil as Metric?)
                        ForEach(metricsWithoutGoals, id: \.id) { metric in
                            HStack {
                                Image(systemName: metric.safeHabitType.icon)
                                    .foregroundColor(metric.safeHabitType == .positive ? .green : .red)
                                Text(metric.name)
                            }
                            .tag(metric as Metric?)
                        }
                    }
                } header: {
                    Text("Habit")
                } footer: {
                    if selectedMetric != nil {
                        Text(goalExplanationText)
                    }
                }
                
                if selectedMetric != nil {
                    // Period Selection
                    Section {
                        Picker("Period", selection: $selectedPeriod) {
                            ForEach(GoalPeriod.allCases, id: \.self) { period in
                                Text(period.displayName).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Goal Period")
                    }
                    
                    // Preset Options
                    Section {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(availablePresets, id: \.title) { preset in
                                PresetButton(
                                    preset: preset,
                                    isSelected: selectedPreset?.title == preset.title,
                                    action: { selectPreset(preset) }
                                )
                            }
                        }
                    } header: {
                        Text("Quick Options")
                    } footer: {
                        Text("Choose a preset or set a custom target below")
                    }
                    
                    // Custom Target
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Custom Target")
                                    .font(.headline)
                                Spacer()
                                Text("\(customTarget) days")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(customTarget) },
                                set: { customTarget = Int($0) }
                            ), in: 1.0...Double(maxTarget), step: 1.0)
                            .accentColor(.blue)
                            
                            HStack {
                                Text("1")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(maxTarget)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } header: {
                        Text("Custom Target")
                    }
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(selectedMetric == nil)
                }
            }
        }
    }
    
    private var metricsWithoutGoals: [Metric] {
        metrics.filter { $0.goalPeriod == nil || $0.goalTarget == nil }
    }
    
    private var goalExplanationText: String {
        guard let metric = selectedMetric else { return "" }
        
        if metric.safeHabitType == .positive {
            return "Track how many days you successfully do this habit"
        } else {
            return "Track how many days you successfully avoid this vice"
        }
    }
    
    private var maxTarget: Int {
        selectedPeriod.maxDays
    }
    
    private var availablePresets: [GoalPreset] {
        guard let metric = selectedMetric else { return [] }
        
        let isVice = metric.safeHabitType == .vice
        
        switch selectedPeriod {
        case .weekly:
            return isVice ? weeklyVicePresets : weeklyHabitPresets
        case .biWeekly:
            return isVice ? biWeeklyVicePresets : biWeeklyHabitPresets
        case .monthly:
            return isVice ? monthlyVicePresets : monthlyHabitPresets
        case .yearly:
            return isVice ? yearlyVicePresets : yearlyHabitPresets
        }
    }
    
    private func selectPreset(_ preset: GoalPreset) {
        selectedPreset = preset
        customTarget = preset.target
    }
    
    private func saveGoal() {
        guard let metric = selectedMetric else { return }
        
        metric.goalPeriod = selectedPeriod
        metric.goalTarget = customTarget
        
        try? modelContext.save()
        dismiss()
    }
}

struct EditGoalView: View {
    let metric: Metric
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPeriod: GoalPeriod
    @State private var customTarget: Int
    
    init(metric: Metric) {
        self.metric = metric
        self._selectedPeriod = State(initialValue: metric.goalPeriod ?? .monthly)
        self._customTarget = State(initialValue: metric.goalTarget ?? 20)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: metric.safeHabitType.icon)
                            .foregroundColor(metric.safeHabitType == .positive ? .green : .red)
                        Text(metric.name)
                            .font(.headline)
                    }
                } header: {
                    Text("Habit")
                }
                
                Section {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(GoalPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Goal Period")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Target")
                                .font(.headline)
                            Spacer()
                            Text("\(customTarget) days")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(customTarget) },
                            set: { customTarget = Int($0) }
                        ), in: 1.0...Double(maxTarget), step: 1.0)
                        .accentColor(.blue)
                        
                        HStack {
                            Text("1")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(maxTarget)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Target")
                } footer: {
                    Text(goalExplanationText)
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                }
            }
        }
    }
    
    private var maxTarget: Int {
        selectedPeriod.maxDays
    }
    
    private var goalExplanationText: String {
        if metric.safeHabitType == .positive {
            return "How many days do you want to do this habit per \(selectedPeriod.displayName.lowercased())?"
        } else {
            return "Maximum number of days you'll allow yourself to do this vice per \(selectedPeriod.displayName.lowercased())"
        }
    }
    
    private func saveGoal() {
        metric.goalPeriod = selectedPeriod
        metric.goalTarget = customTarget
        
        try? modelContext.save()
        dismiss()
    }
}

struct GoalPreset {
    let title: String
    let target: Int
    let description: String
}

// Preset configurations
private let weeklyHabitPresets = [
    GoalPreset(title: "Daily", target: 7, description: "Every day"),
    GoalPreset(title: "5 Days", target: 5, description: "5 days per week"),
    GoalPreset(title: "3 Days", target: 3, description: "3 days per week"),
    GoalPreset(title: "Weekends", target: 2, description: "Weekends only")
]

private let weeklyVicePresets = [
    GoalPreset(title: "Never", target: 0, description: "Complete avoidance"),
    GoalPreset(title: "Rarely", target: 1, description: "Max 1 day"),
    GoalPreset(title: "Occasionally", target: 2, description: "Max 2 days"),
    GoalPreset(title: "Moderately", target: 3, description: "Max 3 days")
]

private let biWeeklyHabitPresets = [
    GoalPreset(title: "Daily", target: 14, description: "Every day"),
    GoalPreset(title: "5x Week", target: 10, description: "5 days per week"),
    GoalPreset(title: "3x Week", target: 6, description: "3 days per week"),
    GoalPreset(title: "Weekends", target: 4, description: "Weekends only")
]

private let biWeeklyVicePresets = [
    GoalPreset(title: "Never", target: 0, description: "Complete avoidance"),
    GoalPreset(title: "Rarely", target: 2, description: "Max 2 days"),
    GoalPreset(title: "Occasionally", target: 4, description: "Max 4 days"),
    GoalPreset(title: "Moderately", target: 6, description: "Max 6 days")
]

private let monthlyHabitPresets = [
    GoalPreset(title: "Daily", target: 30, description: "Every day"),
    GoalPreset(title: "5x Week", target: 20, description: "5 days per week"),
    GoalPreset(title: "3x Week", target: 12, description: "3 days per week"),
    GoalPreset(title: "Weekends", target: 8, description: "Weekends only")
]

private let monthlyVicePresets = [
    GoalPreset(title: "Never", target: 0, description: "Complete avoidance"),
    GoalPreset(title: "Rarely", target: 2, description: "Max 2 days"),
    GoalPreset(title: "Occasionally", target: 5, description: "Max 5 days"),
    GoalPreset(title: "Moderately", target: 10, description: "Max 10 days")
]

private let yearlyHabitPresets = [
    GoalPreset(title: "Daily", target: 365, description: "Every day"),
    GoalPreset(title: "5x Week", target: 260, description: "5 days per week"),
    GoalPreset(title: "3x Week", target: 156, description: "3 days per week"),
    GoalPreset(title: "Weekends", target: 104, description: "Weekends only")
]

private let yearlyVicePresets = [
    GoalPreset(title: "Never", target: 0, description: "Complete avoidance"),
    GoalPreset(title: "Rarely", target: 24, description: "Max 24 days"),
    GoalPreset(title: "Occasionally", target: 60, description: "Max 60 days"),
    GoalPreset(title: "Moderately", target: 120, description: "Max 120 days")
]

struct PresetButton: View {
    let preset: GoalPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(preset.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(preset.target) days")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Goal History View
struct GoalHistoryView: View {
    let metric: Metric
    let entries: [MetricEntry]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: GoalPeriod = .monthly
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: metric.safeHabitType.icon)
                            .foregroundColor(metric.safeHabitType == .positive ? .green : .red)
                            .font(.title2)
                        
                        Text(metric.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    Text("Goal History")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                
                // Period selector
                VStack(spacing: 16) {
                    HStack {
                        Text("View Periods")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(GoalPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 16)
                
                // History list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(historicalPeriods, id: \.startDate) { period in
                            HistoricalPeriodCard(
                                metric: metric,
                                period: period,
                                entries: entries
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Goal History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var historicalPeriods: [HistoricalPeriod] {
        guard let goalPeriod = metric.goalPeriod, let target = metric.goalTarget else { return [] }
        
        var periods: [HistoricalPeriod] = []
        let calendar = Calendar.current
        let now = Date()
        
        // Generate periods going back in time
        var currentDate = now
        for _ in 0..<12 { // Show last 12 periods
            let startDate = CalendarHelper.startOfPeriod(goalPeriod, for: currentDate)
            let endDate = CalendarHelper.endOfPeriod(goalPeriod, for: currentDate)
            
            let periodEntries = entries.filter { entry in
                entry.metricID == metric.id &&
                entry.date >= startDate &&
                entry.date <= endDate
            }
            
            let progress = calculateProgress(for: periodEntries, target: target, isVice: metric.safeHabitType == .vice)
            
            periods.append(HistoricalPeriod(
                startDate: startDate,
                endDate: endDate,
                progress: progress,
                target: target
            ))
            
            // Move to previous period
            currentDate = calendar.date(byAdding: .day, value: -1, to: startDate) ?? currentDate
        }
        
        return periods
    }
    
    private func calculateProgress(for entries: [MetricEntry], target: Int, isVice: Bool) -> Int {
        if isVice {
            return entries.filter { !$0.value }.count
        } else {
            return entries.filter { $0.value }.count
        }
    }
}

struct HistoricalPeriod {
    let startDate: Date
    let endDate: Date
    let progress: Int
    let target: Int
    
    var wasAchieved: Bool {
        return progress >= target
    }
    
    var periodDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            return formatter.string(from: startDate)
        } else {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
}

struct HistoricalPeriodCard: View {
    let metric: Metric
    let period: HistoricalPeriod
    let entries: [MetricEntry]
    
    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            VStack(spacing: 4) {
                Image(systemName: period.wasAchieved ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(period.wasAchieved ? .green : .red)
                    .font(.title2)
                
                Text(period.wasAchieved ? "✓" : "✗")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(period.wasAchieved ? .green : .red)
            }
            
            // Period info
            VStack(alignment: .leading, spacing: 4) {
                Text(period.periodDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(period.progress)/\(period.target) days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Progress bar
            VStack(alignment: .trailing, spacing: 4) {
                let percentage = Double(period.progress) / Double(period.target)
                ProgressView(value: percentage, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: period.wasAchieved ? .green : .red))
                    .frame(width: 80)
                
                Text("\(Int(percentage * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(period.wasAchieved ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Weekly Date Navigation Component
struct WeeklyDateNavigationView: View {
    @Binding var selectedDate: Date
    let canGoBack: Bool
    let isCurrentWeek: Bool
    
    var body: some View {
        HStack {
            Button {
                if canGoBack {
                    selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(canGoBack ? .blue : .gray)
            }
            .disabled(!canGoBack)
            
            Spacer()
            
            Button {
                // This will be handled by parent view
            } label: {
                VStack(spacing: 2) {
                    Text(weekDisplayText)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(weekRangeText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var weekDisplayText: String {
        if isCurrentWeek {
            return "This Week"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            let startOfWeek = CalendarHelper.startOfWeek(for: selectedDate)
            return formatter.string(from: startOfWeek)
        }
    }
    
    private var weekRangeText: String {
        let startOfWeek = CalendarHelper.startOfWeek(for: selectedDate)
        let endOfWeek = CalendarHelper.endOfWeek(for: selectedDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
