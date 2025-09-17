import SwiftUI
import SwiftData

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
        _habitType = State(initialValue: metric.habitType)
        _goalPeriod = State(initialValue: metric.booleanGoals.first?.period ?? .monthly)
        _goalTarget = State(initialValue: metric.booleanGoals.first?.target ?? 20)
        _primaryMotivation = State(initialValue: metric.primaryMotivation ?? "")
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

        try? modelContext.save()
        dismiss()
    }
}
