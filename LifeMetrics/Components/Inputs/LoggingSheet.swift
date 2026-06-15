import SwiftUI
import SwiftData
import UIKit

// MARK: - LoggingSheet Component
/// Sheet component for logging metric entries with details and motivation
struct LoggingSheet: View, Identifiable {
    let id = UUID()
    let metric: Metric
    let selectedDate: Date

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var themeManager = ThemeManager.shared
    @Query private var entries: [MetricEntry]

    @State private var value: Bool = false
    @State private var details: String = ""
    @State private var motivation: String = ""
    @State private var quantity: Int?
    @State private var unit: String = "times"
    @State private var showingQuantitySheet: Bool = false

    private var existingEntry: MetricEntry? {
        let start = Calendar.current.startOfDay(for: selectedDate)
        return entries.first { $0.metricID == metric.id && Calendar.current.isDate($0.date, inSameDayAs: start) }
    }

    private var quantitySummary: String {
        guard let quantity, quantity > 0 else { return "Not set" }
        return "\(quantity) \(unit)"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Status")) {
                    Toggle(isOn: statusToggleBinding) {
                        Text(metric.habitType == .positive ? "Did it" : "Avoided")
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.loggingStatusToggle)
                }

                Section(header: Text("Daily Details")) {
                    TextField("Optional details", text: $details, axis: .vertical)
                }

                Section(header: Text("Daily Motivation")) {
                    TextField("Why?", text: $motivation, axis: .vertical)
                }

                Section(header: Text("Quantity")) {
                    if (quantity ?? 0) > 0 {
                        Stepper(value: Binding(
                            get: { quantity ?? 1 },
                            set: { quantity = max(1, $0) }
                        ), in: 1...999) {
                            Text(quantitySummary)
                        }

                        Button("Advanced quantity editor") {
                            showingQuantitySheet = true
                        }
                        .foregroundColor(.currentPrimary)

                        Button("Clear quantity", role: .destructive) {
                            quantity = nil
                        }
                    } else {
                        Button("Add quantity") {
                            quantity = 1
                            unit = metric.quantityGoals.first?.safeDefaultUnit ?? "times"
                        }
                        .foregroundColor(.currentPrimary)

                        Button("Open quantity editor") {
                            showingQuantitySheet = true
                        }
                        .foregroundColor(.currentSecondaryText)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.currentBackground)
            .navigationTitle(metric.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndClose() }
                        .accessibilityIdentifier(AccessibilityIdentifiers.loggingSaveButton)
                }
            }
            .onAppear { seedDefaults() }
            .sheet(isPresented: $showingQuantitySheet, onDismiss: syncQuantityFromStore) {
                QuantityInputSheet(metric: metric, selectedDate: selectedDate)
            }
        }
    }

    private var statusToggleBinding: Binding<Bool> {
        Binding(
            get: { TrackingSemantics.toggleIsOn(habitType: metric.habitType, value: value) },
            set: { value = TrackingSemantics.value(fromToggleIsOn: $0, habitType: metric.habitType) }
        )
    }

    private func seedDefaults() {
        if let entry = existingEntry {
            value = entry.value
            details = entry.details ?? ""
            motivation = entry.motivation ?? ""
            quantity = entry.quantity
            unit = entry.unit ?? (metric.quantityGoals.first?.safeDefaultUnit ?? "times")
        } else {
            value = TrackingSemantics.failureValue(habitType: metric.habitType)
            quantity = nil
            unit = metric.quantityGoals.first?.safeDefaultUnit ?? "times"
        }
    }

    private func syncQuantityFromStore() {
        guard let entry = existingEntry else { return }
        quantity = entry.quantity
        unit = entry.unit ?? unit
        if entry.hasBeenLogged {
            value = entry.value
        }
    }

    private func saveAndClose() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)

        let entry: MetricEntry
        if let existingEntry {
            entry = existingEntry
        } else {
            entry = MetricEntry(metricID: metric.id, date: startOfDay, value: value, hasBeenLogged: false)
            modelContext.insert(entry)
        }

        entry.value = value
        entry.details = details.isEmpty ? nil : details
        entry.motivation = motivation.isEmpty ? nil : motivation

        if let quantity, quantity > 0 {
            entry.quantity = quantity
            entry.unit = unit.isEmpty ? nil : unit
        } else {
            entry.quantity = nil
            entry.unit = nil
        }

        MetricEntry.markLogged(entry: entry, metric: metric)

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    LoggingSheet(
        metric: Metric(name: "Exercise", habitType: .positive),
        selectedDate: Date()
    )
    .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
