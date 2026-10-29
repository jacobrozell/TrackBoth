import SwiftData
import SwiftUI

struct TodayScreen: View {
    @Query(filter: #Predicate<Metric> { !$0.isArchived }, sort: \Metric.sortOrder)
    private var metrics: [Metric]
    @Query private var entries: [MetricEntry]

    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @State private var model = TodayViewModel()
    @State private var sheet: TodaySheet?
    @State private var dismissedYesterday = Preferences.dismissedYesterdayPromptDay

    var body: some View {
        NavigationStack {
            ScrollView {
                ReadableColumn {
                    VStack(alignment: .leading, spacing: Spacing.m) {
                        if let prompt = model.yesterdayPrompt {
                            YesterdayPrompt(name: prompt.name) {
                                confirmYesterday(prompt.metricID)
                            } onSlipped: {
                                sheet = .slip(prompt.metricID)
                            } onDismiss: {
                                dismissYesterday()
                            }
                        }
                        if model.checkInRemaining > 0 {
                            CheckInBanner(remaining: model.checkInRemaining) { router.present(.checkIn) }
                        }
                        if model.isEmpty {
                            EmptyState(
                                systemImage: "sun.max",
                                title: RecoveryCopy.startWithOneThing,
                                message: RecoveryCopy.startWithOneThingMessage,
                                actionTitle: RecoveryCopy.addSomething
                            ) { sheet = .add }
                        }
                        if !model.vices.isEmpty {
                            SectionHeader(RecoveryCopy.quitting)
                            ForEach(model.vices) { card in
                                ViceCard(model: card, calendar: model.calendar) { sheet = .detail(card.id) }
                            }
                        }
                        if !model.habits.isEmpty {
                            SectionHeader(RecoveryCopy.building)
                            ForEach(model.habits) { row in
                                HabitCheckRow(model: row, onToggle: { toggleHabit(row.id) }, onOpen: { sheet = .detail(row.id) })
                            }
                        }
                    }
                    .padding(.vertical, Spacing.m)
                }
            }
            .background(Color.tbBackground)
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text(Date().formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                        .font(.subheadline)
                        .foregroundStyle(Color.tbTextSecondary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if model.showsSOS {
                    SOSButton {
                        router.present(.urge(nil))
                    }
                }
            }
        }
        .onAppear { refresh() }
        .onChange(of: snapshotToken) { refresh() }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .slip(let id):
                if let metric = metrics.first(where: { $0.id == id }) {
                    SlipFlowView(metric: metric, prefilledTriggers: []) { self.sheet = nil }
                }
            case .add:
                FlowStub(title: RecoveryCopy.addSomething, message: RecoveryCopy.addStub) { self.sheet = nil }
            case .detail(let id):
                FlowStub(title: metrics.first { $0.id == id }?.name ?? "", message: RecoveryCopy.detailStub) { self.sheet = nil }
            }
        }
    }

    private var snapshotToken: String {
        let metricPart = metrics.map { "\($0.id.uuidString):\($0.sortOrder):\($0.name):\($0.costPerDayRaw ?? "")" }.joined(separator: "|")
        let entryPart = entries.map { "\($0.metricID.uuidString):\($0.statusRaw):\($0.day.timeIntervalSinceReferenceDate)" }.joined(separator: "|")
        return metricPart + "#" + entryPart + "#\(dismissedYesterday?.timeIntervalSinceReferenceDate ?? 0)"
    }

    private func refresh() {
        model.update(metrics: metrics, entries: entries, now: Date(), dismissedYesterday: dismissedYesterday)
    }

    private func toggleHabit(_ id: UUID) {
        guard let metric = metrics.first(where: { $0.id == id }) else { return }
        let store = RecoveryStore(context: modelContext)
        let done = model.habits.first { $0.id == id }?.isDoneToday == false
        try? store.setHabitDone(metric, on: Date(), done: done, now: Date())
    }

    private func confirmYesterday(_ id: UUID) {
        guard let metric = metrics.first(where: { $0.id == id }),
              let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
        let store = RecoveryStore(context: modelContext)
        try? store.markFree(metric, on: yesterday, now: Date())
    }

    private func dismissYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        Preferences.dismissedYesterdayPromptDay = yesterday
        dismissedYesterday = yesterday
        refresh()
    }
}

private enum TodaySheet: Identifiable {
    case slip(UUID)
    case add
    case detail(UUID)

    var id: String {
        switch self {
        case .slip(let id): "slip-\(id.uuidString)"
        case .add: "add"
        case .detail(let id): id.uuidString
        }
    }
}
