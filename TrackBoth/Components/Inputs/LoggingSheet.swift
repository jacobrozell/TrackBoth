import SwiftUI
import SwiftData
import UIKit

// MARK: - LoggingSheet Component
/// Sheet for optional logging details beyond the one-tap toggle on Track.
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
    @State private var quantity: Int?
    @State private var unit: String = "times"
    @State private var mood: String?
    @State private var showingQuantitySheet: Bool = false
    @State private var showsMoreOptions = false

    private var existingEntry: MetricEntry? {
        let start = Calendar.current.startOfDay(for: selectedDate)
        return entries.first { $0.metricID == metric.id && Calendar.current.isDate($0.date, inSameDayAs: start) }
    }

    private var quantitySummary: String {
        guard let quantity, quantity > 0 else { return "Not set" }
        return "\(quantity) \(unit)"
    }

    private var statusLabel: String {
        metric.habitType == .positive ? "Did it" : "Avoided it"
    }

    private var isViceSlip: Bool {
        guard metric.habitType == .vice else { return false }
        return !TrackingSemantics.toggleIsOn(habitType: .vice, value: value)
    }

    private var slipMotivationReminder: String? {
        guard isViceSlip else { return nil }
        let trimmed = metric.primaryMotivation?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: statusToggleBinding) {
                        Text(statusLabel)
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.loggingStatusToggle)
                } header: {
                    Text("Status")
                } footer: {
                    Text(metric.habitType == .positive
                         ? "Turn on when you completed this habit today."
                         : "Turn on when you successfully avoided this vice today.")
                }

                Section(header: Text("Notes")) {
                    TextField("Optional notes for this day", text: $details, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let reminder = slipMotivationReminder {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Remember why", systemImage: "heart.text.square.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.currentPrimary)
                            Text(reminder)
                                .font(.body)
                                .foregroundStyle(Color.currentText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 4)
                    } footer: {
                        Text("Your motivation for this vice — read it before you close.")
                    }
                }

                if ProductSurface.showsExtendedLogging {
                    extendedLoggingSections
                } else if showsMoreOptions {
                    extendedLoggingSections
                } else {
                    Section {
                        Button("More options") {
                            withAnimation { showsMoreOptions = true }
                        }
                        .foregroundStyle(Color.currentPrimary)
                    } footer: {
                        Text("Add mood, motivation, or quantity if you want extra context.")
                    }
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
                    Button("Save") { saveAndClose() }
                        .accessibilityIdentifier(AccessibilityIdentifiers.loggingSaveButton)
                }
            }
            .onAppear { seedDefaults() }
            .sheet(isPresented: $showingQuantitySheet, onDismiss: syncQuantityFromStore) {
                QuantityInputSheet(metric: metric, selectedDate: selectedDate)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var extendedLoggingSections: some View {
        Section {
            MoodChipPicker(selectedMood: $mood)
        } header: {
            Text("How are you feeling?")
        } footer: {
            Text("Optional — tap an emoji to log your mood for the day.")
        }

        Section(header: Text("Motivation")) {
            TextField("Why does this matter today?", text: $motivation, axis: .vertical)
                .lineLimit(2...4)
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
            mood = entry.mood
            quantity = entry.quantity
            unit = entry.unit ?? (metric.quantityGoals.first?.safeDefaultUnit ?? "times")
            showsMoreOptions = ProductSurface.showsExtendedLogging
                || !(motivation.isEmpty && (mood ?? "").isEmpty && quantity == nil)
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
        showsMoreOptions = true
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
        entry.mood = mood

        if let quantity, quantity > 0 {
            entry.quantity = quantity
            entry.unit = unit.isEmpty ? nil : unit
        } else {
            entry.quantity = nil
            entry.unit = nil
        }

        if TrackingSemantics.shouldMarkLoggedOnSave(
            habitType: metric.habitType,
            value: value,
            details: details,
            mood: mood ?? "",
            quantity: quantity,
            existingEntry: existingEntry
        ) {
            MetricEntry.markLogged(entry: entry, metric: metric)
        }

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        modelContext.saveChanges(operation: "save log entry", entity: "MetricEntry")
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
