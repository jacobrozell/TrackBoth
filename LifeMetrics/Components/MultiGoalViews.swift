import SwiftUI
import SwiftData

// MARK: - Multi Goal Card Component
struct MultiGoalCardView: View {
    let metric: Metric
    let selectedDate: Date
    let entries: [MetricEntry]
    let goals: [Goal]
    @Environment(\.modelContext) private var modelContext
    
    private var metricGoals: [Goal] {
        goals.filter { $0.metric?.id == metric.id }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with habit name
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: metric.safeHabitType.icon)
                            .foregroundColor(metric.safeHabitType == .positive ? .currentSuccess : .currentError)
                            .font(.title3)
                        
                        Text(metric.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.currentText)
                    }
                    
                    Text("\(metricGoals.count) goal\(metricGoals.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                }
                
                Spacer()
            }
            
            // Goals list
            VStack(spacing: 12) {
                ForEach(metricGoals, id: \.id) { goal in
                    GoalProgressRow(goal: goal, metric: metric, selectedDate: selectedDate, entries: entries)
                }
            }
        }
        .padding(16)
        .background(Color.currentSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Goal Progress Row Component
struct GoalProgressRow: View {
    let goal: Goal
    let metric: Metric
    let selectedDate: Date
    let entries: [MetricEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditGoal = false
    
    private var progress: (current: Double, target: Double, percentage: Double, unit: String) {
        GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Goal header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(goalDescription)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.currentText)
                    
                    Text(goal.period.displayName)
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                }
                
                Spacer()
                
                // Status indicator
                Image(systemName: progress.percentage >= 1.0 ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(progress.percentage >= 1.0 ? .currentSuccess : .currentSecondaryText)
                    .font(.title3)
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(progressText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.currentText)
                    
                    Spacer()
                    
                    Text("\(Int(progress.percentage * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(progressColor)
                }
                
                ProgressView(value: progress.percentage, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .scaleEffect(x: 1, y: 0.8)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .onTapGesture {
            showingEditGoal = true
        }
        .sheet(isPresented: $showingEditGoal) {
            EditGoalView(metric: metric)
        }
    }
    
    private var goalDescription: String {
        if goal.goalType == .boolean {
            return "\(goal.target) days per \(goal.period.displayName.lowercased())"
        } else {
            let unit = goal.safeDefaultUnit
            switch goal.quantityGoalType ?? .totalPeriod {
            case .maxDaily:
                return "Max \(goal.target) \(unit) per day"
            case .avgDaily:
                return "Average \(goal.target) \(unit) per day"
            case .totalPeriod:
                return "Total \(goal.target) \(unit) per \(goal.period.displayName.lowercased())"
            }
        }
    }
    
    private var progressText: String {
        if goal.goalType == .boolean {
            return "\(Int(progress.current))/\(Int(progress.target)) days"
        } else {
            let currentText = String(format: "%.1f", progress.current)
            let targetText = String(format: "%.0f", progress.target)
            return "\(currentText)/\(targetText) \(progress.unit)"
        }
    }
    
    private var progressColor: Color {
        if progress.percentage >= 1.0 {
            return .currentSuccess
        } else if progress.percentage >= 0.7 {
            return .currentWarning
        } else {
            return .currentError
        }
    }
}
