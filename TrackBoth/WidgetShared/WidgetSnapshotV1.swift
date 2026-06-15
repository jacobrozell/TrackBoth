import Foundation

// MARK: - WidgetSnapshotV1
struct WidgetSnapshotV1: Codable, Equatable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let generatedAt: Date
    var today: WidgetTodaySummary
    var metrics: [WidgetMetricSnapshot]

    static var empty: WidgetSnapshotV1 {
        WidgetSnapshotV1(
            schemaVersion: currentSchemaVersion,
            generatedAt: Date(),
            today: .empty,
            metrics: []
        )
    }

    static var placeholder: WidgetSnapshotV1 {
        let metrics = [
            WidgetMetricSnapshot.placeholder(
                id: "1",
                name: "Exercise",
                habitType: "positive",
                streak: 12,
                logged: true,
                goal: WidgetGoalSnapshot(period: "monthly", progress: 0.6, current: 18, target: 30, unit: "days")
            ),
            WidgetMetricSnapshot.placeholder(
                id: "2",
                name: "Smoking",
                habitType: "vice",
                streak: 21,
                logged: true,
                savings: "$252 saved",
                primaryMotivation: "Breathe easier. Save for travel."
            ),
            WidgetMetricSnapshot.placeholder(
                id: "3",
                name: "Social media",
                habitType: "vice",
                streak: 14,
                logged: true,
                recovery: "14d recovering"
            )
        ]
        return WidgetSnapshotV1(
            schemaVersion: currentSchemaVersion,
            generatedAt: Date(),
            today: WidgetTodaySummary(
                date: WidgetDateCodec.dayString(from: Date()),
                completedCount: 2,
                totalCount: 3,
                habitsCompleted: 1,
                habitsTotal: 2,
                vicesAvoided: 1,
                vicesTotal: 1
            ),
            metrics: metrics
        )
    }

    func metric(id: String) -> WidgetMetricSnapshot? {
        metrics.first { $0.id == id }
    }

    func habits() -> [WidgetMetricSnapshot] {
        metrics.filter { $0.habitType == HabitTypeSnapshot.positive }
    }

    func vices() -> [WidgetMetricSnapshot] {
        metrics.filter { $0.habitType == HabitTypeSnapshot.vice }
    }

    func unloggedMetrics(limit: Int = 4) -> [WidgetMetricSnapshot] {
        Array(metrics.filter { !$0.today.isLogged }.prefix(limit))
    }

    mutating func applyQuickToggle(metricID: String) -> Bool? {
        guard let index = metrics.firstIndex(where: { $0.id == metricID }) else { return nil }
        let metric = metrics[index]
        let newValue = WidgetToggleSemantics.nextStoredValue(
            habitType: metric.habitType,
            today: metric.today
        )
        var updatedMetrics = metrics
        updatedMetrics[index] = metric.updatingToday(
            isLogged: true,
            storedValue: newValue
        )
        today = WidgetTodaySummary.recalculated(from: updatedMetrics)
        metrics = updatedMetrics
        return newValue
    }

    mutating func applyLog(metricID: String, success: Bool) -> Bool? {
        guard let index = metrics.firstIndex(where: { $0.id == metricID }) else { return nil }
        let metric = metrics[index]
        let storedValue = success
            ? WidgetToggleSemantics.successStoredValue(habitType: metric.habitType)
            : WidgetToggleSemantics.failureStoredValue(habitType: metric.habitType)
        var updatedMetrics = metrics
        updatedMetrics[index] = metric.updatingToday(isLogged: true, storedValue: storedValue)
        today = WidgetTodaySummary.recalculated(from: updatedMetrics)
        metrics = updatedMetrics
        return storedValue
    }
}

struct WidgetTodaySummary: Codable, Equatable {
    let date: String
    let completedCount: Int
    let totalCount: Int
    let habitsCompleted: Int
    let habitsTotal: Int
    let vicesAvoided: Int
    let vicesTotal: Int

    static var empty: WidgetTodaySummary {
        WidgetTodaySummary(
            date: WidgetDateCodec.dayString(from: Date()),
            completedCount: 0,
            totalCount: 0,
            habitsCompleted: 0,
            habitsTotal: 0,
            vicesAvoided: 0,
            vicesTotal: 0
        )
    }

    static func recalculated(from metrics: [WidgetMetricSnapshot]) -> WidgetTodaySummary {
        let habits = metrics.filter { $0.habitType == HabitTypeSnapshot.positive }
        let vices = metrics.filter { $0.habitType == HabitTypeSnapshot.vice }
        let habitsCompleted = habits.filter(\.today.isSuccess).count
        let vicesAvoided = vices.filter(\.today.isSuccess).count
        let completed = habitsCompleted + vicesAvoided
        return WidgetTodaySummary(
            date: WidgetDateCodec.dayString(from: Date()),
            completedCount: completed,
            totalCount: metrics.count,
            habitsCompleted: habitsCompleted,
            habitsTotal: habits.count,
            vicesAvoided: vicesAvoided,
            vicesTotal: vices.count
        )
    }
}

