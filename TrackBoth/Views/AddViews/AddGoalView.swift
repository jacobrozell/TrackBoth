import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
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
    @State private var showingUnitPicker = false
    
    private var effectiveSelectedMetric: Metric? {
        return selectedMetric ?? pickerSelectedMetric
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Metric Selection (only show if no metric pre-selected)
                if selectedMetric == nil {
                    Section {
                        Picker("Select Habit", selection: $pickerSelectedMetric) {
                            Text("Choose a habit...").tag(nil as Metric?)
                            ForEach(metricsWithoutGoals, id: \.id) { metric in
                                HStack {
                                    Image(systemName: metric.habitType.icon)
                                        .foregroundColor(metric.habitType == .positive ? Color.currentSuccess : Color.currentError)
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
                            Image(systemName: effectiveSelectedMetric!.habitType.icon)
                                .foregroundColor(effectiveSelectedMetric!.habitType == .positive ? Color.currentSuccess : Color.currentError)
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
                            ForEach(availableGoalTypes, id: \.self) { type in
                                Text("\(type.displayName) Goal").tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onAppear {
                            // If current goal type is not available, switch to first available
                            if !availableGoalTypes.contains(goalType) {
                                goalType = availableGoalTypes.first ?? .boolean
                            }
                        }
                        .onChange(of: effectiveSelectedMetric) { _, _ in
                            // If current goal type is not available, switch to first available
                            if !availableGoalTypes.contains(goalType) {
                                goalType = availableGoalTypes.first ?? .boolean
                            }
                        }
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
            .scrollContentBackground(.hidden)
            .background(Color.currentBackground)
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingUnitPicker) {
                UnitPickerSheet(selectedUnit: $quantityUnit, units: commonUnits)
            }
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
                    .disabled(effectiveSelectedMetric == nil)
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
        
        // Check if metric already has a goal of the same type (regardless of period)
        if goalType == .boolean {
            return metric.booleanGoals.count > 0
        } else if goalType == .quantity {
            return metric.quantityGoals.count > 0
        }
        
        return false
    }
    
    private var availableGoalTypes: [GoalType] {
        guard let metric = effectiveSelectedMetric else { return GoalType.allCases }
        
        return GoalType.allCases.filter { goalType in
            switch goalType {
            case .boolean:
                return metric.booleanGoals.count == 0
            case .quantity:
                return metric.quantityGoals.count == 0
            }
        }
    }
    
    private var availablePeriods: [GoalPeriod] {
        // Since we only allow 1 goal per type, all periods are available
        return GoalPeriod.allCases
    }
    
    private var commonUnits: [String] {
        guard let metric = effectiveSelectedMetric else { return ["times", "minutes", "hours", "pages", "glasses", "servings", "sets", "reps"] }
        
        switch metric.habitType {
        case .positive:
            return ["times", "minutes", "hours", "pages", "glasses", "servings", "sets", "reps"]
        case .vice:
            return ["times", "minutes", "hours", "servings"]
        }
    }
    
    private var goalExplanationText: String {
        guard let metric = effectiveSelectedMetric else { return "" }
        
        if metric.habitType == .positive {
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
                .onChange(of: selectedPeriod) { _, newPeriod in
                    // Clamp customTarget to new period's bounds when period changes
                    if customTarget > newPeriod.maxDays {
                        customTarget = newPeriod.maxDays
                        selectedPreset = nil // Clear selected preset since target changed
                    }
                }
            } header: {
                Text("Goal Period")
            } footer: {
                Text("Choose the period for your goal")
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
                            .foregroundColor(Color.currentPrimary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(customTarget) },
                        set: { customTarget = Int($0) }
                    ), in: 1.0...Double(maxTarget), step: 1.0)
                    .accentColor(Color.currentPrimary)
                    
                    HStack {
                        Text("1")
                            .font(.caption)
                            .foregroundColor(Color.currentSecondaryText)
                        Spacer()
                        Text("\(maxTarget)")
                            .font(.caption)
                            .foregroundColor(Color.currentSecondaryText)
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
                VStack(spacing: 12) {
                    ForEach(QuantityGoalType.allCases, id: \.self) { type in
                        quantityGoalTypeButton(for: type)
                    }
                }
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
                .onChange(of: selectedPeriod) { _, newPeriod in
                    // Clamp quantityTarget to new period's bounds when period changes
                    if quantityTarget > quantityMaxTarget {
                        quantityTarget = quantityMaxTarget
                        selectedQuantityPreset = nil // Clear selected preset since target changed
                    }
                }
            } header: {
                Text("Goal Period")
            }
            
            // Unit Selection
            Section {
                Button(action: {
                    showingUnitPicker = true
                }) {
                    HStack {
                        Text(quantityUnit.isEmpty ? "Select Unit" : quantityUnit)
                            .foregroundColor(quantityUnit.isEmpty ? Color.currentSecondaryText : Color.currentText)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.currentSecondaryText)
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            } header: {
                Text("Unit")
            } footer: {
                Text("Choose a unit to track your progress")
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
                            .foregroundColor(Color.currentPrimary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(quantityTarget) },
                        set: { quantityTarget = Int($0) }
                    ), in: 1.0...Double(quantityMaxTarget), step: 1.0)
                    .accentColor(Color.currentPrimary)
                    
                    HStack {
                        Text("1")
                            .font(.caption)
                            .foregroundColor(Color.currentSecondaryText)
                        Spacer()
                        Text("\(quantityMaxTarget)")
                            .font(.caption)
                            .foregroundColor(Color.currentSecondaryText)
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
        
        let isVice = metric.habitType == .vice
        
        return getBooleanPresets(for: selectedPeriod, isVice: isVice)
    }
    
    private func selectPreset(_ preset: GoalPreset) {
        selectedPreset = preset
        customTarget = preset.target
    }
    
    private var availableQuantityPresets: [QuantityPreset] {
        guard let metric = effectiveSelectedMetric else { return [] }
        
        let isVice = metric.habitType == .vice
        
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
        modelContext.saveChanges(operation: "create goal", entity: "Goal")
        dismiss()
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func quantityGoalTypeButton(for type: QuantityGoalType) -> some View {
        let isSelected = quantityGoalType == type
        
        Button(action: {
            quantityGoalType = type
        }) {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .foregroundColor(isSelected ? .white : Color.currentPrimary)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : Color.currentText)
                    
                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Color.currentSecondaryText)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(buttonBackground(isSelected: isSelected))
            .overlay(buttonOverlay(isSelected: isSelected))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func buttonBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.currentPrimary : Color.currentSecondaryBackground)
    }
    
    private func buttonOverlay(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(isSelected ? Color.currentPrimary : Color.currentSecondaryBackground, lineWidth: 1)
    }
}
