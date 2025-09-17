import SwiftUI

// MARK: - Watch Unit Picker View
/// Unit selection and custom unit input for Apple Watch
struct WatchUnitPickerView: View {
    @Binding var selectedUnit: String
    let metric: Metric
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingCustomInput = false
    @State private var customUnit = ""
    
    private var commonUnits: [String] {
        switch metric.habitType {
        case .positive:
            return ["times", "minutes", "hours", "pages", "glasses", "servings", "sets", "reps"]
        case .vice:
            return ["times", "minutes", "hours", "servings"]
        }
    }
    
    private var customUnitExamples: [String] {
        switch metric.habitType {
        case .positive:
            return ["laps", "cups", "steps", "miles", "rounds", "sessions"]
        case .vice:
            return ["cigarettes", "drinks", "pieces", "items"]
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
                    
                    Text("Select Unit:")
                        .font(.subheadline)
                        .foregroundColor(Color.currentSecondaryText)
                }
                .padding(.top, 8)
                
                // Unit List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(commonUnits, id: \.self) { unit in
                            Button(action: {
                                selectedUnit = unit
                                dismiss()
                            }) {
                                HStack {
                                    Text(unit.capitalized)
                                        .font(.subheadline)
                                        .foregroundColor(Color.currentText)
                                    
                                    Spacer()
                                    
                                    if selectedUnit == unit {
                                        Image(systemName: "checkmark")
                                            .font(.subheadline)
                                            .foregroundColor(Color.currentPrimary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedUnit == unit ? Color.currentPrimary.opacity(0.1) : Color.clear)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Custom Unit Button
                        Button(action: {
                            showingCustomInput = true
                        }) {
                            HStack {
                                Text("Custom...")
                                    .font(.subheadline)
                                    .foregroundColor(Color.currentPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(Color.currentPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.currentPrimary, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
            .navigationTitle("Unit")
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
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter a custom unit for this metric.")
                
                if !customUnitExamples.isEmpty {
                    Text("Examples:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    ForEach(customUnitExamples.prefix(3), id: \.self) { example in
                        Text("• \(example)")
                            .font(.caption)
                    }
                }
            }
        }
    }
}

#Preview {
    WatchUnitPickerView(
        selectedUnit: .constant("minutes"),
        metric: Metric(name: "Exercise", habitType: .positive)
    )
}
