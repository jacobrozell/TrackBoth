import SwiftUI
import SwiftData

// MARK: - Watch Quantity Input View
/// Quantity input modal for Apple Watch
struct WatchQuantityInputView: View {
    let metric: Metric
    let selectedDate: Date
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [MetricEntry]
    
    @State private var quantity: Int = 1
    @State private var unit: String = ""
    @State private var showingUnitPicker = false
    
    private var isVice: Bool {
        metric.habitType == .vice
    }
    
    private var maxQuantity: Int {
        if let goal = metric.quantityGoals.first,
           let maxDaily = goal.safeMaxDailyQuantity {
            return max(maxDaily, 10)
        }
        return isVice ? 20 : 100
    }
    
    private var quickPresets: [Int] {
        if isVice {
            return [1, 2, 3, 5, 10]
        } else {
            return [1, 2, 3, 5, 10, 15, 30, 60]
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 4) {
                    Text(metric.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("How many \(unit)?")
                        .font(.subheadline)
                        .foregroundColor(Color.currentSecondaryText)
                }
                .padding(.top, 8)
                
                // Quantity Display
                Text("\(quantity)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color.currentText)
                    .frame(height: 40)
                
                // Quick Preset Buttons
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(quickPresets, id: \.self) { preset in
                        Button("\(preset)") {
                            quantity = preset
                            hapticFeedback()
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.currentText)
                        .frame(width: 50, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(quantity == preset ? Color.currentPrimary : Color.currentSecondaryBackground)
                        )
                        .foregroundColor(quantity == preset ? .white : Color.currentText)
                    }
                }
                .padding(.horizontal, 16)
                
                // Unit Selection Button
                Button(action: {
                    showingUnitPicker = true
                }) {
                    HStack {
                        Text("Unit: \(unit)")
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(Color.currentPrimary)
                    .padding(.vertical, 8)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(Color.currentSecondaryText)
                    
                    Button("Save") {
                        saveQuantity()
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.currentPrimary)
                    .cornerRadius(8)
                }
                .padding(.bottom, 8)
            }
            .navigationTitle("Quantity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.caption)
                }
            }
        }
        .sheet(isPresented: $showingUnitPicker) {
            WatchUnitPickerView(selectedUnit: $unit, metric: metric)
        }
        .onAppear {
            setupInitialValues()
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
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        // If they log quantity, we know they did it - set boolean to true
        MetricEntry.updateOrCreate(
            for: metric.id,
            date: startOfDay,
            value: true,
            quantity: quantity,
            unit: unit.isEmpty ? nil : unit,
            in: modelContext,
            entries: entries
        )
        
        try? modelContext.save()
        
        // Success haptic feedback
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)
        
        dismiss()
    }
    
    private func hapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    WatchQuantityInputView(
        metric: Metric(name: "Exercise", habitType: .positive),
        selectedDate: Date()
    )
    .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
