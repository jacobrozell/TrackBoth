import SwiftUI
import SwiftData

// MARK: - Edit Why Sheet
/// Updates the pinned reason on a habit or vice (`Metric.primaryMotivation`).
struct EditWhySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let metric: Metric

    @State private var whyText = ""

    private var isVice: Bool { metric.habitType == .vice }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        isVice ? "Why do you want to avoid this?" : "Why does this habit matter?",
                        text: $whyText,
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                } header: {
                    Text("Primary motivation")
                } footer: {
                    Text(isVice
                         ? "Your main reason to stay clean — separate from day-to-day logged motivations."
                         : "Your main reason for this habit — separate from logged reflections.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.currentBackground)
            .navigationTitle(metric.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                whyText = metric.primaryMotivation ?? ""
            }
        }
    }

    private func save() {
        let trimmed = whyText.trimmingCharacters(in: .whitespacesAndNewlines)
        metric.primaryMotivation = trimmed.isEmpty ? nil : trimmed
        modelContext.saveChanges(operation: "update your why", entity: "Metric")
        dismiss()
    }
}
