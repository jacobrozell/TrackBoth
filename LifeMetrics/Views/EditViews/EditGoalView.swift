import SwiftUI
import SwiftData

struct EditGoalView: View {
    let metric: Metric
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPeriod: GoalPeriod
    @State private var customTarget: Int
    
    init(metric: Metric) {
        self.metric = metric
        self._selectedPeriod = State(initialValue: metric.booleanGoals.first?.period ?? .monthly)
        self._customTarget = State(initialValue: metric.booleanGoals.first?.target ?? 20)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: metric.safeHabitType.icon)
                            .foregroundColor(metric.safeHabitType == .positive ? Color.currentSuccess : Color.currentError)
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
                    .onChange(of: selectedPeriod) { _, newPeriod in
                        // Clamp customTarget to new period's bounds when period changes
                        if customTarget > newPeriod.maxDays {
                            customTarget = newPeriod.maxDays
                        }
                    }
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
        // Update the existing boolean goal
        if let existingGoal = metric.booleanGoals.first {
            existingGoal.period = selectedPeriod
            existingGoal.target = customTarget
        } else {
            // Create a new boolean goal if none exists
            let newGoal = Goal(
                goalType: .boolean,
                period: selectedPeriod,
                target: customTarget
            )
            newGoal.metric = metric
            metric.goals?.append(newGoal)
            modelContext.insert(newGoal)
        }
        
        try? modelContext.save()
        dismiss()
    }
}
