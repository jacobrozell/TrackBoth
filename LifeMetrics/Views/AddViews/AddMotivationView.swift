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
                        
                        Text("Write down your reasons for avoiding a vice. This will help you stay strong when you're struggling.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.currentSecondaryText)
                            .lineSpacing(2)
                    }
                    .padding(.top, 8)
                    
                    // Metric picker with better design
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Vice")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.currentText)
                        
                        Picker("Vice", selection: $selectedMetric) {
                            Text("Choose a vice to motivate against").tag(nil as Metric?)
                            ForEach(metrics) { metric in
                                HStack(spacing: 12) {
                                    Image(systemName: metric.habitType.icon)
                                        .foregroundColor(Color.currentError)
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
                                                Text("Why do you want to avoid this vice?")
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
            value: false,
            motivation: motivationText.trimmingCharacters(in: .whitespacesAndNewlines),
            in: modelContext,
            entries: entries
        )
        
        try? modelContext.save()
        dismiss()
    }
}
