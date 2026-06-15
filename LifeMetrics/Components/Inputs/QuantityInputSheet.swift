import SwiftUI
import SwiftData

// MARK: - QuantityInputSheet Component
/// Safe quantity input sheet with different flows for habits vs vices
struct QuantityInputSheet: View {
    let metric: Metric
    let selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var themeManager = ThemeManager.shared
    @Query private var entries: [MetricEntry]
    
    @State private var quantity: Int = 1
    @State private var unit: String = ""
    @State private var showingUnitPicker = false
    
    // Common units for different habit types
    private var commonUnits: [String] {
        switch metric.habitType {
        case .positive:
            return ["times", "minutes", "hours", "pages", "glasses", "servings", "sets", "reps"]
        case .vice:
            return ["times", "minutes", "hours", "servings"]
        }
    }
    
    private var isVice: Bool {
        metric.habitType == .vice
    }
    
    private var maxQuantity: Int {
        if let goal = metric.quantityGoals.first,
           let maxDaily = goal.safeMaxDailyQuantity {
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
        NavigationStack {
            VStack(spacing: 24) {
                // Header with habit info
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: metric.habitType.icon)
                            .foregroundColor(isVice ? .currentError : .currentSuccess)
                            .font(.title2)
                        
                        Text(metric.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.currentText)
                    }
                    
                    Text(DateFormatter.dayFormatter.string(from: selectedDate))
                        .font(.subheadline)
                        .foregroundColor(.currentSecondaryText)
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
                    .foregroundColor(.currentSecondaryText)
                    
                    Spacer()
                    
                    Button(isVice ? "Log Amount" : "Save") {
                        saveQuantity()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(isVice ? Color.currentWarning : Color.currentPrimary)
                    .cornerRadius(8)
                    .fontWeight(.medium)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.currentBackground)
        }
        .navigationBarHidden(true)
        .onAppear {
            setupInitialValues()
        }
        .sheet(isPresented: $showingUnitPicker) {
            UnitPickerSheet(
                selectedUnit: $unit,
                units: commonUnits
            )
        }
    }
    
    // MARK: - Vice Input Section (Safe Design)
    private var viceInputSection: some View {
        VStack(spacing: 16) {
            // Status indicator
            HStack {
                Text("Status:")
                    .font(.headline)
                    .foregroundColor(.currentText)
                Spacer()
                Text("Avoided ✓")
                    .font(.headline)
                    .foregroundColor(.currentSuccess)
            }
            .padding(.horizontal, 20)
            
            Divider()
            
            // Warning message
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.currentWarning)
                    Text("If you did \(metric.name.lowercased()) today:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.currentText)
                }
                
                Text("Remember: Your goal is to reduce this habit")
                    .font(.caption)
                    .foregroundColor(.currentSecondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            // Quantity input
            VStack(spacing: 12) {
                HStack {
                    Text("Amount:")
                        .font(.headline)
                        .foregroundColor(.currentText)
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
                                .foregroundColor(quantity > 1 ? .currentWarning : .currentSecondaryText)
                        }
                        .disabled(quantity <= 1)
                        
                        Text("\(quantity)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.currentWarning)
                            .frame(minWidth: 40)
                        
                        Button {
                            if quantity < maxQuantity {
                                quantity += 1
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(quantity < maxQuantity ? .currentWarning : .currentSecondaryText)
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
                                .foregroundColor(.currentText)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.currentSecondaryText)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.currentSecondaryBackground)
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
                                    .foregroundColor(quantity == preset ? .white : .currentWarning)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(quantity == preset ? Color.currentWarning : Color.currentWarning.opacity(0.2))
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
                        .foregroundColor(.currentText)
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
                                .foregroundColor(quantity > 1 ? .currentPrimary : .currentSecondaryText)
                        }
                        .disabled(quantity <= 1)
                        
                        Text("\(quantity)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.currentPrimary)
                            .frame(minWidth: 40)
                        
                        Button {
                            if quantity < maxQuantity {
                                quantity += 1
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(quantity < maxQuantity ? .currentPrimary : .currentSecondaryText)
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
                                .foregroundColor(.currentText)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.currentSecondaryText)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.currentSecondaryBackground)
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
                                    .foregroundColor(quantity == preset ? .white : .currentPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(quantity == preset ? Color.currentPrimary : Color.currentPrimary.opacity(0.2))
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
        unit = metric.quantityGoals.first?.safeDefaultUnit ?? "times"
        
        // Check if there's an existing entry for today
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        if let existingEntry = entries.first(where: { 
            $0.metricID == metric.id && calendar.isDate($0.date, inSameDayAs: startOfDay) 
        }) {
            quantity = existingEntry.quantity ?? 1
            unit = existingEntry.unit ?? (metric.quantityGoals.first?.safeDefaultUnit ?? "times")
        }
    }
    
    private func saveQuantity() {
        logger.logUserAction("Save quantity", details: "Metric: \(metric.name), Quantity: \(quantity), Unit: \(unit)")
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)

        let loggedValue = isVice
            ? TrackingSemantics.failureValue(habitType: .vice)
            : TrackingSemantics.successValue(habitType: .positive)

        MetricEntry.updateOrCreate(
            for: metric.id,
            date: startOfDay,
            value: loggedValue,
            quantity: quantity,
            unit: unit.isEmpty ? nil : unit,
            in: modelContext,
            entries: entries,
            metric: metric
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
    @StateObject private var themeManager = ThemeManager.shared
    @State private var customUnit: String = ""
    @State private var showingCustomInput = false
    
    var body: some View {
        NavigationStack {
            List {
                // Predefined units
                ForEach(units, id: \.self) { unit in
                    Button {
                        selectedUnit = unit
                        dismiss()
                    } label: {
                        HStack {
                            Text(unit)
                                .foregroundColor(.currentText)
                            Spacer()
                            if selectedUnit == unit {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.currentPrimary)
                            }
                        }
                    }
                }
                
                // Custom unit option
                Button {
                    showingCustomInput = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.currentPrimary)
                        Text("Custom Unit")
                            .foregroundColor(.currentPrimary)
                        Spacer()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.currentBackground)
            .navigationTitle("Select Unit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Custom Unit", isPresented: $showingCustomInput) {
                TextField("Enter unit", text: $customUnit)
                Button("Add") {
                    if !customUnit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        selectedUnit = customUnit.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter a custom unit for this metric.")
            }
        }
    }
}

#Preview {
    QuantityInputSheet(
        metric: Metric(name: "Smoking", habitType: .vice),
        selectedDate: Date()
    )
    .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
