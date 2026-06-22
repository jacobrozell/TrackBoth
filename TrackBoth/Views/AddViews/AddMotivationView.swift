import SwiftUI
import SwiftData

struct AddMotivationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let metrics: [Metric]

    @State private var selectedMetric: Metric?
    @State private var noteText = ""

    private var isMetricLocked: Bool {
        metrics.count == 1
    }

    private var sortedMetrics: [Metric] {
        let vices = metrics.filter { $0.habitType == .vice }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        let habits = metrics.filter { $0.habitType == .positive }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return vices + habits
    }

    init(metrics: [Metric], preselectedMetric: Metric? = nil) {
        self.metrics = metrics
        _selectedMetric = State(initialValue: preselectedMetric ?? (metrics.count == 1 ? metrics.first : nil))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Log motivation")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.currentText)

                        Text(introCopy)
                            .font(.body)
                            .foregroundColor(Color.currentSecondaryText)
                            .lineSpacing(2)
                    }
                    .padding(.top, 8)

                    if !isMetricLocked {
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
                    } else if let metric = selectedMetric {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("For")
                                .font(.caption)
                                .foregroundStyle(Color.currentSecondaryText)
                            Text(metric.name)
                                .font(.headline)
                                .foregroundStyle(Color.currentText)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("What came to mind?")
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
                                    Text(placeholderCopy)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.currentSecondaryText)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .padding(20)
                                        .allowsHitTesting(false)
                                }
                            }
                            .accessibilityIdentifier("motivation_note_text")
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.currentBackground)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveNote() }
                        .fontWeight(.semibold)
                        .disabled(selectedMetric == nil || noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier("motivation_note_save")
                }
            }
        }
    }

    private var introCopy: String {
        "Saved with today's date and time. This is separate from your primary motivation — add as many as you need."
    }

    private var navigationTitle: String {
        if let metric = selectedMetric, isMetricLocked {
            return metric.name
        }
        return "Log Motivation"
    }

    private var placeholderCopy: String {
        guard let metric = selectedMetric else {
            return "Choose a habit or vice first."
        }
        return metric.habitType == .vice
            ? "What helped you stay strong — or what triggered a craving?"
            : "What made today easier or harder?"
    }

    private func saveNote() {
        guard let metric = selectedMetric else { return }

        MetricEntry.insertMotivationNote(
            for: metric.id,
            motivation: noteText,
            in: modelContext
        )

        modelContext.saveChanges(operation: "save motivation note", entity: "MetricEntry")
        dismiss()
    }
}
