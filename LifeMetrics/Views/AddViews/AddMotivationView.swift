import SwiftUI
import SwiftData

struct AddMotivationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var entries: [MetricEntry]
    let metrics: [Metric]
    
    @State private var selectedMetric: Metric?
    @State private var motivationText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add Motivation")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.currentText)
                        
                        Text("Write your own motivation to help you stay strong when struggling.")
                            .font(.body)
                            .foregroundColor(Color.currentSecondaryText)
                            .lineSpacing(2)
                    }
                    .padding(.top, 8)
                    
                    // Metric picker with better design
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Habit")
                            .font(.headline)
                            .foregroundColor(Color.currentText)
                        
                        Picker("Habit", selection: $selectedMetric) {
                            Text("Choose a habit to motivate for").tag(nil as Metric?)
                            ForEach(metrics) { metric in
                                HStack(spacing: 12) {
                                    Image(systemName: metric.habitType.icon)
                                        .foregroundColor(metric.habitType == .positive ? Color.currentSuccess : Color.currentError)
                                        .font(.system(size: 16))
                                        .frame(width: 20)
                                    Text(metric.name)
                                        .font(.system(size: 16, weight: .medium))
                                }.tag(metric as Metric?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.currentSecondaryBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.currentSecondaryBackground, lineWidth: 1)
                        )
                    }
                    
                    // Motivation text input with better design
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Motivation")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.currentText)
                        
                        TextEditor(text: $motivationText)
                            .frame(minHeight: 200)
                            .font(.system(size: 16, weight: .regular))
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.currentSecondaryBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.currentSecondaryBackground, lineWidth: 1)
                            )
                            .overlay(
                                // Placeholder text
                                Group {
                                    if motivationText.isEmpty {
                                        VStack {
                                            HStack {
                                                Text("Why is this habit important to you?")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color.currentSecondaryText)
                                                    .padding(.leading, 20)
                                                    .padding(.top, 24)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            )
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.currentBackground)
            .navigationTitle("Add Motivation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMotivation()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(selectedMetric == nil || motivationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveMotivation() {
        guard let metric = selectedMetric else { return }
        
        let today = CalendarHelper.startOfDay(for: Date())
        MetricEntry.updateOrCreate(
            for: metric.id,
            date: today,
            motivation: motivationText.trimmingCharacters(in: .whitespacesAndNewlines),
            in: modelContext,
            entries: entries
        )
        
        modelContext.saveChanges(operation: "save motivation", entity: "MetricEntry")
        dismiss()
    }
}
