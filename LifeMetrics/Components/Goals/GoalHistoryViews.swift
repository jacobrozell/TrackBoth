import SwiftUI
import SwiftData

// MARK: - Goal History Models
struct HistoricalPeriod {
    let startDate: Date
    let endDate: Date
    let progress: Int
    let target: Int
    
    var wasAchieved: Bool {
        return progress >= target
    }
    
    var periodDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            return formatter.string(from: startDate)
        } else {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
}

// MARK: - Goal History View
struct GoalHistoryView: View {
    let metric: Metric
    let entries: [MetricEntry]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: GoalPeriod = .monthly
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: metric.habitType.icon)
                            .foregroundColor(metric.habitType == .positive ? .currentSuccess : .currentError)
                            .font(.title2)
                        
                        Text(metric.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.currentText)
                        
                        Spacer()
                    }
                    
                    Text("Goal History")
                        .font(.subheadline)
                        .foregroundColor(.currentSecondaryText)
                }
                .padding(.horizontal, 16)
                
                // Period selector
                VStack(spacing: 16) {
                    HStack {
                        Text("View Periods")
                            .font(.headline)
                            .foregroundColor(.currentText)
                        Spacer()
                    }
                    
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(GoalPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 16)
                
                // History list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(historicalPeriods, id: \.startDate) { period in
                            HistoricalPeriodCard(
                                metric: metric,
                                period: period,
                                entries: entries
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Goal History")
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
    
    private var historicalPeriods: [HistoricalPeriod] {
        guard let goal = metric.booleanGoals.first else { return [] }
        
        var periods: [HistoricalPeriod] = []
        let calendar = Calendar.current
        let now = Date()
        
        // Generate periods going back in time
        var currentDate = now
        for _ in 0..<12 { // Show last 12 periods
            let startDate = CalendarHelper.startOfPeriod(goal.period, for: currentDate)
            let endDate = CalendarHelper.endOfPeriod(goal.period, for: currentDate)
            
            let periodEntries = entries.filter { entry in
                entry.metricID == metric.id &&
                entry.date >= startDate &&
                entry.date <= endDate
            }
            
            let progress = calculateProgress(for: periodEntries, target: goal.target, isVice: metric.habitType == .vice)
            
            periods.append(HistoricalPeriod(
                startDate: startDate,
                endDate: endDate,
                progress: progress,
                target: goal.target
            ))
            
            // Move to previous period
            currentDate = calendar.date(byAdding: .day, value: -1, to: startDate) ?? currentDate
        }
        
        return periods
    }
    
    private func calculateProgress(for entries: [MetricEntry], target: Int, isVice: Bool) -> Int {
        if isVice {
            return entries.filter { !$0.value }.count
        } else {
            return entries.filter { $0.value }.count
        }
    }
}

// MARK: - Historical Period Card
struct HistoricalPeriodCard: View {
    let metric: Metric
    let period: HistoricalPeriod
    let entries: [MetricEntry]
    
    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            VStack(spacing: 4) {
                Image(systemName: period.wasAchieved ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(period.wasAchieved ? .currentSuccess : .currentError)
                    .font(.title2)
                
                Text(period.wasAchieved ? "✓" : "✗")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(period.wasAchieved ? .currentSuccess : .currentError)
            }
            
            // Period info
            VStack(alignment: .leading, spacing: 4) {
                Text(period.periodDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.currentText)
                
                Text("\(period.progress)/\(period.target) days")
                    .font(.caption)
                    .foregroundColor(.currentSecondaryText)
            }
            
            Spacer()
            
            // Progress bar
            VStack(alignment: .trailing, spacing: 4) {
                let percentage = Double(period.progress) / Double(period.target)
                ProgressView(value: percentage, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: period.wasAchieved ? .currentSuccess : .currentError))
                    .frame(width: 80)
                
                Text("\(Int(percentage * 100))%")
                    .font(.caption2)
                    .foregroundColor(.currentSecondaryText)
            }
        }
        .padding(16)
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(period.wasAchieved ? Color.currentSuccess.opacity(0.3) : Color.currentError.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Quantity Goal History Placeholder
struct QuantityGoalHistoryView: View {
    let metric: Metric
    let entries: [MetricEntry]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Quantity Goal History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.currentText)
                    .padding()
                
                Text("Coming Soon")
                    .font(.body)
                    .foregroundColor(.currentSecondaryText)
                
                Spacer()
            }
            .navigationTitle("Quantity Goal History")
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
