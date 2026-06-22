import SwiftUI
import SwiftData

struct EditMetricView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Query private var entries: [MetricEntry]
    @State var metric: Metric
    @State private var name: String = ""
    @State private var habitType: HabitType = .positive
    @State private var goalPeriod: GoalPeriod = .monthly
    @State private var goalTarget: Int = 20
    @State private var primaryMotivation: String = ""
    @State private var costPerUnitText: String = ""
    @State private var showTimeSinceSlip: Bool = false
    
    private var maxTargetForEditPeriod: Int {
        goalPeriod.maxDays
    }
    
    private var quickPresetsForEdit: [GoalPreset] {
        getBooleanPresets(for: goalPeriod, isVice: habitType == .vice)
    }

    init(metric: Metric) {
        _metric = State(initialValue: metric)
        _name = State(initialValue: metric.name)
        _habitType = State(initialValue: metric.habitType)
        _goalPeriod = State(initialValue: metric.booleanGoals.first?.period ?? .monthly)
        _goalTarget = State(initialValue: metric.booleanGoals.first?.target ?? 20)
        _primaryMotivation = State(initialValue: metric.primaryMotivation ?? "")
        if let cost = metric.costPerUnitDecimal {
            _costPerUnitText = State(initialValue: NSDecimalNumber(decimal: cost).stringValue)
        }
        _showTimeSinceSlip = State(initialValue: MetricDisplayPreferences.showTimeSinceSlip(for: metric.id))
    }

    var body: some View {
        NavigationStack {
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
                    Text("Your why")
                } footer: {
                    Text(habitType == .vice ?
                         "Pinned to this vice — shown on Motivation and when you log a slip." :
                         "Optional — why you're building this habit.")
                }

                if habitType == .vice {
                    Section {
                        TextField("Amount", text: $costPerUnitText)
                            .keyboardType(.decimalPad)
                    } header: {
                        Text("Money Saved")
                    } footer: {
                        Text("Optional cost per day or unit avoided. Shows estimated savings on Home during clean streaks.")
                    }

                    Section {
                        Toggle("Show recovery timer", isOn: $showTimeSinceSlip)
                    } footer: {
                        Text("Shows how long you've been recovering since your last slip. Off by default.")
                    }
                }

                Section {
                    Picker("Period", selection: $goalPeriod) {
                        ForEach(GoalPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: goalPeriod) { _, newPeriod in
                        // Reset goal target to a reasonable default when period changes
                        let maxDays = newPeriod.maxDays
                        if goalTarget > maxDays {
                            // Set to a reasonable default based on period
                            switch newPeriod {
                            case .weekly:
                                goalTarget = habitType == .vice ? 2 : 5
                            case .monthly:
                                goalTarget = habitType == .vice ? 8 : 20
                            case .yearly:
                                goalTarget = habitType == .vice ? 50 : 200
                            }
                        }
                    }

                    // Improved goal target selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(habitType == .vice ? "Max Days" : "Target Days")
                                .font(.headline)
                            Spacer()
                            Text("\(goalTarget)")
                                .font(.headline)
                                .foregroundColor(Color.currentPrimary)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(goalTarget) },
                            set: { goalTarget = Int($0) }
                        ), in: 1.0...Double(maxTargetForEditPeriod), step: 1.0)
                        .accentColor(Color.currentPrimary)
                        
                        HStack {
                            Text("1")
                                .font(.caption)
                                .foregroundColor(Color.currentSecondaryText)
                            Spacer()
                            Text("\(maxTargetForEditPeriod)")
                                .font(.caption)
                                .foregroundColor(Color.currentSecondaryText)
                        }
                        
                        // Quick preset buttons with enhanced styling
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick Presets")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.currentSecondaryText)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(quickPresetsForEdit, id: \.title) { preset in
                                    Button(action: {
                                        goalTarget = preset.target
                                    }) {
                                        VStack(spacing: 4) {
                                            Text(preset.title)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Color.currentText)
                                            Text("\(preset.target) days")
                                                .font(.caption)
                                                .foregroundColor(Color.currentSecondaryText)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(goalTarget == preset.target ? 
                                                    Color.currentPrimary.opacity(0.2) : 
                                                    Color.currentSecondaryBackground)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(goalTarget == preset.target ? 
                                                    Color.currentPrimary : 
                                                    Color.currentSecondaryBackground, lineWidth: goalTarget == preset.target ? 2 : 1)
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
            .scrollContentBackground(.hidden)
            .background(Color.currentBackground)
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

        if habitType == .vice {
            let trimmedCost = costPerUnitText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedCost.isEmpty {
                metric.setCostPerUnitDecimal(nil)
            } else if let cost = Decimal(string: trimmedCost), cost > 0 {
                metric.setCostPerUnitDecimal(cost)
            }
        } else {
            metric.setCostPerUnitDecimal(nil)
        }

        if habitType == .vice {
            MetricDisplayPreferences.setShowTimeSinceSlip(showTimeSinceSlip, for: metric.id)
        } else {
            MetricDisplayPreferences.remove(for: metric.id)
        }
        
        // Update or create boolean goal
        if let existingGoal = metric.booleanGoals.first {
            existingGoal.period = goalPeriod
            existingGoal.target = goalTarget
        } else {
            let newGoal = Goal(
                goalType: .boolean,
                period: goalPeriod,
                target: goalTarget
            )
            newGoal.metric = metric
            metric.goals?.append(newGoal)
            modelContext.insert(newGoal)
        }

        modelContext.saveChanges(operation: "save metric edits", entity: "Metric")
        dismiss()
    }
}
