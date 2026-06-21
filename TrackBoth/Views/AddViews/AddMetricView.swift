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
    @State private var viceNeedingMotivation: Metric?
    @State private var showingViceMotivationPrompt = false

    private var maxTargetForPeriod: Int {
        selectedGoalPeriod.maxDays
    }

    private var quickPresets: [GoalPreset] {
        getBooleanPresets(for: selectedGoalPeriod, isVice: selectedHabitType == .vice)
    }

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                quickAddSection
                typeSection
                motivationSection

                if ProductSurface.showsAdvancedMetricSetup {
                    targetSection
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.currentBackground)
            .navigationTitle("Add Habit or Vice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveMetric() }
                        .disabled(metricName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showingViceMotivationPrompt) {
                if let vice = viceNeedingMotivation {
                    ViceMotivationPromptSheet(metric: vice) {
                        showingViceMotivationPrompt = false
                        viceNeedingMotivation = nil
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    private var nameSection: some View {
        Section {
            TextField(selectedHabitType == .positive ? "Habit name" : "Vice name", text: $metricName)
        } header: {
            Text("Name")
        } footer: {
            Text(selectedHabitType == .positive
                 ? "Something you want to do more often, like Exercise or Read."
                 : "Something you want to avoid, like Social media or Smoking.")
        }
    }

    private var quickAddSection: some View {
        Section {
            let presets = MetricPreset.presets(for: selectedHabitType)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                ForEach(presets) { preset in
                    let isSelected = metricName == preset.name
                    Button {
                        metricName = preset.name
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: preset.icon)
                                .font(.subheadline)
                            Text(preset.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                            Spacer(minLength: 0)
                        }
                        .foregroundColor(isSelected ? Color.currentBackground : Color.currentText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.currentPrimary : Color.currentSecondaryBackground)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        } header: {
            Text("Suggestions")
        } footer: {
            Text("Tap a suggestion, then edit the name if you like.")
        }
    }

    private var typeSection: some View {
        Section {
            Picker("Type", selection: $selectedHabitType) {
                ForEach(HabitType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedHabitType) { _, _ in
                metricName = ""
            }
        } header: {
            Text("Type")
        } footer: {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: selectedHabitType.icon)
                    .foregroundColor(selectedHabitType == .positive ? Color.currentSuccess : Color.currentError)
                Text(selectedHabitType == .positive
                     ? "Habits track days you did it. Tap the row on Track to log."
                     : "Vices track days you avoided it. Tap the row on Track to log.")
            }
        }
    }

    private var motivationSection: some View {
        Section {
            TextField(
                selectedHabitType == .vice ? "Why do you want to avoid this?" : "What motivates you to do this?",
                text: $primaryMotivation,
                axis: .vertical
            )
            .lineLimit(3...6)
        } header: {
            Text("Primary Motivation")
        }
    }

    private var targetSection: some View {
        Section {
            Picker("Period", selection: $selectedGoalPeriod) {
                ForEach(GoalPeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedGoalPeriod) { _, newPeriod in
                let maxDays = newPeriod.maxDays
                if goalTarget > maxDays {
                    switch newPeriod {
                    case .weekly:
                        goalTarget = selectedHabitType == .vice ? 2 : 5
                    case .monthly:
                        goalTarget = selectedHabitType == .vice ? 8 : 20
                    case .yearly:
                        goalTarget = selectedHabitType == .vice ? 50 : 200
                    }
                }
            }

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

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(quickPresets, id: \.title) { preset in
                        Button {
                            goalTarget = preset.target
                        } label: {
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
                                    .fill(goalTarget == preset.target
                                          ? Color.currentPrimary.opacity(0.2)
                                          : Color.currentSecondaryBackground)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        } header: {
            Text(selectedHabitType == .vice ? "Target (Maximum Days)" : "Target (Days)")
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

        let goal = Goal(
            goalType: .boolean,
            period: ProductSurface.showsAdvancedMetricSetup ? selectedGoalPeriod : .monthly,
            target: ProductSurface.showsAdvancedMetricSetup
                ? goalTarget
                : MetricPresetFactory.defaultMonthlyTarget(for: selectedHabitType)
        )
        goal.metric = metric
        metric.goals?.append(goal)
        modelContext.insert(goal)

        modelContext.saveChanges(operation: "create metric", entity: "Metric")

        if selectedHabitType == .vice, trimmedMotivation.isEmpty {
            viceNeedingMotivation = metric
            showingViceMotivationPrompt = true
        } else {
            dismiss()
        }
    }
}
