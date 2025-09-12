import SwiftUI
import SwiftData

// MARK: - MetricRowView Component
struct MetricRowView: View {
    let metric: Metric
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [MetricEntry]
    @State private var isEditingDetails = false
    @State private var editingDetailsText = ""
    @State private var isEditingMotivation = false
    @State private var editingMotivationText = ""
    
    private var todayEntry: MetricEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return entries.first { entry in
            entry.metricID == metric.id && 
            Calendar.current.isDate(entry.date, inSameDayAs: today)
        }
    }
    
    private var streak: Int {
        StreakUtils.calculateCurrentStreak(for: metric, entries: entries)
    }
    
    private var recentDetails: String? {
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
                    
                    if streak > 0 {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text(metric.safeHabitType == .positive ? 
                                 "\(streak) day streak" : 
                                 "\(streak) days clean")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Toggle button - only for completion status
                Button {
                    logger.logUserAction("Toggle metric completion", details: "Metric: \(metric.name)")
                    toggleTodayEntry()
                } label: {
                    Image(systemName: todayEntry?.value == true ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(todayEntry?.value == true ? .green : .gray)
                }
            }
            
            // Today's status and details section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Today")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if metric.safeHabitType == .positive {
                        Text(todayEntry?.value == true ? "Done" : "Not Done")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(todayEntry?.value == true ? .green : .secondary)
                    } else {
                        Text(todayEntry?.value == false ? "Avoided" : "Not Avoided")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(todayEntry?.value == false ? .green : .red)
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
                                    logger.logUserAction("Save details", details: "Metric: \(metric.name)")
                                    saveDetails()
                                } else {
                                    logger.logUserAction("Start editing details", details: "Metric: \(metric.name)")
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
                            if let details = todayEntry?.details, !details.isEmpty {
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
                        HStack {
                            Text("Today's Motivation")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button {
                                if isEditingMotivation {
                                    logger.logUserAction("Save motivation", details: "Metric: \(metric.name)")
                                    saveMotivation()
                                } else {
                                    logger.logUserAction("Start editing motivation", details: "Metric: \(metric.name)")
                                    startEditingMotivation()
                                }
                            } label: {
                                Text(isEditingMotivation ? "Save" : "Edit")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if isEditingMotivation {
                            TextField("Why are you avoiding this?", text: $editingMotivationText, axis: .vertical)
                                .lineLimit(2...4)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        } else {
                            if let motivation = todayEntry?.motivation, !motivation.isEmpty {
                                Text(motivation)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 4)
                            } else {
                                Text("No motivation added today")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .italic()
                                    .padding(.vertical, 4)
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
            editingDetailsText = todayEntry?.details ?? ""
            editingMotivationText = todayEntry?.motivation ?? ""
        }
    }
    
    // MARK: - Private Methods
    private func startEditingDetails() {
        editingDetailsText = todayEntry?.details ?? ""
        isEditingDetails = true
    }
    
    private func saveDetails() {
        let today = Calendar.current.startOfDay(for: Date())
        
        MetricEntry.updateOrCreate(
            for: metric.id,
            date: today,
            details: editingDetailsText,
            in: modelContext,
            entries: entries
        )
        
        try? modelContext.save()
        isEditingDetails = false
    }
    
    private func startEditingMotivation() {
        editingMotivationText = todayEntry?.motivation ?? ""
        isEditingMotivation = true
    }
    
    private func saveMotivation() {
        let today = Calendar.current.startOfDay(for: Date())
        
        MetricEntry.updateOrCreate(
            for: metric.id,
            date: today,
            motivation: editingMotivationText,
            in: modelContext,
            entries: entries
        )
        
        try? modelContext.save()
        isEditingMotivation = false
    }
    
    private func toggleTodayEntry() {
        logger.debug("Toggling today's entry - Metric: \(metric.name)", category: .data)
        let today = Calendar.current.startOfDay(for: Date())
        
        if let existingEntry = todayEntry {
            existingEntry.value.toggle()
        } else {
            MetricEntry.updateOrCreate(
                for: metric.id,
                date: today,
                value: true,
                in: modelContext,
                entries: entries
            )
        }
        
        try? modelContext.save()
    }
}

#Preview {
    MetricRowView(metric: Metric(name: "Exercise", habitType: .positive))
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