struct WidgetMetricSnapshot: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let habitType: String
    let sortOrder: Int
    let primaryMotivation: String?
    let showRecoveryTimer: Bool
    let today: WidgetTodayEntry
    let streak: WidgetStreakSnapshot
    let recovery: WidgetRecoverySnapshot?
    let savings: WidgetSavingsSnapshot?
    let goal: WidgetGoalSnapshot?
    let week: [Bool?]

    static func placeholder(
        id: String,
        name: String,
        habitType: String,
        streak: Int,
        logged: Bool,
        recovery: String? = nil,
        savings: String? = nil,
        goal: WidgetGoalSnapshot? = nil,
        primaryMotivation: String? = nil
    ) -> WidgetMetricSnapshot {
        let isPositive = habitType == HabitTypeSnapshot.positive
        let isSuccess = logged
        let storedValue = isPositive ? isSuccess : !isSuccess
        return WidgetMetricSnapshot(
            id: id,
            name: name,
            habitType: habitType,
            sortOrder: 0,
            primaryMotivation: primaryMotivation,
            showRecoveryTimer: recovery != nil,
            today: WidgetTodayEntry(isLogged: logged, storedValue: storedValue, habitType: habitType),
            streak: WidgetStreakSnapshot(current: streak, longest: streak),
            recovery: recovery.map { WidgetRecoverySnapshot(label: $0, compactLabel: $0, lastSlipDate: nil) },
            savings: savings.map { WidgetSavingsSnapshot(label: $0) },
            goal: goal,
            week: Array(repeating: true, count: 7)
        )
    }

    func updatingToday(isLogged: Bool, storedValue: Bool) -> WidgetMetricSnapshot {
        WidgetMetricSnapshot(
            id: id,
            name: name,
            habitType: habitType,
            sortOrder: sortOrder,
            primaryMotivation: primaryMotivation,
            showRecoveryTimer: showRecoveryTimer,
            today: WidgetTodayEntry(isLogged: isLogged, storedValue: storedValue, habitType: habitType),
            streak: streak,
            recovery: recovery,
            savings: savings,
            goal: goal,
            week: week
        )
    }
}

extension WidgetSnapshotV1 {
    func metricsWithGoals() -> [WidgetMetricSnapshot] {
        metrics.filter { $0.goal != nil }
    }

    func vicesWithSavings() -> [WidgetMetricSnapshot] {
        vices().filter { $0.savings != nil }
    }

    func metricsWithMotivation() -> [WidgetMetricSnapshot] {
        metrics.filter { !($0.primaryMotivation ?? "").isEmpty }
    }
}

struct WidgetGoalSnapshot: Codable, Equatable {
    let period: String
    let progress: Double
    let current: Int
    let target: Int
    let unit: String

    var progressLabel: String {
        "\(current)/\(target) \(unit)"
    }
}

struct WidgetTodayEntry: Codable, Equatable {
    let isLogged: Bool
    let isSuccess: Bool
    let value: Bool?

    init(isLogged: Bool, storedValue: Bool, habitType: String) {
        self.isLogged = isLogged
        self.value = isLogged ? storedValue : nil
        self.isSuccess = isLogged && WidgetToggleSemantics.isSuccess(habitType: habitType, storedValue: storedValue)
    }
}

struct WidgetStreakSnapshot: Codable, Equatable {
    let current: Int
    let longest: Int
}

struct WidgetRecoverySnapshot: Codable, Equatable {
    let label: String
    let compactLabel: String
    let lastSlipDate: String?
}

struct WidgetSavingsSnapshot: Codable, Equatable {
    let label: String
}

enum HabitTypeSnapshot {
    static let positive = "positive"
    static let vice = "vice"
}

enum WidgetDateCodec {
    static func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = Calendar.current.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

enum WidgetToggleSemantics {
    static func isSuccess(habitType: String, storedValue: Bool) -> Bool {
        habitType == HabitTypeSnapshot.positive ? storedValue : !storedValue
    }

    static func successStoredValue(habitType: String) -> Bool {
        habitType == HabitTypeSnapshot.positive
    }

    static func failureStoredValue(habitType: String) -> Bool {
        !successStoredValue(habitType: habitType)
    }

    static func nextStoredValue(habitType: String, today: WidgetTodayEntry) -> Bool {
        if today.isLogged, let value = today.value {
            return isSuccess(habitType: habitType, storedValue: value)
                ? failureStoredValue(habitType: habitType)
                : successStoredValue(habitType: habitType)
        }
        return successStoredValue(habitType: habitType)
    }
}
