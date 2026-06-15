import Foundation
import SwiftData

// MARK: - DemoDataGenerator
/// Deterministic demo dataset tuned for screenshots: habits + vices, streaks, savings, recovery timer.
struct DemoDataGenerator {

    private struct DemoMetricPlan {
        let name: String
        let habitType: HabitType
        let primaryMotivation: String?
        let costPerUnit: Decimal?
        let showRecoveryTimer: Bool
        let monthlyGoal: Int
        /// Day offsets from today (0 = today) where the metric was successfully logged.
        let successOffsets: [Int]
        /// Vice only — day offsets where the user slipped (`value == true`).
        let slipOffsets: [Int]
        let moodToday: String?
    }

    static func generateDemoData(modelContext: ModelContext) {
        UserDefaults.standard.set(true, forKey: "hasDemoData")
        MetricCostStore.clearAll()
        MetricDisplayPreferences.clearAll()
        MilestoneStore.clearAll()

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let plans = demoPlans()
        var metrics: [Metric] = []

        for plan in plans {
            let metric = Metric(
                name: plan.name,
                habitType: plan.habitType,
                primaryMotivation: plan.primaryMotivation
            )
            metric.hasBeenLogged = true
            modelContext.insert(metric)
            metrics.append(metric)

            if let cost = plan.costPerUnit {
                MetricCostStore.setCostPerUnit(cost, for: metric.id)
            }
            if plan.showRecoveryTimer {
                MetricDisplayPreferences.setShowTimeSinceSlip(true, for: metric.id)
            }

            let goal = Goal(goalType: .boolean, period: .monthly, target: plan.monthlyGoal)
            goal.metric = metric
            metric.goals?.append(goal)
            modelContext.insert(goal)
        }

        for plan in plans {
            guard let metric = metrics.first(where: { $0.name == plan.name }) else { continue }

            let slipOffsets = Set(plan.slipOffsets)
            let successOffsets = Set(plan.successOffsets)

            for offset in 0...44 {
                guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }

                let isSlip = plan.habitType == .vice && slipOffsets.contains(offset)
                let isSuccess = successOffsets.contains(offset)

                guard isSlip || isSuccess else { continue }

                let value: Bool
                if plan.habitType == .positive {
                    value = true
                } else {
                    value = isSlip
                }

                let mood: String?
                if offset == 0 {
                    mood = plan.moodToday
                } else if offset == 1, plan.habitType == .positive {
                    mood = "🙂"
                } else {
                    mood = nil
                }

                let (quantity, unit) = quantityData(for: plan.name, offset: offset, isSuccess: isSuccess && !isSlip)

                let entry = MetricEntry(
                    metricID: metric.id,
                    date: date,
                    value: value,
                    quantity: quantity,
                    unit: unit,
                    mood: mood,
                    hasBeenLogged: true
                )
                modelContext.insert(entry)
            }
        }

        modelContext.saveChanges(operation: "seed demo data", entity: "Model")
    }

    // MARK: - Curated plans (deterministic — safe for screenshots)

    private static func demoPlans() -> [DemoMetricPlan] {
        let habitSuccess = { (streak: Int) in Array(0..<streak) }

        return [
            DemoMetricPlan(
                name: "Exercise",
                habitType: .positive,
                primaryMotivation: "More energy for my kids",
                costPerUnit: nil,
                showRecoveryTimer: false,
                monthlyGoal: 20,
                successOffsets: habitSuccess(12) + [14, 16, 18, 20, 22, 25, 28, 30, 33, 36],
                slipOffsets: [],
                moodToday: "💪"
            ),
            DemoMetricPlan(
                name: "Reading",
                habitType: .positive,
                primaryMotivation: "Learn something new every day",
                costPerUnit: nil,
                showRecoveryTimer: false,
                monthlyGoal: 20,
                successOffsets: habitSuccess(8) + [10, 12, 15, 18, 21, 24, 27, 30, 35, 40],
                slipOffsets: [],
                moodToday: "😊"
            ),
            DemoMetricPlan(
                name: "Meditation",
                habitType: .positive,
                primaryMotivation: nil,
                costPerUnit: nil,
                showRecoveryTimer: false,
                monthlyGoal: 15,
                successOffsets: habitSuccess(7) + [9, 11, 14, 17, 20, 26, 32],
                slipOffsets: [],
                moodToday: "🙂"
            ),
            DemoMetricPlan(
                name: "Drink water",
                habitType: .positive,
                primaryMotivation: nil,
                costPerUnit: nil,
                showRecoveryTimer: false,
                monthlyGoal: 25,
                successOffsets: habitSuccess(15) + [17, 19, 22, 25, 28, 31, 34, 38, 42],
                slipOffsets: [],
                moodToday: nil
            ),
            DemoMetricPlan(
                name: "Social media",
                habitType: .vice,
                primaryMotivation: "I want my attention back for things that matter",
                costPerUnit: nil,
                showRecoveryTimer: true,
                monthlyGoal: 8,
                successOffsets: habitSuccess(14) + Array(15...28) + [30, 32, 34, 36, 38, 40, 42],
                slipOffsets: [14, 29],
                moodToday: "🙂"
            ),
            DemoMetricPlan(
                name: "Late-night snacks",
                habitType: .vice,
                primaryMotivation: "Better sleep and mornings",
                costPerUnit: 5,
                showRecoveryTimer: false,
                monthlyGoal: 10,
                successOffsets: habitSuccess(9) + [11, 13, 16, 19, 22, 26, 30, 35],
                slipOffsets: [10],
                moodToday: nil
            ),
            DemoMetricPlan(
                name: "Smoking",
                habitType: .vice,
                primaryMotivation: "Breathe easier and save money",
                costPerUnit: 12,
                showRecoveryTimer: false,
                monthlyGoal: 5,
                successOffsets: habitSuccess(21) + [23, 25, 28, 31, 34, 37, 40, 43],
                slipOffsets: [],
                moodToday: nil
            ),
            DemoMetricPlan(
                name: "Alcohol",
                habitType: .vice,
                primaryMotivation: "Clearer weekends",
                costPerUnit: 15,
                showRecoveryTimer: true,
                monthlyGoal: 8,
                successOffsets: habitSuccess(6) + [8, 10, 12, 15, 18, 21, 24, 27, 33, 39],
                slipOffsets: [7, 20],
                moodToday: nil
            )
        ]
    }

    private static func quantityData(for name: String, offset: Int, isSuccess: Bool) -> (Int?, String?) {
        guard isSuccess else { return (nil, nil) }
        _ = name
        _ = offset
        return (nil, nil)
    }

    static func clearDemoData(modelContext: ModelContext) {
        UserDefaults.standard.set(false, forKey: "hasDemoData")
        MetricCostStore.clearAll()
        MetricDisplayPreferences.clearAll()
        MilestoneStore.clearAll()

        do {
            try modelContext.delete(model: Metric.self)
            try modelContext.delete(model: MetricEntry.self)
            try modelContext.delete(model: Goal.self)
            try modelContext.save()
        } catch {
            logger.error("Error clearing demo data: \(error.localizedDescription)", category: .data)
        }
    }

    static func hasDemoData() -> Bool {
        UserDefaults.standard.bool(forKey: "hasDemoData")
    }
}
