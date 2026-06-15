import Foundation

// MARK: - Tracking Semantics
/// Single source of truth for habit/vice completion rules.
/// See `specs/TrackingSemanticsSpec.md`.
enum TrackingSemantics {

    // MARK: - Boolean rules

    /// Whether the entry value represents success (habit done / vice avoided).
    static func isSuccessful(habitType: HabitType, value: Bool) -> Bool {
        switch habitType {
        case .positive:
            return value
        case .vice:
            return !value
        }
    }

    /// Stored `value` that represents success for the habit type.
    static func successValue(habitType: HabitType) -> Bool {
        switch habitType {
        case .positive:
            return true
        case .vice:
            return false
        }
    }

    /// Stored `value` that represents failure for the habit type.
    static func failureValue(habitType: HabitType) -> Bool {
        switch habitType {
        case .positive:
            return false
        case .vice:
            return true
        }
    }

    // MARK: - Logged state

    /// Whether the metric has ever been explicitly logged by the user.
    static func streakEligible(metric: Metric) -> Bool {
        metric.hasBeenLogged
    }

    /// Whether an entry represents an explicit log for that day.
    static func isLoggedForDay(entry: MetricEntry?) -> Bool {
        entry?.hasBeenLogged == true
    }

    // MARK: - Completion

    /// Counts toward Home "completed today" stats.
    static func countsTowardTodayCompleted(habitType: HabitType, entry: MetricEntry?) -> Bool {
        guard let entry, isLoggedForDay(entry: entry) else { return false }
        return isSuccessful(habitType: habitType, value: entry.value)
    }

    /// Row/sheet completion for a specific day.
    static func isCompleted(habitType: HabitType, entry: MetricEntry?) -> Bool {
        countsTowardTodayCompleted(habitType: habitType, entry: entry)
    }

    /// Logged entry that counts as success for charts, history, and insights.
    static func isLoggedSuccess(habitType: HabitType, entry: MetricEntry) -> Bool {
        guard isLoggedForDay(entry: entry) else { return false }
        return isSuccessful(habitType: habitType, value: entry.value)
    }

    /// Whether an explicit LoggingSheet save should mark the entry logged.
    static func shouldMarkLoggedOnSave(
        habitType: HabitType,
        value: Bool,
        details: String,
        mood: String = "",
        quantity: Int?,
        existingEntry: MetricEntry?
    ) -> Bool {
        if existingEntry?.hasBeenLogged == true { return true }
        if let quantity, quantity > 0 { return true }
        if !details.isEmpty { return true }
        if !mood.isEmpty { return true }
        return isSuccessful(habitType: habitType, value: value)
    }

    // MARK: - Toggle

    /// Value to persist after the user taps quick-toggle on a row.
    static func valueAfterQuickToggle(habitType: HabitType, existingEntry: MetricEntry?) -> Bool {
        if let entry = existingEntry, isLoggedForDay(entry: entry) {
            return isSuccessful(habitType: habitType, value: entry.value)
                ? failureValue(habitType: habitType)
                : successValue(habitType: habitType)
        }
        return successValue(habitType: habitType)
    }

    // MARK: - UI labels

    static func statusLabel(habitType: HabitType, entry: MetricEntry?) -> (text: String, isSuccess: Bool) {
        guard isLoggedForDay(entry: entry) else {
            switch habitType {
            case .positive:
                return ("Incomplete", false)
            case .vice:
                return ("Not Avoided", false)
            }
        }

        let success = isSuccessful(habitType: habitType, value: entry!.value)
        switch habitType {
        case .positive:
            return success ? ("Completed", true) : ("Incomplete", false)
        case .vice:
            return success ? ("Avoided", true) : ("Not Avoided", false)
        }
    }

    /// UI toggle binding: `true` means success (did it / avoided).
    static func toggleIsOn(habitType: HabitType, value: Bool) -> Bool {
        isSuccessful(habitType: habitType, value: value)
    }

    static func value(fromToggleIsOn isOn: Bool, habitType: HabitType) -> Bool {
        switch habitType {
        case .positive:
            return isOn
        case .vice:
            return !isOn
        }
    }
}
