import Foundation
import Observation

struct ViceCardModel: Identifiable, Equatable {
    var id: UUID
    var name: String
    var iconName: String
    var daysFree: Int
    var savedText: String?
    var week: [DayVisualState]
    var weekLabels: [String]
    var nextMilestone: String?
    var history: ViceHistory

    func clockLine(at now: Date, calendar: Calendar) -> String {
        let clock = RecoveryCopy.clock(RecoveryMath.currentRunClock(history, now: now, calendar: calendar))
        if let savedText { return "\(clock) · \(savedText)" }
        return clock
    }

    var accessibilityLabel: String {
        var parts = [name, RecoveryCopy.daysFree(daysFree)]
        if let savedText { parts.append(savedText) }
        return parts.joined(separator: ", ")
    }
}

struct HabitRowModel: Identifiable, Equatable {
    var id: UUID
    var name: String
    var iconName: String
    var run: Int
    var isDoneToday: Bool
    var isAtRisk: Bool
}

struct YesterdayPromptModel: Equatable {
    var metricID: UUID
    var name: String
}

@MainActor
@Observable
final class TodayViewModel {
    var calendar: Calendar
    var locale: Locale
    private(set) var vices: [ViceCardModel] = []
    private(set) var habits: [HabitRowModel] = []
    private(set) var checkInRemaining = 0
    private(set) var yesterdayPrompt: YesterdayPromptModel?

    init(calendar: Calendar = .current, locale: Locale = .current) {
        self.calendar = calendar
        self.locale = locale
    }

    var showsSOS: Bool { !vices.isEmpty }
    var isEmpty: Bool { vices.isEmpty && habits.isEmpty }

    func update(metrics: [Metric], entries: [MetricEntry], now: Date, dismissedYesterday: Date?) {
        let active = metrics
            .filter { !$0.isArchived }
            .sorted { $0.sortOrder < $1.sortOrder }
        let today = calendar.startOfDay(for: now)
        let weekStart = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        let weekDays = DayMath.days(from: weekStart, through: today, calendar: calendar)

        vices = active.filter { $0.habitType == .vice }.map { metric in
            let history = Snapshots.viceHistory(for: metric, entries: entries, calendar: calendar)
            let daysFree = RecoveryMath.currentRunDays(history, now: now, calendar: calendar)
            let saved = RecoveryMath.moneySaved(
                totalFreeDays: RecoveryMath.totalFreeDays(history, now: now, calendar: calendar),
                costPerDay: metric.costPerDay
            )
            let next = MilestonePolicy.next(after: daysFree, isVice: true)
            return ViceCardModel(
                id: metric.id,
                name: metric.name,
                iconName: metric.iconName,
                daysFree: daysFree,
                savedText: saved.map { RecoveryCopy.saved($0, locale: locale) },
                week: weekDays.map { DayVisualState(dayState: RecoveryMath.state(of: $0, in: history, now: now, calendar: calendar)) },
                weekLabels: weekDays.map { weekdayName($0) },
                nextMilestone: RecoveryCopy.nextMilestone(next, inDays: next - daysFree),
                history: history
            )
        }

        habits = active.filter { $0.habitType == .positive }.map { metric in
            let history = Snapshots.habitHistory(for: metric, entries: entries, calendar: calendar)
            return HabitRowModel(
                id: metric.id,
                name: metric.name,
                iconName: metric.iconName,
                run: HabitMath.currentRun(history, now: now, calendar: calendar),
                isDoneToday: history.doneDays.contains(today),
                isAtRisk: HabitMath.isAtRisk(history, now: now, calendar: calendar)
            )
        }

        checkInRemaining = active.filter { metric in
            guard metric.habitType == .vice else { return false }
            let history = Snapshots.viceHistory(for: metric, entries: entries, calendar: calendar)
            return RecoveryMath.state(of: today, in: history, now: now, calendar: calendar) == .todayPending
        }.count

        yesterdayPrompt = makeYesterdayPrompt(vices: active.filter { $0.habitType == .vice }, entries: entries, now: now, dismissedYesterday: dismissedYesterday)
    }

    private func makeYesterdayPrompt(vices: [Metric], entries: [MetricEntry], now: Date, dismissedYesterday: Date?) -> YesterdayPromptModel? {
        guard calendar.component(.hour, from: now) < 12,
              let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now)) else { return nil }
        if let dismissedYesterday, calendar.isDate(dismissedYesterday, inSameDayAs: yesterday) { return nil }
        for metric in vices {
            let history = Snapshots.viceHistory(for: metric, entries: entries, calendar: calendar)
            if RecoveryMath.state(of: yesterday, in: history, now: now, calendar: calendar) == .presumedFree {
                return YesterdayPromptModel(metricID: metric.id, name: metric.name)
            }
        }
        return nil
    }

    private func weekdayName(_ day: Date) -> String {
        let index = calendar.component(.weekday, from: day) - 1
        let symbols = calendar.weekdaySymbols
        guard symbols.indices.contains(index) else { return "" }
        return symbols[index]
    }
}
