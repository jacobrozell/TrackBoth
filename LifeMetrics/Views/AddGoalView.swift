import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var metrics: [Metric]
    
    let selectedMetric: Metric?
    @State private var goalType: GoalType = .boolean
    @State private var selectedPeriod: GoalPeriod = .monthly
    @State private var customTarget: Int = 20
    @State private var selectedPreset: GoalPreset?
    @State private var pickerSelectedMetric: Metric?
    
    init(selectedMetric: Metric? = nil) {
        self.selectedMetric = selectedMetric
    }
    // Quantity goal specific
    @State private var quantityGoalType: QuantityGoalType = .totalPeriod
    @State private var quantityTarget: Int = 10
    @State private var quantityUnit: String = "times"
    @State private var selectedQuantityPreset: QuantityPreset?
    @State private var showingConflictAlert = false
    
    private var effectiveSelectedMetric: Metric? {
        return selectedMetric ?? pickerSelectedMetric
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Metric Selection (only show if no metric pre-selected)
                if selectedMetric == nil {
                    Section {
                        Picker("Select Habit", selection: $pickerSelectedMetric) {
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
                        if effectiveSelectedMetric != nil {
                            Text(goalExplanationText)
                        }
                    }
                } else {
                    // Show selected metric info
                    Section {
                        HStack {
                            Image(systemName: effectiveSelectedMetric!.safeHabitType.icon)
                                .foregroundColor(effectiveSelectedMetric!.safeHabitType == .positive ? .green : .red)
                            Text(effectiveSelectedMetric!.name)
                                .font(.headline)
                        }
                    } header: {
                        Text("Habit")
                    } footer: {
                        Text(goalExplanationText)
                    }
                }
                
                if effectiveSelectedMetric != nil {
                    // Goal Type Selection
                    Section {
                        Picker("Goal Type", selection: $goalType) {
                            Text("Boolean Goal").tag(GoalType.boolean)
                            Text("Quantity Goal").tag(GoalType.quantity)
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Goal Type")
                    } footer: {
                        Text(goalTypeExplanation)
                    }
                    
                    if goalType == .boolean {
                        // Boolean Goal Configuration
                        booleanGoalConfiguration
                    } else {
                        // Quantity Goal Configuration
                        quantityGoalConfiguration
                    }
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Goal Conflict", isPresented: $showingConflictAlert) {
                Button("OK") { }
            } message: {
                Text("You already have a \(goalType.displayName.lowercased()) goal for \(selectedPeriod.displayName.lowercased()). Please choose a different period or goal type.")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if hasConflict {
                            showingConflictAlert = true
                        } else {
                            saveGoal()
                        }
                    }
                    .disabled(effectiveSelectedMetric == nil || hasConflict)
                }
            }
        }
    }
    
    private var metricsWithoutGoals: [Metric] {
        if let selectedMetric = effectiveSelectedMetric {
            return [selectedMetric]
        } else {
            return metrics.filter { !$0.hasAnyGoals }
        }
    }
    
    private var hasConflict: Bool {
        guard let metric = effectiveSelectedMetric else { return false }
        return metric.goals?.contains { goal in
            if goal.goalType == .boolean && goalType == .boolean {
                // Boolean goals: same type + period = conflict
                return goal.period == selectedPeriod
            } else if goal.goalType == .quantity && goalType == .quantity {
                // Quantity goals: same type + period + quantityGoalType = conflict
                return goal.period == selectedPeriod && goal.quantityGoalType == quantityGoalType
            } else {
                // Different goal types = no conflict
                return false
            }
        } ?? false
    }
    
    private var availablePeriods: [GoalPeriod] {
        guard let metric = effectiveSelectedMetric else { return GoalPeriod.allCases }
        return GoalPeriod.allCases.filter { period in
            !(metric.goals?.contains { goal in
                if goal.goalType == .boolean && goalType == .boolean {
                    // Boolean goals: same type + period = conflict
                    return goal.period == period
                } else if goal.goalType == .quantity && goalType == .quantity {
                    // Quantity goals: same type + period + quantityGoalType = conflict
                    return goal.period == period && goal.quantityGoalType == quantityGoalType
                } else {
                    // Different goal types = no conflict
                    return false
                }
            } ?? false)
        }
    }
    
    private var goalExplanationText: String {
        guard let metric = effectiveSelectedMetric else { return "" }
        
        if metric.safeHabitType == .positive {
            return "Track how many days you successfully do this habit"
        } else {
            return "Track how many days you successfully avoid this vice"
        }
    }
    
    private var goalTypeExplanation: String {
        switch goalType {
        case .boolean:
            return "Track whether you did or avoided the habit each day"
        case .quantity:
            return "Track the quantity/amount of the habit each day"
        }
    }
    
    private var booleanGoalConfiguration: some View {
        VStack(spacing: 16) {
            // Period Selection
            Section {
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(availablePeriods, id: \.self) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Goal Period")
            } footer: {
                if hasConflict {
                    Text("⚠️ You already have a \(goalType.displayName.lowercased()) goal for \(selectedPeriod.displayName.lowercased())")
                        .foregroundColor(.red)
                } else if availablePeriods.isEmpty {
                    Text("All periods are taken for \(goalType.displayName.lowercased()) goals")
                        .foregroundColor(.orange)
                }
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
    
    private var quantityGoalConfiguration: some View {
        VStack(spacing: 16) {
            // Quantity Goal Type
            Section {
                Picker("Goal Type", selection: $quantityGoalType) {
                    ForEach(QuantityGoalType.allCases, id: \.self) { type in
                        VStack(alignment: .leading) {
                            Text(type.displayName)
                            Text(type.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(type)
                    }
                }
                .pickerStyle(.wheel)
            } header: {
                Text("Quantity Goal Type")
            } footer: {
                Text(quantityGoalTypeExplanation)
            }
            
            // Quantity Preset Options
            Section {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(availableQuantityPresets, id: \.title) { preset in
                        QuantityPresetButton(
                            preset: preset,
                            isSelected: selectedQuantityPreset?.title == preset.title,
                            action: { selectQuantityPreset(preset) }
                        )
                    }
                }
            } header: {
                Text("Quick Options")
            } footer: {
                Text("Choose a preset or set a custom target below")
            }
            
            // Period Selection
            Section {
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(availablePeriods, id: \.self) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Goal Period")
            } footer: {
                if hasConflict {
                    Text("⚠️ You already have a \(goalType.displayName.lowercased()) goal for \(selectedPeriod.displayName.lowercased())")
                        .foregroundColor(.red)
                } else if availablePeriods.isEmpty {
                    Text("All periods are taken for \(goalType.displayName.lowercased()) goals")
                        .foregroundColor(.orange)
                }
            }
            
            // Unit Selection
            Section {
                TextField("Unit (e.g., times, minutes, pages)", text: $quantityUnit)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } header: {
                Text("Unit")
            } footer: {
                Text("What unit do you want to track? (e.g., times, minutes, pages, cups)")
            }
            
            // Target Selection
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Target")
                            .font(.headline)
                        Spacer()
                        Text("\(quantityTarget) \(quantityUnit)")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(quantityTarget) },
                        set: { quantityTarget = Int($0) }
                    ), in: 1.0...Double(quantityMaxTarget), step: 1.0)
                    .accentColor(.blue)
                    
                    HStack {
                        Text("1")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(quantityMaxTarget)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Target")
            }
        }
    }
    
    private var maxTarget: Int {
        selectedPeriod.maxDays
    }
    
    private var quantityMaxTarget: Int {
        switch quantityGoalType {
        case .maxDaily:
            return 100 // Max 100 per day
        case .avgDaily:
            return 50  // Max 50 average per day
        case .totalPeriod:
            return selectedPeriod.maxDays * 10 // Max 10 per day over the period
        }
    }
    
    private var quantityGoalTypeExplanation: String {
        switch quantityGoalType {
        case .maxDaily:
            return "Keep your daily quantity under the target limit"
        case .avgDaily:
            return "Maintain an average daily quantity equal to the target"
        case .totalPeriod:
            return "Reach the total quantity over the entire period"
        }
    }
    
    private var availablePresets: [GoalPreset] {
        guard let metric = effectiveSelectedMetric else { return [] }
        
        let isVice = metric.safeHabitType == .vice
        
        return getBooleanPresets(for: selectedPeriod, isVice: isVice)
    }
    
    private func selectPreset(_ preset: GoalPreset) {
        selectedPreset = preset
        customTarget = preset.target
    }
    
    private var availableQuantityPresets: [QuantityPreset] {
        guard let metric = effectiveSelectedMetric else { return [] }
        
        let isVice = metric.safeHabitType == .vice
        
        return getQuantityPresets(for: quantityGoalType, isVice: isVice)
    }
    
    private func selectQuantityPreset(_ preset: QuantityPreset) {
        selectedQuantityPreset = preset
        quantityTarget = preset.target
        quantityUnit = preset.unit
    }
    
    private func saveGoal() {
        guard let metric = effectiveSelectedMetric else { return }
        
        // Create new goal
        let newGoal = Goal(
            goalType: goalType,
            period: selectedPeriod,
            target: goalType == .boolean ? customTarget : quantityTarget,
            quantityGoalType: goalType == .quantity ? quantityGoalType : nil,
            defaultUnit: goalType == .quantity ? (quantityUnit.isEmpty ? "times" : quantityUnit) : nil,
            maxDailyQuantity: goalType == .quantity ? quantityTarget * 2 : nil
        )
        
        // Set the relationship
        newGoal.metric = metric
        metric.goals?.append(newGoal)
        
        modelContext.insert(newGoal)
        try? modelContext.save()
        dismiss()
    }
}
