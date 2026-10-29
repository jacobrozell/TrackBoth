import SwiftData
import SwiftUI

struct MetricDetailScreen: View {
    var metric: Metric

    @Query private var entries: [MetricEntry]
    @Query private var urges: [UrgeEvent]
    @Query private var reasons: [Reason]
    @Environment(\.modelContext) private var modelContext
    @State private var model = MetricDetailViewModel()
    @State private var sheet: DetailSheet?
    @State private var pendingSlip = false
    @State private var planText = ""
    @State private var newReason = ""

    var body: some View {
        ScrollView {
            ReadableColumn {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    header
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: Spacing.m)], spacing: Spacing.m) {
                        ForEach(Array(model.stats.tiles.enumerated()), id: \.offset) { _, tile in
                            StatTile(value: tile.1, label: tile.0, systemImage: "circle")
                        }
                    }
                    calendar
                    if metric.habitType == .vice {
                        reasonsSection
                        planSection
                        if !model.stats.triggers.isEmpty {
                            patterns
                        }
                        if let urgeLine = model.stats.urgeLine {
                            Text(urgeLine).font(.body).foregroundStyle(Color.tbTextPrimary)
                        }
                    }
                }
                .padding(.vertical, Spacing.l)
            }
        }
        .background(Color.tbBackground)
        .navigationTitle(metric.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(RecoveryCopy.edit) { sheet = .form }
            }
        }
        .onAppear { refresh() }
        .onChange(of: entries.count) { refresh() }
        .sheet(item: $sheet, onDismiss: {
            if pendingSlip {
                pendingSlip = false
                sheet = .slip
            }
        }) { sheet in
            switch sheet {
            case .editor(let day):
                DayEditorSheet(metric: metric, day: day) { pendingSlip = true }
            case .slip:
                SlipFlowView(metric: metric, prefilledTriggers: []) { self.sheet = nil }
            case .form:
                MetricFormView(metric: metric)
            }
        }
    }

    private var header: some View {
        HStack(spacing: Spacing.m) {
            IconBadge(systemImage: metric.iconName, tint: metric.habitType == .vice ? .tbBrand : .tbHabit)
            VStack(alignment: .leading) {
                Text(metric.name).font(.title2).foregroundStyle(Color.tbTextPrimary)
                if metric.habitType == .vice {
                    TimelineView(.periodic(from: .now, by: 60)) { context in
                        let history = Snapshots.viceHistory(for: metric, entries: entries, calendar: model.calendar)
                        Text(RecoveryCopy.clock(RecoveryMath.currentRunClock(history, now: context.date, calendar: model.calendar)))
                            .font(.subheadline)
                            .foregroundStyle(Color.tbTextSecondary)
                    }
                }
                Text(model.stats.primary).bigNumberStyle().foregroundStyle(Color.tbTextPrimary)
            }
        }
    }

    private var calendar: some View {
        VStack {
            HStack {
                Button("Previous month") { model.shiftMonth(-1, metric: metric, now: Date()) }
                    .frame(minHeight: 44)
                Spacer()
                Button("Next month") { model.shiftMonth(1, metric: metric, now: Date()) }
                    .frame(minHeight: 44)
            }
            .font(.subheadline)
            .foregroundStyle(Color.tbBrand)
            MonthCalendar(month: model.month, stateFor: { day in
                model.state(for: day, metric: metric, entries: entries, now: Date())
            }, onSelect: { day in
                guard model.canEdit(day, metric: metric, now: Date()) else { return }
                sheet = .editor(day)
            })
        }
    }

    private var reasonsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(RecoveryCopy.yourReasons)
            ForEach(metricReasons) { reason in
                Text(reason.text).font(.body).foregroundStyle(Color.tbTextPrimary)
            }
            TextField(RecoveryCopy.addReason, text: $newReason)
                .textFieldStyle(.roundedBorder)
            Button(RecoveryCopy.addReason) {
                try? RecoveryStore(context: modelContext).addReason(newReason, to: metric)
                newReason = ""
            }
            .frame(minHeight: 44)
        }
    }

    private var planSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(RecoveryCopy.yourPlan)
            TextField(RecoveryCopy.nextTimePlan, text: $planText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            Button(RecoveryCopy.edit) {
                try? RecoveryStore(context: modelContext).setPlan(metric, plan: planText)
            }
            .frame(minHeight: 44)
        }
    }

    private var patterns: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            SectionHeader(RecoveryCopy.patterns)
            ForEach(model.stats.triggers, id: \.0) { trigger in
                Text("\(trigger.0) \(trigger.1)")
                    .font(.body)
                    .foregroundStyle(Color.tbTextPrimary)
            }
            if let hardest = model.stats.hardest {
                Text(hardest).font(.subheadline).foregroundStyle(Color.tbTextSecondary)
            }
        }
    }

    private var metricReasons: [Reason] {
        reasons.filter { $0.metricID == metric.id }.sorted { $0.sortOrder < $1.sortOrder }
    }

    private func refresh() {
        model.update(metric: metric, entries: entries, urges: urges, now: Date())
        if planText.isEmpty { planText = metric.ifThenPlan ?? "" }
    }
}

private enum DetailSheet: Identifiable {
    case editor(Date)
    case slip
    case form

    var id: String {
        switch self {
        case .editor(let day): "editor-\(day.timeIntervalSinceReferenceDate)"
        case .slip: "slip"
        case .form: "form"
        }
    }
}

struct DayEditorSheet: View {
    var metric: Metric
    var day: Date
    var onSlip: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ReadableColumn {
                VStack(spacing: Spacing.m) {
                    if metric.habitType == .vice {
                        Button(RecoveryCopy.free) { markFree() }
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityIdentifier(AccessibilityIdentifiers.dayEditorFree)
                        Button(RecoveryCopy.iSlipped) { onSlip(); dismiss() }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .accessibilityIdentifier(AccessibilityIdentifiers.dayEditorSlipped)
                        Button(RecoveryCopy.clearDay) { clear() }
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityIdentifier(AccessibilityIdentifiers.dayEditorClear)
                    } else {
                        Button(RecoveryCopy.doneLast30) { setDone(true) }
                            .frame(maxWidth: .infinity, minHeight: 44)
                        Button(RecoveryCopy.notDone) { setDone(false) }
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
                .padding(.vertical, Spacing.xl)
            }
            .background(Color.tbBackground)
            .navigationTitle(day.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { Button(RecoveryCopy.close) { dismiss() } }
        }
        .presentationDetents([.medium])
    }

    private func markFree() {
        try? RecoveryStore(context: modelContext).markFree(metric, on: day, now: Date())
        dismiss()
    }

    private func clear() {
        try? RecoveryStore(context: modelContext).clearDay(metric, on: day)
        dismiss()
    }

    private func setDone(_ done: Bool) {
        try? RecoveryStore(context: modelContext).setHabitDone(metric, on: day, done: done, now: Date())
        dismiss()
    }
}
