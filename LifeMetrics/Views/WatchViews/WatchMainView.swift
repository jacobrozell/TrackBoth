import SwiftUI
import SwiftData

// MARK: - Watch Main View
/// Main Apple Watch interface for today-only habit and vice tracking
struct WatchMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    
    @State private var selectedDate = Date()
    @State private var showingQuantityInput = false
    @State private var selectedMetric: Metric?
    @State private var showingWeeklySummary = false
    
    private var todayEntries: [MetricEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        return entries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: startOfDay)
        }
    }
    
    private var habits: [Metric] {
        metrics.filter { $0.habitType == .positive }
    }
    
    private var vices: [Metric] {
        metrics.filter { $0.habitType == .vice }
    }
    
    private var todaySummary: TodaySummary {
        let completedHabits = habits.filter { metric in
            todayEntries.contains { $0.metricID == metric.id && $0.value }
        }.count
        
        let completedVices = vices.filter { metric in
            todayEntries.contains { $0.metricID == metric.id && $0.value }
        }.count
        
        return TodaySummary(
            totalHabits: habits.count,
            completedHabits: completedHabits,
            totalVices: vices.count,
            completedVices: completedVices
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Date Header
                    dateHeader
                    
                    // Habits Section
                    if !habits.isEmpty {
                        habitsSection
                    }
                    
                    // Vices Section
                    if !vices.isEmpty {
                        vicesSection
                    }
                    
                    // Summary
                    summarySection
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .navigationTitle("TrackBoth")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Week") {
                        showingWeeklySummary = true
                    }
                    .font(.caption)
                }
            }
        }
        .sheet(isPresented: $showingQuantityInput) {
            if let metric = selectedMetric {
                WatchQuantityInputView(metric: metric, selectedDate: selectedDate)
            }
        }
        .sheet(isPresented: $showingWeeklySummary) {
            WatchWeeklySummaryView()
        }
    }
    
    // MARK: - Date Header
    private var dateHeader: some View {
        HStack {
            Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            if !Calendar.current.isDateInToday(selectedDate) {
                Button("Today") {
                    selectedDate = Date()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Habits Section
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Habits (\(todaySummary.completedHabits)/\(todaySummary.totalHabits))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            LazyVStack(spacing: 6) {
                ForEach(habits, id: \.id) { metric in
                    WatchMetricRowView(
                        metric: metric,
                        entry: entryForMetric(metric),
                        onTap: {
                            toggleMetric(metric)
                        },
                        onLongPress: {
                            selectedMetric = metric
                            showingQuantityInput = true
                        }
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
                Text("Vices (\(todaySummary.completedVices)/\(todaySummary.totalVices))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            LazyVStack(spacing: 6) {
                ForEach(vices, id: \.id) { metric in
                    WatchMetricRowView(
                        metric: metric,
                        entry: entryForMetric(metric),
                        onTap: {
                            toggleMetric(metric)
                        },
                        onLongPress: {
                            selectedMetric = metric
                            showingQuantityInput = true
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Summary Section
    private var summarySection: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("\(todaySummary.completedHabits + todaySummary.completedVices)/\(todaySummary.totalHabits + todaySummary.totalVices) Complete")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            if let streak = calculateStreak() {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(streak) day streak")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Helper Methods
    private func entryForMetric(_ metric: Metric) -> MetricEntry? {
        return todayEntries.first { $0.metricID == metric.id }
    }
    
    private func toggleMetric(_ metric: Metric) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        let entry = MetricEntry.getOrCreate(
            for: metric.id,
            date: startOfDay,
            in: modelContext,
            entries: entries,
            metric: metric
        )
        
        entry.value.toggle()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        try? modelContext.save()
    }
    
    private func calculateStreak() -> Int? {
        // Check if any metrics have entries
        let hasLoggedMetrics = metrics.contains { metric in entries.contains(where: { $0.metricID == metric.id }) }
        if !hasLoggedMetrics {
            return nil // No streak if no metrics have been logged
        }
        
        // Simple streak calculation - count consecutive days with any completion
        let calendar = Calendar.current
        var streak = 0
        var currentDate = selectedDate
        
        while streak < 30 { // Max 30 day streak for performance
            let dayEntries = entries.filter { entry in
                calendar.isDate(entry.date, inSameDayAs: currentDate)
            }
            
            if dayEntries.isEmpty || !dayEntries.contains(where: { $0.value }) {
                break
            }
            
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak > 0 ? streak : nil
    }
}

// MARK: - Today Summary Model
struct TodaySummary {
    let totalHabits: Int
    let completedHabits: Int
    let totalVices: Int
    let completedVices: Int
    
    var overallProgress: Double {
        let total = totalHabits + totalVices
        let completed = completedHabits + completedVices
        return total > 0 ? Double(completed) / Double(total) : 0.0
    }
}

#Preview {
    WatchMainView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
