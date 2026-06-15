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
                .foregroundColor(Color.currentText)
            
            Spacer()
            
            if !Calendar.current.isDateInToday(selectedDate) {
                Button("Today") {
                    selectedDate = Date()
                }
                .font(.caption)
                .foregroundColor(Color.currentPrimary)
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Habits Section
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.currentSuccess)
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
                    .foregroundColor(Color.currentError)
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
                    .foregroundColor(Color.currentPrimary)
                Text("\(todaySummary.completedHabits + todaySummary.completedVices)/\(todaySummary.totalHabits + todaySummary.totalVices) Complete")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            if let streak = calculateStreak() {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color.currentWarning)
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

        let existingEntry = MetricEntry.find(for: metric.id, date: startOfDay, in: entries)
        let newValue = TrackingSemantics.valueAfterQuickToggle(
            habitType: metric.habitType,
            existingEntry: existingEntry
        )

        let entry: MetricEntry
        if let existingEntry {
            entry = existingEntry
        } else {
            entry = MetricEntry(metricID: metric.id, date: startOfDay, value: newValue, hasBeenLogged: false)
            modelContext.insert(entry)
        }

        entry.value = newValue
        MetricEntry.markLogged(entry: entry, metric: metric)

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        try? modelContext.save()
    }

    private func calculateStreak() -> Int? {
        let streaks = metrics.compactMap { metric -> Int? in
            let streak = StreakUtils.calculateCurrentStreak(
                for: metric,
                entries: entries,
                selectedDate: selectedDate
            )
            return streak > 0 ? streak : nil
        }
        guard let best = streaks.max() else { return nil }
        return best
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
