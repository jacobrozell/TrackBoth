import Foundation
import Observation
import SwiftData

enum UrgeStep: Equatable {
    case choose
    case intensity
    case ride
    case passed
    case unsure
    case empty
}

@MainActor
@Observable
final class UrgeViewModel {
    private let store: RecoveryStore
    private(set) var step: UrgeStep = .choose
    private(set) var vices: [Metric] = []
    var selectedID: UUID?
    var intensity = 3
    var endDate = Date()
    var triggers: Set<TriggerTag> = []
    private(set) var urge: UrgeEvent?
    private(set) var beaten = 0

    init(store: RecoveryStore) {
        self.store = store
    }

    var calendar: Calendar { store.calendar }

    func start(metrics: [Metric], preferredID: UUID?, now: Date) {
        vices = metrics.filter { $0.habitType == .vice && !$0.isArchived }.sorted { $0.sortOrder < $1.sortOrder }
        if vices.isEmpty {
            step = .empty
            return
        }
        if let preferredID, vices.contains(where: { $0.id == preferredID }) {
            selectedID = preferredID
            step = .intensity
        } else if vices.count == 1 {
            selectedID = vices[0].id
            step = .intensity
        } else {
            step = .choose
        }
        endDate = now.addingTimeInterval(5 * 60)
    }

    func choose(_ id: UUID) {
        selectedID = id
        step = .intensity
    }

    func begin(metrics: [Metric], now: Date) throws {
        guard let metric = metrics.first(where: { $0.id == selectedID }) else { return }
        urge = try store.startUrge(for: metric, intensity: intensity, now: now)
        endDate = now.addingTimeInterval(5 * 60)
        step = .ride
    }

    func remaining(at now: Date) -> TimeInterval {
        max(0, endDate.timeIntervalSince(now))
    }

    func addFiveMinutes(now: Date) {
        let base = max(endDate, now)
        endDate = base.addingTimeInterval(5 * 60)
    }

    func passed(now: Date) throws {
        try finish(.resisted, now: now)
        step = .passed
    }

    func markNotSure(now: Date) throws {
        try finish(.unknown, now: now)
        step = .unsure
    }

    func markSlipped(now: Date) throws {
        try finish(.slipped, now: now)
    }

    private func finish(_ outcome: UrgeOutcome, now: Date) throws {
        guard let urge else { return }
        try store.finishUrge(urge, outcome: outcome, triggers: Array(triggers), note: nil, now: now)
        let urges = try store.context.fetch(FetchDescriptor<UrgeEvent>())
        beaten = PatternInsights.urgeSummary(urges.map(\.outcome)).beaten
    }
}
