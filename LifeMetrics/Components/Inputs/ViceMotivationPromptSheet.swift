import SwiftUI
import SwiftData

// MARK: - ViceMotivationPromptSheet
/// Shown after creating a vice without a primary motivation.
struct ViceMotivationPromptSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var metric: Metric
    let onComplete: () -> Void

    @State private var motivationText = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why avoid \(metric.name)?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.currentText)
                    Text("A personal reason helps when motivation dips. You can add more in the Motivation tab later.")
                        .font(.body)
                        .foregroundColor(Color.currentSecondaryText)
                }

                TextEditor(text: $motivationText)
                    .frame(minHeight: 160)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.currentSecondaryBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.currentSecondaryText.opacity(0.2), lineWidth: 1)
                    )

                Spacer()
            }
            .padding(20)
            .background(Color.currentBackground)
            .navigationTitle("Add Motivation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        onComplete()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMotivation()
                    }
                    .disabled(motivationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .interactiveDismissDisabled()
    }

    private func saveMotivation() {
        let trimmed = motivationText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        metric.primaryMotivation = trimmed
        modelContext.saveChanges(operation: "save vice motivation", entity: "Metric")
        onComplete()
    }
}
