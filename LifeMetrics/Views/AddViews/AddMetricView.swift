import SwiftUI
import SwiftData

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
        NavigationStack {
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
                            .foregroundColor(selectedHabitType == .positive ? Color.currentSuccess : Color.currentError)
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
                    .onChange(of: selectedGoalPeriod) { _, newPeriod in
                        // Reset goal target to a reasonable default when period changes
                        let maxDays = newPeriod.maxDays
                        if goalTarget > maxDays {
                            // Set to a reasonable default based on period
                            switch newPeriod {
                            case .weekly:
                                goalTarget = selectedHabitType == .vice ? 2 : 5
                            case .biWeekly:
                                goalTarget = selectedHabitType == .vice ? 4 : 10
                            case .monthly:
                                goalTarget = selectedHabitType == .vice ? 8 : 20
                            case .yearly:
                                goalTarget = selectedHabitType == .vice ? 50 : 200
                            }
                        }
                    }

                    // Improved goal target selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(selectedHabitType == .vice ? "Max Days" : "Target Days")
                                .font(.headline)
                            Spacer()
                            Text("\(goalTarget)")
                                .font(.headline)
                                .foregroundColor(Color.currentPrimary)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(goalTarget) },
                            set: { goalTarget = Int($0) }
                        ), in: 1.0...Double(maxTargetForPeriod), step: 1.0)
                        .accentColor(Color.currentPrimary)
                        
                        HStack {
                            Text("1")
                                .font(.caption)
                                .foregroundColor(Color.currentSecondaryText)
                            Spacer()
                            Text("\(maxTargetForPeriod)")
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
                                ForEach(quickPresets, id: \.title) { preset in
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
            primaryMotivation: trimmedMotivation.isEmpty ? nil : trimmedMotivation
        )
        modelContext.insert(metric)
        
        // Create a boolean goal for the metric
        let goal = Goal(
            goalType: .boolean,
            period: selectedGoalPeriod,
            target: goalTarget
        )
        goal.metric = metric
        metric.goals?.append(goal)
        modelContext.insert(goal)
        
        try? modelContext.save()
        dismiss()
    }
}
