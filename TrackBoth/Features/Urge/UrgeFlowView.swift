import SwiftData
import SwiftUI

struct UrgeFlowView: View {
    var metrics: [Metric]
    var preferredID: UUID?
    var onClose: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: UrgeViewModel?
    @State private var showSlip = false
    @State private var askClose = false
    @State private var reasonIndex = 0

    var body: some View {
        NavigationStack {
            ReadableColumn {
                ScrollView {
                    Group {
                        if let model {
                            content(model)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.vertical, Spacing.l)
                }
            }
            .background(Color.tbCalm)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(RecoveryCopy.close) {
                        if model?.step == .ride {
                            askClose = true
                        } else {
                            onClose()
                        }
                    }
                    .foregroundStyle(Color.tbOnCalm)
                }
            }
            .confirmationDialog(RecoveryCopy.howDidItGo, isPresented: $askClose, titleVisibility: .visible) {
                Button(RecoveryCopy.theUrgePassed) { try? model?.passed(now: Date()) }
                Button(RecoveryCopy.iSlipped) { showSlip = true }
                Button(RecoveryCopy.notSure) { try? model?.markNotSure(now: Date()); onClose() }
                Button(RecoveryCopy.close, role: .cancel) {}
            }
            .sheet(isPresented: $showSlip) {
                if let metric = selectedMetric {
                    SlipFlowView(metric: metric, prefilledTriggers: Array(model?.triggers ?? [])) {
                        try? model?.markSlipped(now: Date())
                        showSlip = false
                        onClose()
                    }
                }
            }
        }
        .onAppear { prepare() }
    }

    @ViewBuilder
    private func content(_ model: UrgeViewModel) -> some View {
        switch model.step {
        case .empty:
            Text(RecoveryCopy.noViceForUrge)
                .font(.title2)
                .foregroundStyle(Color.tbOnCalm)
        case .choose:
            Text(RecoveryCopy.whichOne)
                .font(.title2)
                .foregroundStyle(Color.tbOnCalm)
            ForEach(model.vices) { metric in
                Button(metric.name) { model.choose(metric.id) }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .foregroundStyle(Color.tbOnCalm)
            }
        case .intensity:
            Text(RecoveryCopy.howStrong)
                .font(.title2)
                .foregroundStyle(Color.tbOnCalm)
            ForEach(1...5, id: \.self) { level in
                Button(RecoveryCopy.intensityLabel(level)) {
                    model.intensity = level
                    try? model.begin(metrics: metrics, now: Date())
                }
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(model.intensity == level ? Color.tbOnCalm.opacity(0.2) : Color.clear, in: RoundedRectangle(cornerRadius: Radius.control))
                .foregroundStyle(Color.tbOnCalm)
                .accessibilityIdentifier(AccessibilityIdentifiers.urgeIntensity(level))
            }
            Button(RecoveryCopy.skip) {
                model.intensity = 3
                try? model.begin(metrics: metrics, now: Date())
            }
            .frame(minHeight: 44)
            .foregroundStyle(Color.tbOnCalm)
        case .ride:
            ride(model)
        case .passed:
            passed(model)
        case .unsure:
            EmptyView()
        }
    }

    private func ride(_ model: UrgeViewModel) -> some View {
        ViewThatFits(in: .vertical) {
            VStack(spacing: Spacing.l) { rideBody(model) }
            HStack(alignment: .top, spacing: Spacing.l) { rideBody(model) }
        }
    }

    @ViewBuilder
    private func rideBody(_ model: UrgeViewModel) -> some View {
        Text(RecoveryCopy.urgeIntro)
            .font(.body)
            .foregroundStyle(Color.tbOnCalm)
            .multilineTextAlignment(.center)
        BreathingCircle()
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = model.remaining(at: context.date)
            VStack(spacing: Spacing.s) {
                Text(clock(remaining))
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(Color.tbOnCalm)
                if remaining == 0 {
                    Text(RecoveryCopy.stillWithIt)
                        .font(.body)
                        .foregroundStyle(Color.tbOnCalm)
                        .multilineTextAlignment(.center)
                }
            }
        }
        Button(RecoveryCopy.addFiveMinutes) { model.addFiveMinutes(now: Date()) }
            .frame(minHeight: 44)
            .foregroundStyle(Color.tbOnCalm)
        if let plan = selectedMetric?.ifThenPlan, !plan.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(RecoveryCopy.yourPlanPrefix).font(.headline)
                Text(plan).font(.body)
            }
            .foregroundStyle(Color.tbOnCalm)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        reasons
        habitChips
        PrimaryButton(title: RecoveryCopy.theUrgePassed, systemImage: nil, accessibilityID: AccessibilityIdentifiers.urgePassed) {
            try? model.passed(now: Date())
        }
        Button(RecoveryCopy.iSlipped) { showSlip = true }
            .frame(minHeight: 44)
            .foregroundStyle(Color.tbOnCalm)
            .accessibilityIdentifier(AccessibilityIdentifiers.urgeSlipped)
    }

    private func passed(_ model: UrgeViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            Text(RecoveryCopy.urgePassed(model.beaten))
                .font(.title2)
                .foregroundStyle(Color.tbOnCalm)
            Text(RecoveryCopy.whatSetItOff)
                .font(.headline)
                .foregroundStyle(Color.tbOnCalm)
            triggerGrid
            PrimaryButton(title: RecoveryCopy.done, systemImage: nil, accessibilityID: AccessibilityIdentifiers.urgeDone, action: onClose)
        }
    }

    private var reasons: some View {
        let items = selectedReasons
        return VStack(alignment: .leading, spacing: Spacing.s) {
            if !items.isEmpty {
                Text(RecoveryCopy.yourWhy)
                    .font(.headline)
                    .foregroundStyle(Color.tbOnCalm)
                if reduceMotion {
                    ForEach(items, id: \.self) { text in
                        Text(text).foregroundStyle(Color.tbOnCalm)
                    }
                } else if reasonIndex < items.count {
                    Text(items[reasonIndex])
                        .font(.title2)
                        .foregroundStyle(Color.tbOnCalm)
                        .task(id: items.count) {
                            while !Task.isCancelled {
                                try? await Task.sleep(for: .seconds(8))
                                reasonIndex = (reasonIndex + 1) % max(items.count, 1)
                            }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var habitChips: some View {
        let habits = metrics.filter { $0.habitType == .positive && !$0.isArchived }
        if !habits.isEmpty {
            Text(RecoveryCopy.tryOneInstead)
                .font(.headline)
                .foregroundStyle(Color.tbOnCalm)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(habits) { habit in
                Button(habit.name) {
                    try? RecoveryStore(context: modelContext).setHabitDone(habit, on: Date(), done: true, now: Date())
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(Color.tbOnCalm)
            }
        }
    }

    private var triggerGrid: some View {
        let binding = Binding<Set<String>>(
            get: { Set((model?.triggers ?? []).map(\.rawValue)) },
            set: { raw in model?.triggers = Set(raw.compactMap(TriggerTag.init(rawValue:))) }
        )
        return ChipGrid(
            items: TriggerTag.allCases.map { ChipOption(id: $0.rawValue, title: $0.title, systemImage: $0.systemImage) },
            selection: binding
        )
    }

    private var selectedMetric: Metric? {
        metrics.first { $0.id == model?.selectedID }
    }

    private var selectedReasons: [String] {
        guard let id = model?.selectedID else { return [] }
        let store = RecoveryStore(context: modelContext)
        return (try? store.reasons(for: id).sorted { $0.sortOrder < $1.sortOrder }.map(\.text)) ?? []
    }

    private func prepare() {
        if model == nil {
            model = UrgeViewModel(store: RecoveryStore(context: modelContext))
        }
        model?.start(metrics: metrics, preferredID: preferredID, now: Date())
    }

    private func clock(_ remaining: TimeInterval) -> String {
        let total = Int(remaining)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
