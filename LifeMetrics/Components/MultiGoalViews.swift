import SwiftUI
import SwiftData

// MARK: - Multi Goal Card Component
struct MultiGoalCardView: View {
    let metric: Metric
    let selectedDate: Date
    let entries: [MetricEntry]
    let goals: [Goal]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddGoal = false
    
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
                            .foregroundColor(metric.safeHabitType == .positive ? .green : .red)
                            .font(.title3)
                        
                        Text(metric.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Text("\(metricGoals.count) goal\(metricGoals.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    showingAddGoal = true
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            
            // Goals list
            VStack(spacing: 12) {
                ForEach(metricGoals, id: \.id) { goal in
                    GoalProgressRow(goal: goal, metric: metric, selectedDate: selectedDate, entries: entries)
                }
                
                // Show available periods for adding new goals
                if metricGoals.count < 8 { // Max 8 goals (2 types × 4 periods)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available periods:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 4) {
                            ForEach(GoalPeriod.allCases, id: \.self) { period in
                                let hasBoolean = metricGoals.contains { $0.goalType == .boolean && $0.period == period }
                                let hasMaxDaily = metricGoals.contains { $0.goalType == .quantity && $0.period == period && $0.quantityGoalType == .maxDaily }
                                let hasAvgDaily = metricGoals.contains { $0.goalType == .quantity && $0.period == period && $0.quantityGoalType == .avgDaily }
                                let hasTotalPeriod = metricGoals.contains { $0.goalType == .quantity && $0.period == period && $0.quantityGoalType == .totalPeriod }
                                
                                VStack(spacing: 2) {
                                    Text(period.displayName)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                    
                                    HStack(spacing: 1) {
                                        // Boolean goal
                                        Circle()
                                            .fill(hasBoolean ? Color.blue : Color.gray.opacity(0.3))
                                            .frame(width: 4, height: 4)
                                        
                                        // Quantity goals
                                        Circle()
                                            .fill(hasMaxDaily ? Color.purple : Color.gray.opacity(0.3))
                                            .frame(width: 4, height: 4)
                                        Circle()
                                            .fill(hasAvgDaily ? Color.orange : Color.gray.opacity(0.3))
                                            .frame(width: 4, height: 4)
                                        Circle()
                                            .fill(hasTotalPeriod ? Color.green : Color.gray.opacity(0.3))
                                            .frame(width: 4, height: 4)
                                    }
                                }
                                .padding(4)
                                .background(Color(.systemGray6))
                                .cornerRadius(4)
                            }
                        }
                        
                        Text("Blue = Boolean, Purple = Max Daily, Orange = Avg Daily, Green = Total Period")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView(selectedMetric: metric)
        }
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
                    
                    Text(goal.period.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                Image(systemName: progress.percentage >= 1.0 ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(progress.percentage >= 1.0 ? .green : .gray)
                    .font(.title3)
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(progressText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
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
            return .green
        } else if progress.percentage >= 0.7 {
            return .orange
        } else {
            return .red
        }
    }
}
