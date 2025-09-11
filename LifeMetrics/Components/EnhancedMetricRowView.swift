import SwiftUI
import SwiftData

// MARK: - EnhancedMetricRowView Component
struct EnhancedMetricRowView: View {
    let metric: Metric
    let selectedDate: Date
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [MetricEntry]
    @State private var isEditingDetails = false
    @State private var editingDetailsText = ""
    @State private var isEditingMotivation = false
    @State private var editingMotivationText = ""
    
    private var selectedDateEntry: MetricEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        return entries.first { entry in
            entry.metricID == metric.id && 
            calendar.isDate(entry.date, inSameDayAs: startOfDay)
        }
    }
    
    private var streak: Int {
        StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: selectedDate)
    }
    
    private var goalProgress: (current: Int, target: Int, percentage: Double) {
        GoalUtils.calculateGoalProgress(for: metric, entries: entries, selectedDate: selectedDate)
    }
    
    private var recentDetails: String? {
        // Only show recent details if we're viewing today or a future date
        guard Calendar.current.isDate(selectedDate, inSameDayAs: Date()) || selectedDate > Date() else {
            return nil
        }
        
        let sortedEntries = entries
            .filter { $0.metricID == metric.id && $0.details != nil && !$0.details!.isEmpty }
            .sorted { $0.date > $1.date }
        return sortedEntries.first?.details
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with habit name and toggle button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: metric.safeHabitType.icon)
                            .foregroundColor(metric.safeHabitType == .positive ? .green : .red)
                            .font(.title3)
                        
                        Text(metric.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    // Enhanced info row
                    HStack(spacing: 16) {
                        if streak > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text(metric.safeHabitType == .positive ? 
                                     "\(streak) day streak" : 
                                     "\(streak) days clean")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Goal progress
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("\(goalProgress.current)/\(goalProgress.target)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Enhanced toggle button
                Button {
                    toggleSelectedDateEntry()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selectedDateEntry?.value == true ? "checkmark.circle.fill" : "circle")
                            .font(.title)
                            .foregroundColor(selectedDateEntry?.value == true ? .green : .gray)
                        
                        Text(selectedDateEntry?.value == true ? "Done" : "Tap")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Progress bar
            ProgressView(value: goalProgress.percentage)
                .progressViewStyle(LinearProgressViewStyle(tint: metric.safeHabitType == .positive ? .green : .red))
                .scaleEffect(x: 1, y: 0.5)
            
            // Today's status and details section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(Calendar.current.isDate(selectedDate, inSameDayAs: Date()) ? "Today" : "Selected Day")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if metric.safeHabitType == .positive {
                        Text(selectedDateEntry?.value == true ? "Done" : "Not Done")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedDateEntry?.value == true ? .green : .secondary)
                    } else {
                        Text(selectedDateEntry?.value == false ? "Avoided" : "Not Avoided")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedDateEntry?.value == false ? .green : .red)
                    }
                }
                
                // Details section for positive habits
                if metric.safeHabitType == .positive {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Details")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button {
                                if isEditingDetails {
                                    saveDetails()
                                } else {
                                    startEditingDetails()
                                }
                            } label: {
                                Text(isEditingDetails ? "Save" : "Edit")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if isEditingDetails {
                            TextField("What did you do?", text: $editingDetailsText, axis: .vertical)
                                .lineLimit(2...4)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        } else {
                            if let details = selectedDateEntry?.details, !details.isEmpty {
                                Text(details)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 4)
                            } else if let recentDetails = recentDetails {
                                Text("Last: \(recentDetails)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .italic()
                                    .padding(.vertical, 4)
                            } else {
                                Text("No details yet")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .italic()
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                // Motivation section for vices
                if metric.safeHabitType == .vice {
                    VStack(alignment: .leading, spacing: 8) {
                        // Primary motivation display
                        if let primaryMotivation = metric.primaryMotivation, !primaryMotivation.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Primary Motivation")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Text(primaryMotivation)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                        
                        // Daily motivation section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Daily Motivation")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button {
                                    if isEditingMotivation {
                                        saveMotivation()
                                    } else {
                                        startEditingMotivation()
                                    }
                                } label: {
                                    Text(isEditingMotivation ? "Save" : "Add")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            if isEditingMotivation {
                                TextField("Why are you avoiding this today?", text: $editingMotivationText, axis: .vertical)
                                    .lineLimit(2...4)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            } else {
                                if let motivation = selectedDateEntry?.motivation, !motivation.isEmpty {
                                    Text(motivation)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(.vertical, 4)
                                } else {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("No daily motivation added yet")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                            .italic()
                                        
                                        Text("💡 Add daily motivation to strengthen your resolve")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onAppear {
            editingDetailsText = selectedDateEntry?.details ?? ""
            editingMotivationText = selectedDateEntry?.motivation ?? ""
        }
    }
    
    // MARK: - Private Methods
    private func startEditingDetails() {
        editingDetailsText = selectedDateEntry?.details ?? ""
        isEditingDetails = true
    }
    
    private func saveDetails() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        MetricEntry.updateOrCreate(
            for: metric.id,
            date: startOfDay,
            details: editingDetailsText,
            in: modelContext,
            entries: entries
        )
        
        try? modelContext.save()
        isEditingDetails = false
    }
    
    private func startEditingMotivation() {
        editingMotivationText = selectedDateEntry?.motivation ?? ""
        isEditingMotivation = true
    }
    
    private func saveMotivation() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        MetricEntry.updateOrCreate(
            for: metric.id,
            date: startOfDay,
            motivation: editingMotivationText,
            in: modelContext,
            entries: entries
        )
        
        try? modelContext.save()
        isEditingMotivation = false
    }
    
    private func toggleSelectedDateEntry() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        if let existingEntry = selectedDateEntry {
            existingEntry.value.toggle()
        } else {
            MetricEntry.updateOrCreate(
                for: metric.id,
                date: startOfDay,
                value: true,
                in: modelContext,
                entries: entries
            )
        }
        
        try? modelContext.save()
    }
}

#Preview {
    EnhancedMetricRowView(metric: Metric(name: "Exercise", habitType: .positive), selectedDate: Date())
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
