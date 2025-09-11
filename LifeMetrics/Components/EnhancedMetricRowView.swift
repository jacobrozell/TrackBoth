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
    @State private var showingQuantityInput = false
    
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
                        
                        // Quantity indicator
                        if let quantityString = selectedDateEntry?.quantityString {
                            Text(quantityString)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(metric.safeHabitType == .positive ? .blue : .orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill((metric.safeHabitType == .positive ? Color.blue : Color.orange).opacity(0.2))
                                )
                        }
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
                
                // Action buttons
                HStack(spacing: 8) {
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
                    
                    // Quantity input button (only for positive habits)
                    if metric.safeHabitType == .positive {
                        Button {
                            showingQuantityInput = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text("Qty")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    // Quantity log button for vices (different styling)
                    if metric.safeHabitType == .vice {
                        Button {
                            showingQuantityInput = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                
                                Text("Log")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
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
                
                // Quantity display section
                if let quantityString = selectedDateEntry?.quantityString {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Quantity")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button {
                                showingQuantityInput = true
                            } label: {
                                Text("Edit")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text(quantityString)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(metric.safeHabitType == .positive ? .blue : .orange)
                            .padding(.vertical, 4)
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
        .sheet(isPresented: $showingQuantityInput) {
            QuantityInputSheet(metric: metric, selectedDate: selectedDate)
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

// MARK: - QuantityInputSheet Component
/// Safe quantity input sheet with different flows for habits vs vices
struct QuantityInputSheet: View {
    let metric: Metric
    let selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [MetricEntry]
    
    @State private var quantity: Int = 1
    @State private var unit: String = ""
    @State private var showingUnitPicker = false
    
    // Common units for different habit types
    private var commonUnits: [String] {
        switch metric.safeHabitType {
        case .positive:
            return ["times", "minutes", "hours", "pages", "glasses", "servings", "sets", "reps"]
        case .vice:
            return ["times", "cigarettes", "drinks", "minutes", "hours", "servings"]
        }
    }
    
    private var isVice: Bool {
        metric.safeHabitType == .vice
    }
    
    private var maxQuantity: Int {
        if let maxDaily = metric.safeMaxDailyQuantity {
            return max(maxDaily, 10) // At least 10 for flexibility
        }
        return isVice ? 20 : 100 // Reasonable limits
    }
    
    private var quickPresets: [Int] {
        if isVice {
            return [1, 2, 3, 5, 10] // Smaller increments for vices
        } else {
            return [1, 2, 3, 5, 10, 15, 30, 60] // Larger range for habits
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header with habit info
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: metric.safeHabitType.icon)
                            .foregroundColor(isVice ? .red : .green)
                            .font(.title2)
                        
                        Text(metric.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Text(DateFormatter.dayFormatter.string(from: selectedDate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)
                
                // Main input section
                VStack(spacing: 20) {
                    if isVice {
                        // Vice-specific UI with safety messaging
                        viceInputSection
                    } else {
                        // Positive habit UI
                        habitInputSection
                    }
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(isVice ? "Log Amount" : "Save") {
                        saveQuantity()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(isVice ? Color.orange : Color.blue)
                    .cornerRadius(8)
                    .fontWeight(.medium)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            setupInitialValues()
        }
    }
    
    // MARK: - Vice Input Section (Safe Design)
    private var viceInputSection: some View {
        VStack(spacing: 16) {
            // Status indicator
            HStack {
                Text("Status:")
                    .font(.headline)
                Spacer()
                Text("Avoided ✓")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 20)
            
            Divider()
            
            // Warning message
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("If you did \(metric.name.lowercased()) today:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text("Remember: Your goal is to reduce this habit")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            // Quantity input
            VStack(spacing: 12) {
                HStack {
                    Text("Amount:")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 12) {
                    // Quantity stepper
                    HStack(spacing: 8) {
                        Button {
                            if quantity > 1 {
                                quantity -= 1
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(quantity > 1 ? .orange : .gray)
                        }
                        .disabled(quantity <= 1)
                        
                        Text("\(quantity)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .frame(minWidth: 40)
                        
                        Button {
                            if quantity < maxQuantity {
                                quantity += 1
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(quantity < maxQuantity ? .orange : .gray)
                        }
                        .disabled(quantity >= maxQuantity)
                    }
                    
                    Spacer()
                    
                    // Unit picker
                    Button {
                        showingUnitPicker = true
                    } label: {
                        HStack {
                            Text(unit.isEmpty ? "times" : unit)
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                
                // Quick presets for vices
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(quickPresets, id: \.self) { preset in
                            Button {
                                quantity = preset
                            } label: {
                                Text("\(preset)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(quantity == preset ? .white : .orange)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(quantity == preset ? Color.orange : Color.orange.opacity(0.2))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Habit Input Section
    private var habitInputSection: some View {
        VStack(spacing: 16) {
            // Quantity input
            VStack(spacing: 12) {
                HStack {
                    Text("Quantity:")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 12) {
                    // Quantity stepper
                    HStack(spacing: 8) {
                        Button {
                            if quantity > 1 {
                                quantity -= 1
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(quantity > 1 ? .blue : .gray)
                        }
                        .disabled(quantity <= 1)
                        
                        Text("\(quantity)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .frame(minWidth: 40)
                        
                        Button {
                            if quantity < maxQuantity {
                                quantity += 1
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(quantity < maxQuantity ? .blue : .gray)
                        }
                        .disabled(quantity >= maxQuantity)
                    }
                    
                    Spacer()
                    
                    // Unit picker
                    Button {
                        showingUnitPicker = true
                    } label: {
                        HStack {
                            Text(unit.isEmpty ? "times" : unit)
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                
                // Quick presets for habits
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(quickPresets, id: \.self) { preset in
                            Button {
                                quantity = preset
                            } label: {
                                Text("\(preset)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(quantity == preset ? .white : .blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(quantity == preset ? Color.blue : Color.blue.opacity(0.2))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupInitialValues() {
        unit = metric.safeDefaultUnit
        
        // Check if there's an existing entry for today
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        if let existingEntry = entries.first(where: { 
            $0.metricID == metric.id && calendar.isDate($0.date, inSameDayAs: startOfDay) 
        }) {
            quantity = existingEntry.quantity ?? 1
            unit = existingEntry.unit ?? metric.safeDefaultUnit
        }
    }
    
    private func saveQuantity() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        // For vices, we need to set value to false (not avoided) when logging quantity
        // For habits, we set value to true (done) when logging quantity
        let entryValue = isVice ? false : true
        
        MetricEntry.updateOrCreate(
            for: metric.id,
            date: startOfDay,
            value: entryValue,
            quantity: quantity,
            unit: unit.isEmpty ? nil : unit,
            in: modelContext,
            entries: entries
        )
        
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Unit Picker Sheet
struct UnitPickerSheet: View {
    @Binding var selectedUnit: String
    let units: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(units, id: \.self) { unit in
                Button {
                    selectedUnit = unit
                    dismiss()
                } label: {
                    HStack {
                        Text(unit)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedUnit == unit {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Unit")
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

#Preview {
    EnhancedMetricRowView(metric: Metric(name: "Exercise", habitType: .positive), selectedDate: Date())
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
