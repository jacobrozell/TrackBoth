import SwiftUI
import SwiftData

// MARK: - Watch Weekly Summary View
/// Weekly progress summary for Apple Watch
struct WatchWeeklySummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    
    private var weeklyData: WeeklySummaryData {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        var habitData: [String: Int] = [:]
        var viceData: [String: Int] = [:]
        
        // Calculate completion rates for each metric over the past 7 days
        // Only include metrics that have entries
        for metric in metrics where entries.contains(where: { $0.metricID == metric.id }) {
            let metricEntries = entries.filter { entry in
                entry.metricID == metric.id &&
                entry.date >= weekAgo &&
                entry.date <= today &&
                entry.value
            }
            
            let completionRate = metricEntries.count
            
            if metric.habitType == .positive {
                habitData[metric.name] = completionRate
            } else {
                viceData[metric.name] = completionRate
            }
        }
        
        let loggedHabits = metrics.filter { metric in metric.habitType == .positive && entries.contains(where: { $0.metricID == metric.id }) }.count
        let loggedVices = metrics.filter { metric in metric.habitType == .vice && entries.contains(where: { $0.metricID == metric.id }) }.count
        let totalCompletions = habitData.values.reduce(0, +) + viceData.values.reduce(0, +)
        let totalPossible = (loggedHabits + loggedVices) * 7
        
        return WeeklySummaryData(
            habitData: habitData,
            viceData: viceData,
            totalHabits: loggedHabits,
            totalVices: loggedVices,
            totalCompletions: totalCompletions,
            totalPossible: totalPossible
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 4) {
                        Text("This Week")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Past 7 days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    
                    // Overall Progress
                    overallProgressSection
                    
                    // Habits Section
                    if !weeklyData.habitData.isEmpty {
                        habitsSection
                    }
                    
                    // Vices Section
                    if !weeklyData.viceData.isEmpty {
                        vicesSection
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Weekly Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.caption)
                }
            }
        }
    }
    
    // MARK: - Overall Progress Section
    private var overallProgressSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("Overall Progress")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 4) {
                Text("\(weeklyData.totalCompletions)/\(weeklyData.totalPossible)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                Text("\(Int(weeklyData.overallPercentage * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress Bar
            ProgressView(value: weeklyData.overallPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Habits Section
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Habits")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            LazyVStack(spacing: 6) {
                ForEach(Array(weeklyData.habitData.keys.sorted()), id: \.self) { habitName in
                    WeeklyMetricRowView(
                        name: habitName,
                        completions: weeklyData.habitData[habitName] ?? 0,
                        maxPossible: 7,
                        isHabit: true
                    )
                }
            }
        }
    }
    
    // MARK: - Vices Section
    private var vicesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                Text("Vices")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            LazyVStack(spacing: 6) {
                ForEach(Array(weeklyData.viceData.keys.sorted()), id: \.self) { viceName in
                    WeeklyMetricRowView(
                        name: viceName,
                        completions: weeklyData.viceData[viceName] ?? 0,
                        maxPossible: 7,
                        isHabit: false
                    )
                }
            }
        }
    }
}

// MARK: - Weekly Summary Data Model
struct WeeklySummaryData {
    let habitData: [String: Int]
    let viceData: [String: Int]
    let totalHabits: Int
    let totalVices: Int
    let totalCompletions: Int
    let totalPossible: Int
    
    var overallPercentage: Double {
        return totalPossible > 0 ? Double(totalCompletions) / Double(totalPossible) : 0.0
    }
}

// MARK: - Weekly Metric Row View
struct WeeklyMetricRowView: View {
    let name: String
    let completions: Int
    let maxPossible: Int
    let isHabit: Bool
    
    private var completionRate: Double {
        return maxPossible > 0 ? Double(completions) / Double(maxPossible) : 0.0
    }
    
    private var progressColor: Color {
        if isHabit {
            return completionRate >= 0.7 ? .green : completionRate >= 0.4 ? .orange : .red
        } else {
            return completionRate >= 0.7 ? .red : completionRate >= 0.4 ? .orange : .green
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Metric name
            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
            
            // Completion count
            Text("\(completions)/\(maxPossible)")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.secondary)
            
            // Progress indicator
            Circle()
                .fill(progressColor)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview {
    WatchWeeklySummaryView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
