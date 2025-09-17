import SwiftUI
import SwiftData

// MARK: - LoggingSheet Component
/// Sheet component for logging metric entries with details and motivation
struct LoggingSheet: View, Identifiable {
    let id = UUID()
    let metric: Metric
    let selectedDate: Date

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [MetricEntry]

    @State private var value: Bool = false
    @State private var details: String = ""
    @State private var motivation: String = ""
    @State private var showingQuantitySheet: Bool = false

    private var existingEntry: MetricEntry? {
        let start = Calendar.current.startOfDay(for: selectedDate)
        return entries.first { $0.metricID == metric.id && Calendar.current.isDate($0.date, inSameDayAs: start) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Status")) {
                    Toggle(isOn: $value) {
                        Text(metric.habitType == .positive ? "Did it" : "Avoided")
                    }
                }

                Section(header: Text("Daily Details")) {
                    TextField("Optional details", text: $details, axis: .vertical)
                }

                Section(header: Text("Daily Motivation")) {
                    TextField("Why?", text: $motivation, axis: .vertical)
                }

                Section(header: Text("Quantity")) {
                    HStack {
                        Text(existingEntry?.quantityString ?? "Not set")
                            .foregroundColor(.currentSecondaryText)
                        Spacer()
                        Button("Set Quantity") { showingQuantitySheet = true }
                            .foregroundColor(.currentPrimary)
                    }
                }
            }
            .background(Color.currentBackground)
            .navigationTitle(metric.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndClose() }
                }
            }
            .onAppear { seedDefaults() }
            .sheet(isPresented: $showingQuantitySheet) {
                QuantityInputSheet(metric: metric, selectedDate: selectedDate)
            }
        }
    }

    private func seedDefaults() {
        if let entry = existingEntry {
            value = entry.value
            details = entry.details ?? ""
            motivation = entry.motivation ?? ""
        } else {
            // Defaults per spec: habits not done; vices not avoided
            value = false
        }
    }

    private func saveAndClose() {
        // Persist via HomeViewModel-like helpers
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)

        if let entry = existingEntry {
            entry.value = value
            entry.details = details.isEmpty ? nil : details
            entry.motivation = motivation.isEmpty ? nil : motivation
        } else {
            let newEntry = MetricEntry(metricID: metric.id, date: startOfDay, value: value)
            newEntry.details = details.isEmpty ? nil : details
            newEntry.motivation = motivation.isEmpty ? nil : motivation
            modelContext.insert(newEntry)
        }

        try? modelContext.save()
        dismiss()
    }

    // Quantity is handled by QuantityInputSheet which persists directly
}

#Preview {
    LoggingSheet(
        metric: Metric(name: "Exercise", habitType: .positive),
        selectedDate: Date()
    )
    .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
