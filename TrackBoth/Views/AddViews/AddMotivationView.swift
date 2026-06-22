import SwiftUI
import SwiftData

struct AddMotivationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var entries: [MetricEntry]
    let metrics: [Metric]

    @State private var selectedMetric: Metric?
    @State private var noteText = ""

    private var sortedMetrics: [Metric] {
        let vices = metrics.filter { $0.habitType == .vice }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        let habits = metrics.filter { $0.habitType == .positive }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return vices + habits
    }

    init(metrics: [Metric], preselectedMetric: Metric? = nil) {
        self.metrics = metrics
        _selectedMetric = State(initialValue: preselectedMetric)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add a note")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.currentText)

                        Text("Journal how you're feeling today. This is separate from your pinned why — you can update that anytime from the card.")
                            .font(.body)
                            .foregroundColor(Color.currentSecondaryText)
                            .lineSpacing(2)
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("For which habit or vice?")
                            .font(.headline)
                            .foregroundColor(Color.currentText)

                        Picker("Habit or vice", selection: $selectedMetric) {
                            Text("Choose one").tag(nil as Metric?)
                            ForEach(sortedMetrics, id: \.id) { metric in
                                Label {
                                    Text(metric.name)
                                } icon: {
                                    Image(systemName: metric.habitType.icon)
                                }
                                .tag(metric as Metric?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.currentSecondaryBackground)
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's note")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.currentText)

                        TextEditor(text: $noteText)
                            .frame(minHeight: 180)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.currentSecondaryBackground)
                            )
                            .overlay {
                                if noteText.isEmpty {
                                    Text(selectedMetric?.habitType == .vice
                                         ? "What helped you stay strong — or what triggered a craving?"
                                         : "What made today easier or harder?")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.currentSecondaryText)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .padding(20)
                                        .allowsHitTesting(false)
                                }
                            }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.currentBackground)
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveNote() }
                        .fontWeight(.semibold)
                        .disabled(selectedMetric == nil || noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveNote() {
        guard let metric = selectedMetric else { return }

        let today = CalendarHelper.startOfDay(for: Date())
        MetricEntry.updateOrCreate(
            for: metric.id,
            date: today,
            motivation: noteText.trimmingCharacters(in: .whitespacesAndNewlines),
            in: modelContext,
            entries: entries
        )

        modelContext.saveChanges(operation: "save motivation note", entity: "MetricEntry")
        dismiss()
    }
}
