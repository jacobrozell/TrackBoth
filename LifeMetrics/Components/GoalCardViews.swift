import SwiftUI
import SwiftData

// MARK: - Enhanced Goal Card Component
struct EnhancedGoalCardView: View {
    let metric: Metric
    let selectedDate: Date
    let entries: [MetricEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditGoal = false
    @State private var showingHistory = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with habit name and status
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
                    
                    Text(goalDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                statusIndicator
            }
            
            // Progress visualization
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(progressText)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }
                
                // Enhanced progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: max(8, CGFloat(progressValue) * 200), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progressValue)
                }
                
                // Time remaining
                if let timeRemaining = timeRemainingText {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(timeRemaining)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Success indicator for historical periods
            if !CalendarHelper.isSameDay(selectedDate, Date()) {
                historicalSuccessIndicator
            }
            
            // Action buttons
            HStack {
                Button("History") {
                    showingHistory = true
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(6)
                
                Spacer()
                
                Button("Edit Goal") {
                    showingEditGoal = true
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
        .sheet(isPresented: $showingEditGoal) {
            EditGoalView(metric: metric)
                .onAppear {
                    logger.info("EditGoalView sheet presented - Metric: \(metric.name)")
                }
        }
        .sheet(isPresented: $showingHistory) {
            GoalHistoryView(metric: metric, entries: entries)
                .onAppear {
                    logger.info("GoalHistoryView sheet presented - Metric: \(metric.name)")
                }
        }
    }
    
    private var statusIndicator: some View {
        VStack(spacing: 4) {
            if progressValue >= 1.0 {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Complete")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            } else if progressValue >= 0.7 {
                Image(systemName: "clock.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("On Track")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("Behind")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var borderColor: Color {
        if progressValue >= 1.0 {
            return .green.opacity(0.3)
        } else if progressValue >= 0.7 {
            return .orange.opacity(0.3)
        } else {
            return .red.opacity(0.3)
        }
    }
    
    private var historicalSuccessIndicator: some View {
        HStack {
            Image(systemName: wasGoalAchieved ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(wasGoalAchieved ? .green : .red)
                .font(.title3)
            
            Text(wasGoalAchieved ? "Goal achieved this week!" : "Goal not achieved this week")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(wasGoalAchieved ? .green : .red)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background((wasGoalAchieved ? Color.green : Color.red).opacity(0.1))
        .cornerRadius(8)
    }
    
    private var wasGoalAchieved: Bool {
        return progressValue >= 1.0
    }
    
    private var goalDescription: String {
        guard let goal = metric.booleanGoals.first else {
            return "No goal set"
        }
        
        if metric.safeHabitType == .vice {
            return "Max \(goal.target) days per \(goal.period.displayName.lowercased())"
        } else {
            return "\(goal.target) days per \(goal.period.displayName.lowercased())"
        }
    }
    
    private var progressValue: Double {
        guard let goal = metric.booleanGoals.first else { return 0 }
        
        let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
        return progress.percentage / 100.0
    }
    
    private var progressText: String {
        guard let goal = metric.booleanGoals.first else { return "No target" }
        
        let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
        return "\(Int(progress.current))/\(Int(progress.target))"
    }
    
    private var progressColor: Color {
        let progress = progressValue
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var timeRemainingText: String? {
        guard let period = metric.booleanGoals.first?.period else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .weekly:
            let daysRemaining = CalendarHelper.daysRemainingInPeriod(.weekly, from: now)
            return "\(daysRemaining) days left this week"
        case .biWeekly:
            let daysRemaining = CalendarHelper.daysRemainingInPeriod(.biWeekly, from: now)
            return "\(daysRemaining) days left this period"
        case .monthly:
            if let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end {
                let daysRemaining = calendar.dateComponents([.day], from: now, to: endOfMonth).day ?? 0
                return "\(daysRemaining) days left this month"
            }
        case .yearly:
            if let endOfYear = calendar.dateInterval(of: .year, for: now)?.end {
                let daysRemaining = calendar.dateComponents([.day], from: now, to: endOfYear).day ?? 0
                return "\(daysRemaining) days left this year"
            }
        }
        
        return nil
    }
    
    private func calculateCurrentProgress() -> Int {
        guard let goal = metric.booleanGoals.first else { return 0 }
        let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
        return Int(progress.current)
    }
}

// MARK: - Quantity Goal Card Component
struct QuantityGoalCardView: View {
    let metric: Metric
    let selectedDate: Date
    let entries: [MetricEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditGoal = false
    @State private var showingHistory = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with habit name and status
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
                    
                    Text(quantityGoalDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                statusIndicator
            }
            
            // Progress visualization
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(progressText)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }
                
                // Enhanced progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: max(8, CGFloat(progressValue) * 200), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progressValue)
                }
            }
            
            // Time remaining
            if let timeRemaining = timeRemainingText {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(timeRemaining)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Success indicator for historical periods
            if !CalendarHelper.isSameDay(selectedDate, Date()) {
                historicalSuccessIndicator
            }
            
            // Action buttons
            HStack {
                Button("History") {
                    showingHistory = true
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(6)
                
                Spacer()
                
                Button("Edit Goal") {
                    showingEditGoal = true
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 1)
        )
        .sheet(isPresented: $showingEditGoal) {
            EditQuantityGoalView(metric: metric)
                .onAppear {
                    logger.info("EditQuantityGoalView sheet presented - Metric: \(metric.name)")
                }
        }
        .sheet(isPresented: $showingHistory) {
            QuantityGoalHistoryView(metric: metric, entries: entries)
                .onAppear {
                    logger.info("QuantityGoalHistoryView sheet presented - Metric: \(metric.name)")
                }
        }
    }
    
    private var statusIndicator: some View {
        VStack(spacing: 4) {
            if progressValue >= 1.0 {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Complete")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            } else if progressValue >= 0.7 {
                Image(systemName: "clock.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("On Track")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("Behind")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var borderColor: Color {
        if progressValue >= 1.0 {
            return .green.opacity(0.3)
        } else if progressValue >= 0.7 {
            return .orange.opacity(0.3)
        } else {
            return .red.opacity(0.3)
        }
    }
    
    private var historicalSuccessIndicator: some View {
        HStack {
            Image(systemName: wasGoalAchieved ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(wasGoalAchieved ? .green : .red)
                .font(.title3)
            
            Text(wasGoalAchieved ? "Goal achieved this week!" : "Goal not achieved this week")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(wasGoalAchieved ? .green : .red)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background((wasGoalAchieved ? Color.green : Color.red).opacity(0.1))
        .cornerRadius(8)
    }
    
    private var wasGoalAchieved: Bool {
        return progressValue >= 1.0
    }
    
    private var quantityGoalDescription: String {
        guard let goal = metric.quantityGoals.first else {
            return "No quantity goal set"
        }
        
        let unit = goal.safeDefaultUnit
        
        switch goal.quantityGoalType {
        case .maxDaily:
            return "Max \(goal.target) \(unit) per day"
        case .avgDaily:
            return "Average \(goal.target) \(unit) per day"
        case .totalPeriod:
            return "Total \(goal.target) \(unit) per \(goal.period.displayName.lowercased())"
        case .none:
            return "No quantity goal type set"
        }
    }
    
    private var progressValue: Double {
        guard let goal = metric.quantityGoals.first else { return 0.0 }
        let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
        return progress.percentage
    }
    
    private var progressText: String {
        guard let goal = metric.quantityGoals.first else { return "No goal" }
        let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
        let currentText = String(format: "%.1f", progress.current)
        let targetText = String(format: "%.0f", progress.target)
        return "\(currentText)/\(targetText) \(progress.unit)"
    }
    
    private var progressColor: Color {
        let progress = progressValue
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var timeRemainingText: String? {
        guard let period = metric.quantityGoals.first?.period else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .weekly:
            let daysRemaining = CalendarHelper.daysRemainingInPeriod(.weekly, from: now)
            return "\(daysRemaining) days left this week"
        case .biWeekly:
            let daysRemaining = CalendarHelper.daysRemainingInPeriod(.biWeekly, from: now)
            return "\(daysRemaining) days left this period"
        case .monthly:
            if let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end {
                let daysRemaining = calendar.dateComponents([.day], from: now, to: endOfMonth).day ?? 0
                return "\(daysRemaining) days left this month"
            }
        case .yearly:
            if let endOfYear = calendar.dateInterval(of: .year, for: now)?.end {
                let daysRemaining = calendar.dateComponents([.day], from: now, to: endOfYear).day ?? 0
                return "\(daysRemaining) days left this year"
            }
        }
        
        return nil
    }
}

// MARK: - Placeholder Views for Quantity Goals
struct EditQuantityGoalView: View {
    let metric: Metric
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Quantity Goal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Coming Soon")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Edit Quantity Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
