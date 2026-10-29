import Foundation
import Observation
import SwiftData

enum CheckInAnswer: Equatable {
    case unanswered, free, slipped
}

struct CheckInViceRow: Identifiable, Equatable {
    var id: UUID
    var name: String
    var answer: CheckInAnswer
}

struct CheckInHabitRow: Identifiable, Equatable {
    var id: UUID
    var name: String
    var isDone: Bool
}

struct CheckInSummaryLine: Identifiable, Equatable {
    var id: UUID
    var name: String
    var detail: String
    var milestone: String?
}

@MainActor
@Observable
final class CheckInViewModel {
    private let store: RecoveryStore
    private(set) var vices: [CheckInViceRow] = []
    private(set) var habits: [CheckInHabitRow] = []
    private(set) var lines: [CheckInSummaryLine] = []
    var showComplete = false

    var calendar: Calendar { store.calendar }
    var canFinish: Bool { vices.allSatisfy { $0.answer != .unanswered } }

    init(store: RecoveryStore) {
        self.store = store
    }

    func load(metrics: [Metric], entries: [MetricEntry], now: Date) {
        let active = metrics.filter { !$0.isArchived }.sorted { $0.sortOrder < $1.sortOrder }
        let today = calendar.startOfDay(for: now)
        vices = active.filter { $0.habitType == .vice }.map { metric in
            let history = Snapshots.viceHistory(for: metric, entries: entries, calendar: calendar)
            let answer: CheckInAnswer
            switch RecoveryMath.state(of: today, in: history, now: now, calendar: calendar) {
            case .confirmedFree: answer = .free
            case .slipped: answer = .slipped
            default: answer = .unanswered
            }
            return CheckInViceRow(id: metric.id, name: metric.name, answer: answer)
        }
        habits = active.filter { $0.habitType == .positive }.map { metric in
            let history = Snapshots.habitHistory(for: metric, entries: entries, calendar: calendar)
            return CheckInHabitRow(id: metric.id, name: metric.name, isDone: history.doneDays.contains(today))
        }
    }

    func markFree(_ id: UUID, metrics: [Metric], now: Date) throws {
        guard let metric = metrics.first(where: { $0.id == id }) else { return }
        try store.markFree(metric, on: now, now: now)
        setVice(id, answer: .free)
    }

    func toggleHabit(_ id: UUID, metrics: [Metric], now: Date) throws {
        guard let metric = metrics.first(where: { $0.id == id }),
              let row = habits.first(where: { $0.id == id }) else { return }
        try store.setHabitDone(metric, on: now, done: !row.isDone, now: now)
        if let index = habits.firstIndex(where: { $0.id == id }) {
            habits[index].isDone.toggle()
        }
    }

    func finish(metrics: [Metric], now: Date, locale: Locale = .current, celebrated: [UUID: Int]) throws {
        guard canFinish else { return }
        let entries = try store.context.fetch(FetchDescriptor<MetricEntry>())
        lines = metrics.filter { $0.habitType == .vice && !$0.isArchived }.sorted { $0.sortOrder < $1.sortOrder }.map { metric in
            let history = Snapshots.viceHistory(for: metric, entries: entries, calendar: calendar)
            let days = RecoveryMath.currentRunDays(history, now: now, calendar: calendar)
            let saved = RecoveryMath.moneySaved(
                totalFreeDays: RecoveryMath.totalFreeDays(history, now: now, calendar: calendar),
                costPerDay: metric.costPerDay
            ).map { RecoveryCopy.saved($0, locale: locale) }
            let highest = celebrated[metric.id] ?? 0
            let milestone = MilestonePolicy.pending(value: days, isVice: true, highestCelebrated: highest)
                .map { RecoveryCopy.milestoneVice($0, name: metric.name) }
            return CheckInSummaryLine(
                id: metric.id,
                name: metric.name,
                detail: RecoveryCopy.checkInSummary(days: days, saved: saved),
                milestone: milestone
            )
        }
        showComplete = true
    }

    private func setVice(_ id: UUID, answer: CheckInAnswer) {
        guard let index = vices.firstIndex(where: { $0.id == id }) else { return }
        vices[index].answer = answer
    }
}
