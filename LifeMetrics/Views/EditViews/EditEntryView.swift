import SwiftUI
import SwiftData

struct EditEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let entry: MetricEntry
    let metric: Metric?
    
    @Binding var editingDetails: String
    @Binding var editingMotivation: String
    @Binding var editingValue: Bool
    @Binding var isPresented: Bool
    @Binding var editingQuantity: Int
    @Binding var editingUnit: String
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }
    
    private var isVice: Bool {
        metric?.habitType == .vice
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Edit Entry")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(dateFormatter.string(from: entry.date))
                        .font(.subheadline)
                        .foregroundColor(Color.currentSecondaryText)
                    
                    if let metric = metric {
                        Text(metric.name)
                            .font(.headline)
                            .foregroundColor(Color.currentText)
                    }
                }
                
                // Value toggle
                VStack(alignment: .leading, spacing: 8) {
                    Text(isVice ? "Did you avoid this vice?" : "Did you do this habit?")
                        .font(.headline)
                    
                    Toggle(isOn: $editingValue) {
                        Text(editingValue ? (isVice ? "Avoided" : "Done") : (isVice ? "Did it" : "Skipped"))
                            .font(.body)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: isVice ? Color.currentError : Color.currentSuccess))
                }
                
                // Quantity section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantity (Optional)")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        // Quantity stepper
                        HStack(spacing: 8) {
                            Button {
                                if editingQuantity > 0 {
                                    editingQuantity -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(editingQuantity > 0 ? Color.currentPrimary : Color.currentSecondaryText)
                            }
                            .disabled(editingQuantity <= 0)
                            
                            Text("\(editingQuantity)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.currentPrimary)
                                .frame(minWidth: 40)
                            
                            Button {
                                editingQuantity += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Color.currentPrimary)
                            }
                        }
                        
                        Spacer()
                        
                        // Unit picker
                        TextField("Unit", text: $editingUnit)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                // Details (for positive habits)
                if !isVice {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Details (Optional)")
                            .font(.headline)
                        
                        TextField("What did you do?", text: $editingDetails, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                }
                
                // Motivation (for vices)
                if isVice {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Motivation (Optional)")
                            .font(.headline)
                        
                        TextField("Why did you avoid this?", text: $editingMotivation, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.currentBackground)
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        entry.value = editingValue
        entry.details = editingDetails.isEmpty ? nil : editingDetails
        entry.motivation = editingMotivation.isEmpty ? nil : editingMotivation
        entry.quantity = editingQuantity > 0 ? editingQuantity : nil
        entry.unit = editingUnit.isEmpty ? nil : editingUnit
        
        try? modelContext.save()
        dismiss()
    }
}
