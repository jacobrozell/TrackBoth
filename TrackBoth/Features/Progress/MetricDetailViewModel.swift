import Foundation
import Observation

struct DetailStats: Equatable {
    var primary: String
    var tiles: [(String, String)]
    var plan: String
    var urgeLine: String?
    var triggers: [(String, Int)]
    var hardest: String?
    var month: Date

    static func == (lhs: DetailStats, rhs: DetailStats) -> Bool {
        lhs.primary == rhs.primary && lhs.plan == rhs.plan && lhs.urgeLine == rhs.urgeLine && lhs.hardest == rhs.hardest && lhs.month == rhs.month
            && lhs.tiles.map(\.0) == rhs.tiles.map(\.0) && lhs.tiles.map(\.1) == rhs.tiles.map(\.1)
            && lhs.triggers.map(\.0) == rhs.triggers.map(\.0) && lhs.triggers.map(\.1) == rhs.triggers.map(\.1)
    }
}

@MainActor
@Observable
final class MetricDetailViewModel {
    var calendar: Calendar
    var locale: Locale
    private(set) var stats = DetailStats(primary: "", tiles: [], plan: "", urgeLine: nil, triggers: [], hardest: nil, month: Date())
    var month: Date

    init(calendar: Calendar = .current, locale: Locale = .current, now: Date = Date()) {
        self.calendar = calendar
        self.locale = locale
        self.month = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
    }

    func update(metric: Metric, entries: [MetricEntry], urges: [UrgeEvent], now: Date) {
        if metric.habitType == .vice {
            let history = Snapshots.viceHistory(for: metric, entries: entries, calendar: calendar)
            let days = RecoveryMath.currentRunDays(history, now: now, calendar: calendar)
            let window = RecoveryMath.freeDays(inLast: 30, history, now: now, calendar: calendar)
            let saved = RecoveryMath.moneySaved(totalFreeDays: RecoveryMath.totalFreeDays(history, now: now, calendar: calendar), costPerDay: metric.costPerDay)
            stats = DetailStats(
                primary: RecoveryCopy.daysFree(days),
                tiles: [
                    (RecoveryCopy.currentRun, "\(days)"),
                    (RecoveryCopy.longestRun, "\(RecoveryMath.longestRunDays(history, now: now, calendar: calendar))"),
                    (RecoveryCopy.freeLast30, "\(window.free)/\(window.counted)"),
                    (RecoveryCopy.savedStat, saved.map { RecoveryCopy.money($0, locale: locale) } ?? "—")
                ],
                plan: metric.ifThenPlan ?? "",
                urgeLine: urgeLine(urges.filter { $0.metricID == metric.id }),
                triggers: patternTriggers(metric: metric, entries: entries, urges: urges),
                hardest: hardest(metric: metric, entries: entries, urges: urges),
                month: month
            )
        } else {
            let history = Snapshots.habitHistory(for: metric, entries: entries, calendar: calendar)
            let run = HabitMath.currentRun(history, now: now, calendar: calendar)
            stats = DetailStats(
                primary: RecoveryCopy.habitRun(run),
                tiles: [
                    (RecoveryCopy.currentRun, "\(run)"),
                    (RecoveryCopy.bestRun, "\(HabitMath.bestRun(history, now: now, calendar: calendar))"),
                    (RecoveryCopy.doneLast30, "\(HabitMath.doneCount(inLast: 30, history, now: now, calendar: calendar))"),
                    (RecoveryCopy.doneAllTime, "\(history.doneDays.count)")
                ],
                plan: "",
                urgeLine: nil,
                triggers: [],
                hardest: nil,
                month: month
            )
        }
    }

    func state(for day: Date, metric: Metric, entries: [MetricEntry], now: Date) -> DayVisualState {
        if metric.habitType == .vice {
            let history = Snapshots.viceHistory(for: metric, entries: entries, calendar: calendar)
            return DayVisualState(dayState: RecoveryMath.state(of: day, in: history, now: now, calendar: calendar))
        }
        let key = calendar.startOfDay(for: day)
        let history = Snapshots.habitHistory(for: metric, entries: entries, calendar: calendar)
        let today = calendar.startOfDay(for: now)
        let started = calendar.startOfDay(for: metric.startedAt)
        let active = key >= started && key <= today
        return .habit(isDone: history.doneDays.contains(key), isToday: key == today, isActive: active)
    }

    func canEdit(_ day: Date, metric: Metric, now: Date) -> Bool {
        let key = calendar.startOfDay(for: day)
        let today = calendar.startOfDay(for: now)
        return key >= calendar.startOfDay(for: metric.startedAt) && key <= today
    }

    func shiftMonth(_ delta: Int, metric: Metric, now: Date) {
        guard let next = calendar.date(byAdding: .month, value: delta, to: month) else { return }
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: metric.startedAt)) ?? metric.startedAt
        let current = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        if next < start || next > current { return }
        month = next
    }

    private func urgeLine(_ urges: [UrgeEvent]) -> String {
        let summary = PatternInsights.urgeSummary(urges.map(\.outcome))
        return "\(RecoveryCopy.beatenOf) \(summary.beaten) of \(summary.total)"
    }

    private func patternTriggers(metric: Metric, entries: [MetricEntry], urges: [UrgeEvent]) -> [(String, Int)] {
        let slips = entries.filter { $0.metricID == metric.id && $0.status == .slipped }
        let mine = urges.filter { $0.metricID == metric.id }
        guard slips.count + mine.count >= 3 else { return [] }
        let groups = slips.map(\.triggers) + mine.map(\.triggers)
        return PatternInsights.topTriggers(from: groups).map { ($0.0.title, $0.1) }
    }

    private func hardest(metric: Metric, entries: [MetricEntry], urges: [UrgeEvent]) -> String? {
        let slips = entries.filter { $0.metricID == metric.id && $0.status == .slipped }.map(\.occurredAt)
        let urgesTimes = urges.filter { $0.metricID == metric.id && $0.outcome != .resisted }.map(\.startedAt)
        return PatternInsights.hardestTime(from: slips + urgesTimes, calendar: calendar).map { "\(RecoveryCopy.hardestTime): \($0.title)" }
    }
}
