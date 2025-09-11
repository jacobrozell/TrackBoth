import SwiftUI
import SwiftData

// MARK: - HomeView
/// Main view displaying habit tracking interface with stats, metrics list, and date navigation
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @State private var viewModel = HomeViewModel()
    
    // MARK: - Computed Properties
    private var totalHabits: Int {
        viewModel.totalHabits(from: metrics)
    }
    
    private var totalVices: Int {
        viewModel.totalVices(from: metrics)
    }
    
    private var activeStreaks: Int {
        viewModel.activeStreaks(from: metrics, entries: entries)
    }
    
    private var todayCompleted: Int {
        viewModel.todayCompleted(from: metrics, entries: entries)
    }
    
    private var canGoBack: Bool {
        viewModel.canGoBack
    }
    
    private var isToday: Bool {
        viewModel.isToday
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    if metrics.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)

                            Text("No habits yet")
                                .font(.title2)
                                .fontWeight(.medium)

                            Text("Tap the + button below to add your first habit")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Stats Overview Section
                        VStack(spacing: 12) {
                            // Date Navigation Header
                            HStack {
                                Button {
                                    viewModel.goToPreviousDay()
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(canGoBack ? .blue : .gray)
                                }
                                .disabled(!canGoBack)
                                
                                Spacer()
                                
                                Button {
                                    viewModel.showingDatePicker = true
                                } label: {
                                    VStack(spacing: 2) {
                                        Text(isToday ? "Today" : DateFormatter.dayFormatter.string(from: viewModel.selectedDate))
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(DateFormatter.dateFormatter.string(from: viewModel.selectedDate))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    viewModel.goToNextDay()
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            // Today Button (right-aligned like Goals)
                            if !isToday {
                                HStack {
                                    Spacer()
                                    Button("Today") {
                                        viewModel.goToToday()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            // Quick Stats
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "Habits",
                                    value: "\(totalHabits)",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                                
                                StatCard(
                                    title: "Vices",
                                    value: "\(totalVices)",
                                    icon: "xmark.circle.fill",
                                    color: .red
                                )
                                
                                StatCard(
                                    title: "Streaks",
                                    value: "\(activeStreaks)",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                                
                                StatCard(
                                    title: "Today",
                                    value: "\(todayCompleted)/\(metrics.count)",
                                    icon: "calendar",
                                    color: .blue
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 16)
                        .background(Color(.systemGray6))
                        
                        // Habits List
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(metrics) { metric in
                                    EnhancedMetricRowView(metric: metric, selectedDate: viewModel.selectedDate)
                                        .contextMenu {
                                            Button {
                                                viewModel.showEditMetric(metric)
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            Button(role: .destructive) {
                                                viewModel.showDeleteConfirmation(for: metric)
                                            } label: {
                                                Label("Delete Habit", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .overlay(alignment: .bottomTrailing) {
                            FloatingActionButton {
                                viewModel.showAddMetric()
                            }
                        }
                    }
                }
                .navigationTitle("QuickLog")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.showSettings()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showingAddMetric) {
                    AddMetricView()
                }
                .sheet(item: $viewModel.metricToEdit) { metric in
                    EditMetricView(metric: metric)
                }
                .sheet(isPresented: $viewModel.showingSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $viewModel.showingDatePicker) {
                    DatePickerSheet(selectedDate: $viewModel.selectedDate)
                }
                .alert("Delete Habit", isPresented: $viewModel.showingDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {
                        viewModel.metricToDelete = nil
                    }
                    Button("Delete", role: .destructive) {
                        viewModel.deleteMetric(in: modelContext, entries: entries)
                    }
                } message: {
                    if let metric = viewModel.metricToDelete {
                        Text("Are you sure you want to delete '\(metric.name)'? This will also delete all associated entries and cannot be undone.")
                    }
                }
                .onAppear {
                    // Clean up any duplicate or empty entries on app launch
                    MetricEntry.cleanupEmptyEntries(in: modelContext, entries: entries)
                    // No migration needed; goals are embedded
                    try? modelContext.save()
                }
            }
        }
    }
    
}

struct EditMetricView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [MetricEntry]
    @State var metric: Metric
    @State private var name: String = ""
    @State private var habitType: HabitType = .positive
    @State private var goalPeriod: GoalPeriod = .monthly
    @State private var goalTarget: Int = 20
    @State private var primaryMotivation: String = ""
    
    private var maxTargetForEditPeriod: Int {
        goalPeriod.maxDays
    }
    
    private var quickPresetsForEdit: [QuickPreset] {
        let isVice = habitType == .vice
        
        switch goalPeriod {
        case .weekly:
            return isVice ? [
                QuickPreset(title: "Never", target: 0),
                QuickPreset(title: "Rarely", target: 1),
                QuickPreset(title: "Occasionally", target: 2),
                QuickPreset(title: "Moderately", target: 3)
            ] : [
                QuickPreset(title: "Daily", target: 7),
                QuickPreset(title: "5 Days", target: 5),
                QuickPreset(title: "3 Days", target: 3),
                QuickPreset(title: "Weekends", target: 2)
            ]
        case .biWeekly:
            return isVice ? [
                QuickPreset(title: "Never", target: 0),
                QuickPreset(title: "Rarely", target: 2),
                QuickPreset(title: "Occasionally", target: 4),
                QuickPreset(title: "Moderately", target: 6)
            ] : [
                QuickPreset(title: "Daily", target: 14),
                QuickPreset(title: "5x Week", target: 10),
                QuickPreset(title: "3x Week", target: 6),
                QuickPreset(title: "Weekends", target: 4)
            ]
        case .monthly:
            return isVice ? [
                QuickPreset(title: "Never", target: 0),
                QuickPreset(title: "Rarely", target: 2),
                QuickPreset(title: "Occasionally", target: 5),
                QuickPreset(title: "Moderately", target: 10)
            ] : [
                QuickPreset(title: "Daily", target: 30),
                QuickPreset(title: "5x Week", target: 20),
                QuickPreset(title: "3x Week", target: 12),
                QuickPreset(title: "Weekends", target: 8)
            ]
        case .yearly:
            return isVice ? [
                QuickPreset(title: "Never", target: 0),
                QuickPreset(title: "Rarely", target: 24),
                QuickPreset(title: "Occasionally", target: 60),
                QuickPreset(title: "Moderately", target: 120)
            ] : [
                QuickPreset(title: "Daily", target: 365),
                QuickPreset(title: "5x Week", target: 260),
                QuickPreset(title: "3x Week", target: 156),
                QuickPreset(title: "Weekends", target: 104)
            ]
        }
    }

    init(metric: Metric) {
        _metric = State(initialValue: metric)
        _name = State(initialValue: metric.name)
        _habitType = State(initialValue: metric.safeHabitType)
        _goalPeriod = State(initialValue: metric.goalPeriod ?? .monthly)
        _goalTarget = State(initialValue: metric.goalTarget ?? 20)
        _primaryMotivation = State(initialValue: metric.primaryMotivation ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Habit name", text: $name)
                } header: {
                    Text("Habit Name")
                }

                Section {
                    Picker("Habit Type", selection: $habitType) {
                        ForEach(HabitType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Habit Type")
                }

                // Primary motivation section
                Section {
                    TextField(
                        habitType == .vice ? "Why do you want to avoid this?" : "What motivates you to do this?",
                        text: $primaryMotivation, 
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                } header: {
                    Text("Primary Motivation")
                } footer: {
                    Text(habitType == .vice ? 
                         "Your main reason for avoiding this vice. Used to keep you focused." :
                         "Your main motivation for doing this habit. Helps keep you focused on your goals.")
                }

                Section {
                    Picker("Period", selection: $goalPeriod) {
                        ForEach(GoalPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Improved goal target selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(habitType == .vice ? "Max Days" : "Target Days")
                                .font(.headline)
                            Spacer()
                            Text("\(goalTarget)")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(goalTarget) },
                            set: { goalTarget = Int($0) }
                        ), in: 1.0...Double(maxTargetForEditPeriod), step: 1.0)
                        .accentColor(.blue)
                        
                        HStack {
                            Text("1")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(maxTargetForEditPeriod)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Quick preset buttons with enhanced styling
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick Presets")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(quickPresetsForEdit, id: \.title) { preset in
                                    Button(action: {
                                        goalTarget = preset.target
                                    }) {
                                        VStack(spacing: 4) {
                                            Text(preset.title)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("\(preset.target) days")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(goalTarget == preset.target ? 
                                                    Color.blue.opacity(0.2) : 
                                                    Color(.systemGray6))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(goalTarget == preset.target ? 
                                                    Color.blue : 
                                                    Color(.systemGray4), lineWidth: goalTarget == preset.target ? 2 : 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                } header: {
                    Text(habitType == .vice ? "Target (Maximum Days)" : "Target (Days)")
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveChanges() }
                }
            }
            .onAppear {
                // Primary motivation is already loaded from metric.primaryMotivation in init
            }
        }
    }

    private func saveChanges() {
        metric.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        metric.habitType = habitType
        let trimmedMotivation = primaryMotivation.trimmingCharacters(in: .whitespacesAndNewlines)
        metric.primaryMotivation = trimmedMotivation.isEmpty ? nil : trimmedMotivation
        metric.goalPeriod = goalPeriod
        metric.goalTarget = goalTarget

        try? modelContext.save()
        dismiss()
    }
}


struct AddMetricView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var metricName = ""
    @State private var selectedHabitType: HabitType = .positive
    @State private var primaryMotivation = ""
    @State private var selectedGoalPeriod: GoalPeriod = .monthly
    @State private var goalTarget: Int = 20
    
    private var maxTargetForPeriod: Int {
        selectedGoalPeriod.maxDays
    }
    
    private var quickPresets: [QuickPreset] {
        let isVice = selectedHabitType == .vice
        
        switch selectedGoalPeriod {
        case .weekly:
            return isVice ? [
                QuickPreset(title: "Never", target: 0),
                QuickPreset(title: "Rarely", target: 1),
                QuickPreset(title: "Occasionally", target: 2),
                QuickPreset(title: "Moderately", target: 3)
            ] : [
                QuickPreset(title: "Daily", target: 7),
                QuickPreset(title: "5 Days", target: 5),
                QuickPreset(title: "3 Days", target: 3),
                QuickPreset(title: "Weekends", target: 2)
            ]
        case .biWeekly:
            return isVice ? [
                QuickPreset(title: "Never", target: 0),
                QuickPreset(title: "Rarely", target: 2),
                QuickPreset(title: "Occasionally", target: 4),
                QuickPreset(title: "Moderately", target: 6)
            ] : [
                QuickPreset(title: "Daily", target: 14),
                QuickPreset(title: "5x Week", target: 10),
                QuickPreset(title: "3x Week", target: 6),
                QuickPreset(title: "Weekends", target: 4)
            ]
        case .monthly:
            return isVice ? [
                QuickPreset(title: "Never", target: 0),
                QuickPreset(title: "Rarely", target: 2),
                QuickPreset(title: "Occasionally", target: 5),
                QuickPreset(title: "Moderately", target: 10)
            ] : [
                QuickPreset(title: "Daily", target: 30),
                QuickPreset(title: "5x Week", target: 20),
                QuickPreset(title: "3x Week", target: 12),
                QuickPreset(title: "Weekends", target: 8)
            ]
        case .yearly:
            return isVice ? [
                QuickPreset(title: "Never", target: 0),
                QuickPreset(title: "Rarely", target: 24),
                QuickPreset(title: "Occasionally", target: 60),
                QuickPreset(title: "Moderately", target: 120)
            ] : [
                QuickPreset(title: "Daily", target: 365),
                QuickPreset(title: "5x Week", target: 260),
                QuickPreset(title: "3x Week", target: 156),
                QuickPreset(title: "Weekends", target: 104)
            ]
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Habit name", text: $metricName)
                } header: {
                    Text("Habit Name")
                } footer: {
                    Text(selectedHabitType == .positive ? 
                         "Enter a name for your positive habit (e.g., 'Exercise', 'Read', 'Meditate')" :
                         "Enter a name for the habit you want to avoid (e.g., 'Smoking', 'Junk Food', 'Social Media')")
                }
                
                Section {
                    Picker("Habit Type", selection: $selectedHabitType) {
                        ForEach(HabitType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Habit Type")
                } footer: {
                    HStack {
                        Image(systemName: selectedHabitType.icon)
                            .foregroundColor(selectedHabitType == .positive ? .green : .red)
                        Text(selectedHabitType == .positive ? 
                             "Track days when you successfully do this positive habit" :
                             "Track days when you successfully avoid this vice")
                    }
                }
                
                // Primary motivation section
                Section {
                    TextField(
                        selectedHabitType == .vice ? "Why do you want to avoid this?" : "What motivates you to do this?",
                        text: $primaryMotivation, 
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                } header: {
                    Text("Primary Motivation")
                } footer: {
                    Text(selectedHabitType == .vice ? 
                         "This will be your main reason for avoiding this vice. You can add more motivations later." :
                         "This will be your main motivation for doing this habit. Helps keep you focused on your goals.")
                }
                
                // Target section (embedded into habit)
                Section {
                    Picker("Period", selection: $selectedGoalPeriod) {
                        ForEach(GoalPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Improved goal target selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(selectedHabitType == .vice ? "Max Days" : "Target Days")
                                .font(.headline)
                            Spacer()
                            Text("\(goalTarget)")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(goalTarget) },
                            set: { goalTarget = Int($0) }
                        ), in: 1.0...Double(maxTargetForPeriod), step: 1.0)
                        .accentColor(.blue)
                        
                        HStack {
                            Text("1")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(maxTargetForPeriod)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Quick preset buttons with enhanced styling
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick Presets")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(quickPresets, id: \.title) { preset in
                                    Button(action: {
                                        goalTarget = preset.target
                                    }) {
                                        VStack(spacing: 4) {
                                            Text(preset.title)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.primary)
                                            Text("\(preset.target) days")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(goalTarget == preset.target ? 
                                                    Color.blue.opacity(0.2) : 
                                                    Color(.systemGray6))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(goalTarget == preset.target ? 
                                                    Color.blue : 
                                                    Color(.systemGray4), lineWidth: goalTarget == preset.target ? 2 : 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                } header: {
                    Text(selectedHabitType == .vice ? "Target (Maximum Days)" : "Target (Days)")
                } footer: {
                    Text(selectedHabitType == .vice ?
                         "Maximum number of days you'll allow yourself to do this vice per \(selectedGoalPeriod.displayName.lowercased())." :
                         "How many days do you want to do this habit per \(selectedGoalPeriod.displayName.lowercased())?")
                }

            }
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMetric()
                    }
                    .disabled(metricName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveMetric() {
        let trimmedName = metricName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let trimmedMotivation = primaryMotivation.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let metric = Metric(
            name: trimmedName,
            habitType: selectedHabitType,
            primaryMotivation: trimmedMotivation.isEmpty ? nil : trimmedMotivation,
            goalPeriod: selectedGoalPeriod,
            goalTarget: goalTarget
        )
        modelContext.insert(metric)
        
        try? modelContext.save()
        dismiss()
    }
}


struct QuickPreset {
    let title: String
    let target: Int
}

// MARK: - New Components

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
