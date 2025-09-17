import SwiftUI
import SwiftData

// MARK: - Unified Metric Row Component
struct UnifiedMetricRowView: View {
    let metric: Metric
    let selectedDate: Date
    let showGoalProgress: Bool
    let showQuantitySupport: Bool
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [MetricEntry]
    @State private var isEditingDetails = false
    @State private var editingDetailsText = ""
    @State private var isEditingMotivation = false
    @State private var editingMotivationText = ""
    @State private var showingQuantityInput = false
    
    // MARK: - Initializers
    init(metric: Metric, selectedDate: Date = Date(), showGoalProgress: Bool = false, showQuantitySupport: Bool = false) {
        self.metric = metric
        self.selectedDate = selectedDate
        self.showGoalProgress = showGoalProgress
        self.showQuantitySupport = showQuantitySupport
    }
    
    // MARK: - Computed Properties
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
        guard showGoalProgress, let goal = metric.booleanGoals.first else {
            return (current: 0, target: 0, percentage: 0.0)
        }
        let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
        return (current: Int(progress.current), target: Int(progress.target), percentage: progress.percentage)
    }
    
    private var recentDetails: String? {
        // Only show recent details if we're viewing today or a future date
        guard CalendarHelper.isSameDay(selectedDate, Date()) || selectedDate > Date() else {
            return nil
        }
        
        let sortedEntries = entries
            .filter { $0.metricID == metric.id && $0.details != nil && !$0.details!.isEmpty }
            .sorted { $0.date > $1.date }
        return sortedEntries.first?.details
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with habit name and toggle button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: metric.habitType.icon)
                            .foregroundColor(metric.habitType == .positive ? Color.currentSuccess : Color.currentError)
                            .font(.title3)
                        
                        Text(metric.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.currentText)
                        
                        // Quantity indicator (only if quantity support is enabled)
                        if showQuantitySupport, let quantityString = selectedDateEntry?.quantityString {
                            Text(quantityString)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(metric.habitType == .positive ? Color.currentPrimary : Color.currentWarning)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill((metric.habitType == .positive ? Color.currentPrimary : Color.currentWarning).opacity(0.2))
                                )
                        }
                    }
                    
                    // Enhanced info row (only if goal progress is enabled)
                    if showGoalProgress {
                        HStack(spacing: 16) {
                            if streak > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(Color.currentWarning)
                                        .font(.caption)
                                    Text(metric.habitType == .positive ? 
                                         "\(streak) day streak" : 
                                         "\(streak) days clean")
                                        .font(.caption)
                                        .foregroundColor(Color.currentSecondaryText)
                                }
                            }
                            
                            // Goal progress
                            HStack(spacing: 4) {
                                Image(systemName: "target")
                                    .foregroundColor(Color.currentPrimary)
                                    .font(.caption)
                                Text("\(goalProgress.current)/\(goalProgress.target)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else if streak > 0 {
                        // Simple streak display for basic mode
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(Color.currentWarning)
                            Text(metric.habitType == .positive ? 
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
                    toggleSelectedDateEntry()
                } label: {
                    let isCompleted = isMetricCompleted()
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(isCompleted ? Color.currentSuccess : Color.currentSecondaryText)
                }
            }
            
            // Today's status and details section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(CalendarHelper.isSameDay(selectedDate, Date()) ? "Today" : "Selected Day")
                        .font(.headline)
                        .foregroundColor(Color.currentText)
                    
                    Spacer()
                    
                    if metric.habitType == .positive {
                        let done = selectedDateEntry?.value == true
                        Text(done ? "Done" : "Not Done")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(done ? Color.currentSuccess : Color.currentSecondaryText)
                    } else {
                        // For vices, absence of an entry means avoided (default good state)
                        let avoided = selectedDateEntry == nil || selectedDateEntry?.value == false
                        Text(avoided ? "Avoided" : "Not Avoided")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(avoided ? Color.currentSuccess : Color.currentError)
                    }
                }
                
                // Details section for positive habits
                if metric.habitType == .positive {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Details")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.currentText)
                            
                            Spacer()
                            
                            Button {
                                logger.logUserAction("Edit details", details: "Metric: \(metric.name)")
                                isEditingDetails = true
                                editingDetailsText = selectedDateEntry?.details ?? ""
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.caption)
                                    .foregroundColor(Color.currentPrimary)
                            }
                        }
                        
                        if isEditingDetails {
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Enter details...", text: $editingDetailsText, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(2...4)
                                
                                HStack {
                                    Button("Cancel") {
                                        isEditingDetails = false
                                        editingDetailsText = ""
                                    }
                                    .foregroundColor(Color.currentSecondaryText)
                                    
                                    Spacer()
                                    
                                    Button("Save") {
                                        saveDetails()
                                    }
                                    .foregroundColor(Color.currentPrimary)
                                    .fontWeight(.medium)
                                }
                            }
                        } else {
                            if let details = selectedDateEntry?.details, !details.isEmpty {
                                Text(details)
                                    .font(.subheadline)
                                    .foregroundColor(Color.currentText)
                                    .padding(.vertical, 4)
                            } else if let recentDetails = recentDetails {
                                Text(recentDetails)
                                    .font(.subheadline)
                                    .foregroundColor(Color.currentSecondaryText)
                                    .italic()
                                    .padding(.vertical, 4)
                            } else {
                                Text("Tap to add details")
                                    .font(.subheadline)
                                    .foregroundColor(Color.currentSecondaryText)
                                    .italic()
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                // Quantity section (only if quantity support is enabled)
                if showQuantitySupport {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Quantity")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.currentText)
                            
                            Spacer()
                            
                            Button {
                                logger.logUserAction("Edit quantity", details: "Metric: \(metric.name)")
                                showingQuantityInput = true
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.caption)
                                    .foregroundColor(Color.currentPrimary)
                            }
                        }
                        
                        if let quantityString = selectedDateEntry?.quantityString {
                            Text(quantityString)
                                .font(.subheadline)
                                .foregroundColor(Color.currentText)
                                .padding(.vertical, 4)
                        } else {
                            Text("Tap to add quantity")
                                .font(.subheadline)
                                .foregroundColor(.currentSecondaryText)
                                .italic()
                                .padding(.vertical, 4)
                        }
                    }
                }
                
                // Motivation section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Motivation")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.currentText)
                        
                        Spacer()
                        
                        Button {
                            logger.logUserAction("Edit motivation", details: "Metric: \(metric.name)")
                            isEditingMotivation = true
                            editingMotivationText = selectedDateEntry?.motivation ?? ""
                        } label: {
                            Image(systemName: "heart")
                                .font(.caption)
                                .foregroundColor(Color.currentAccent)
                        }
                    }
                    
                    if isEditingMotivation {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Why is this important?", text: $editingMotivationText, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(2...4)
                            
                            HStack {
                                Button("Cancel") {
                                    isEditingMotivation = false
                                    editingMotivationText = ""
                                }
                                .foregroundColor(.currentSecondaryText)
                                
                                Spacer()
                                
                                Button("Save") {
                                    saveMotivation()
                                }
                                .foregroundColor(Color.currentAccent)
                                .fontWeight(.medium)
                            }
                        }
                    } else {
                        if let motivation = selectedDateEntry?.motivation, !motivation.isEmpty {
                            Text(motivation)
                                .font(.subheadline)
                                .foregroundColor(Color.currentText)
                                .padding(.vertical, 4)
                        } else if let primaryMotivation = metric.primaryMotivation, !primaryMotivation.isEmpty {
                            Text(primaryMotivation)
                                .font(.subheadline)
                                .foregroundColor(.currentSecondaryText)
                                .italic()
                                .padding(.vertical, 4)
                        } else {
                            Text("Tap to add motivation")
                                .font(.subheadline)
                                .foregroundColor(.currentSecondaryText)
                                .italic()
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingQuantityInput) {
            QuantityInputSheet(
                metric: metric,
                selectedDate: selectedDate
            )
        }
    }
    
    // MARK: - Private Methods
    private func isMetricCompleted() -> Bool {
        // Only count as completed if metric has entries
        guard entries.contains(where: { $0.metricID == metric.id }) else { return false }
        
        let isVice = metric.habitType == .vice
        if isVice {
            // For vices, completed when explicitly logged as avoided (value == false)
            return selectedDateEntry?.value == false
        } else {
            // For habits, completed when explicitly logged as done (value == true)
            return selectedDateEntry?.value == true
        }
    }
    
    private func toggleSelectedDateEntry() {
        let startOfDay = CalendarHelper.startOfDay(for: selectedDate)
        
        // Use getOrCreate to handle both existing and new entries
        let entry = MetricEntry.getOrCreate(
            for: metric.id,
            date: startOfDay,
            in: modelContext,
            entries: entries,
            metric: metric
        )
        
        // Toggle the entry value
        let oldValue = entry.value
        entry.value.toggle()
        logger.debug("Toggled entry for \(metric.name) on \(DateFormatter.dateFormatter.string(from: selectedDate)) - From: \(oldValue) to \(entry.value)", category: .data)
        
        do {
            try modelContext.save()
            logger.info("Successfully saved metric entry toggle", category: .data)
        } catch {
            logger.error("Failed to save metric entry toggle: \(error.localizedDescription)", category: .data)
        }
    }
    
    private func saveDetails() {
        let startOfDay = CalendarHelper.startOfDay(for: selectedDate)
        
        let entry = MetricEntry.getOrCreate(
            for: metric.id,
            date: startOfDay,
            in: modelContext,
            entries: entries,
            metric: metric
        )
        
        entry.details = editingDetailsText.isEmpty ? nil : editingDetailsText
        
        do {
            try modelContext.save()
            isEditingDetails = false
            editingDetailsText = ""
            logger.info("Successfully saved metric details", category: .data)
        } catch {
            logger.error("Failed to save metric details: \(error.localizedDescription)", category: .data)
        }
    }
    
    private func saveMotivation() {
        let startOfDay = CalendarHelper.startOfDay(for: selectedDate)
        
        let entry = MetricEntry.getOrCreate(
            for: metric.id,
            date: startOfDay,
            in: modelContext,
            entries: entries,
            metric: metric
        )
        
        entry.motivation = editingMotivationText.isEmpty ? nil : editingMotivationText
        
        do {
            try modelContext.save()
            isEditingMotivation = false
            editingMotivationText = ""
            logger.info("Successfully saved metric motivation", category: .data)
        } catch {
            logger.error("Failed to save metric motivation: \(error.localizedDescription)", category: .data)
        }
    }
}

// MARK: - Convenience Initializers
extension UnifiedMetricRowView {
    /// Basic metric row for simple display (replaces MetricRowView)
    static func basic(metric: Metric, selectedDate: Date = Date()) -> UnifiedMetricRowView {
        return UnifiedMetricRowView(metric: metric, selectedDate: selectedDate, showGoalProgress: false, showQuantitySupport: false)
    }
    
    /// Enhanced metric row with goal progress and quantity support (replaces EnhancedMetricRowView)
    static func enhanced(metric: Metric, selectedDate: Date = Date()) -> UnifiedMetricRowView {
        return UnifiedMetricRowView(metric: metric, selectedDate: selectedDate, showGoalProgress: true, showQuantitySupport: true)
    }
}
