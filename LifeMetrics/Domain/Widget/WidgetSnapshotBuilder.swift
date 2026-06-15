import Foundation

// MARK: - Widget Snapshot Builder
/// Builds `WidgetSnapshotV1` from app domain models. Main-app target only.
enum WidgetSnapshotBuilder {
    static func build(
        metrics: [Metric],
        entries: [MetricEntry],
        asOf date: Date = Date()
    ) -> WidgetSnapshotV1 {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        let snapshots = metrics.enumerated().map { index, metric in
            buildMetricSnapshot(
                metric: metric,
                entries: entries,
                sortOrder: index,
                asOf: today
            )
        }

        let habits = snapshots.filter { $0.habitType == HabitTypeSnapshot.positive }
        let vices = snapshots.filter { $0.habitType == HabitTypeSnapshot.vice }
        let habitsCompleted = habits.filter(\.today.isSuccess).count
        let vicesAvoided = vices.filter(\.today.isSuccess).count

        return WidgetSnapshotV1(
            schemaVersion: WidgetSnapshotV1.currentSchemaVersion,
            generatedAt: Date(),
            today: WidgetTodaySummary(
                date: WidgetDateCodec.dayString(from: today),
                completedCount: habitsCompleted + vicesAvoided,
                totalCount: snapshots.count,
                habitsCompleted: habitsCompleted,
                habitsTotal: habits.count,
                vicesAvoided: vicesAvoided,
                vicesTotal: vices.count
            ),
            metrics: snapshots
        )
    }

    private static func buildMetricSnapshot(
        metric: Metric,
        entries: [MetricEntry],
        sortOrder: Int,
        asOf today: Date
    ) -> WidgetMetricSnapshot {
        let metricEntries = entries.filter { $0.metricID == metric.id }
        let todayEntry = MetricEntry.find(for: metric.id, date: today, in: metricEntries)
        let isLogged = TrackingSemantics.isLoggedForDay(entry: todayEntry)
        let storedValue = todayEntry?.value ?? TrackingSemantics.successValue(habitType: metric.habitType)

        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: metricEntries, selectedDate: today)
        let longest = StreakUtils.calculateLongestStreak(for: metric, entries: metricEntries)

        var recovery: WidgetRecoverySnapshot?
        if metric.habitType == .vice,
           MetricDisplayPreferences.showTimeSinceSlip(for: metric.id),
           let label = ViceSlipTimer.formattedRecoveryTime(metricID: metric.id, entries: metricEntries, asOf: today),
           let compact = ViceSlipTimer.compactRecoveryLabel(metricID: metric.id, entries: metricEntries, asOf: today) {
            let lastSlip = ViceSlipTimer.lastSlipDate(metricID: metric.id, entries: metricEntries)
            recovery = WidgetRecoverySnapshot(
                label: label,
                compactLabel: compact,
                lastSlipDate: lastSlip.map { WidgetDateCodec.dayString(from: $0) }
            )
        }

        var savings: WidgetSavingsSnapshot?
        if metric.habitType == .vice,
           let label = ViceSavingsCalculator.savingsLabel(
               streak: streak,
               costPerUnit: MetricCostStore.costPerUnit(for: metric.id)
           ) {
            savings = WidgetSavingsSnapshot(label: label)
        }

        let goal = buildGoalSnapshot(metric: metric, entries: metricEntries, asOf: today)

        return WidgetMetricSnapshot(
            id: metric.id.uuidString,
            name: metric.name,
            habitType: metric.habitType.rawValue,
            sortOrder: sortOrder,
            primaryMotivation: metric.primaryMotivation,
            showRecoveryTimer: MetricDisplayPreferences.showTimeSinceSlip(for: metric.id),
            today: WidgetTodayEntry(
                isLogged: isLogged,
                storedValue: storedValue,
                habitType: metric.habitType.rawValue
            ),
            streak: WidgetStreakSnapshot(current: streak, longest: longest),
            recovery: recovery,
            savings: savings,
            goal: goal,
            week: weekFlags(metric: metric, entries: metricEntries, asOf: today)
        )
    }

    private static func buildGoalSnapshot(
        metric: Metric,
        entries: [MetricEntry],
        asOf today: Date
    ) -> WidgetGoalSnapshot? {
        let goal = metric.booleanGoal(for: .monthly)
            ?? metric.booleanGoals.first
            ?? metric.quantityGoals.first
        guard let goal else { return nil }

        let progress = GoalUtils.calculateGoalProgress(
            for: goal,
            metric: metric,
            entries: entries,
            selectedDate: today
        )
        return WidgetGoalSnapshot(
            period: goal.period.rawValue,
            progress: min(1, max(0, progress.percentage / 100)),
            current: Int(progress.current),
            target: max(1, Int(progress.target)),
            unit: progress.unit
        )
    }

    private static func weekFlags(
        metric: Metric,
        entries: [MetricEntry],
        asOf today: Date
    ) -> [Bool?] {
        let calendar = Calendar.current
        return (0..<7).map { offset in
            guard let day = calendar.date(byAdding: .day, value: offset - 6, to: today) else { return nil }
            guard let entry = MetricEntry.find(for: metric.id, date: day, in: entries),
                  TrackingSemantics.isLoggedForDay(entry: entry) else { return nil }
            return TrackingSemantics.isSuccessful(habitType: metric.habitType, value: entry.value)
        }
    }
}
