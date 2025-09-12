import SwiftUI
import SwiftData

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
            return ["times", "minutes", "hours", "servings"]
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
        logger.logUserAction("Save quantity", details: "Metric: \(metric.name), Quantity: \(quantity), Unit: \(unit)")
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
    @State private var customUnit: String = ""
    @State private var showingCustomInput = false
    
    var body: some View {
        NavigationView {
            List {
                // Predefined units
                ForEach(units, id: \.self) { unit in
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
                
                // Custom unit option
                Button {
                    showingCustomInput = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                        Text("Custom Unit")
                            .foregroundColor(.blue)
                        Spacer()
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
