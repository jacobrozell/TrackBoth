import Foundation
import SwiftData

// MARK: - MetricPreset
/// Starter templates for habits and vices (onboarding + Add Metric).
struct MetricPreset: Identifiable, Hashable {
    let id: String
    let name: String
    let habitType: HabitType
    let suggestedUnit: String?
    let icon: String

    static let habitPresets: [MetricPreset] = [
        MetricPreset(id: "exercise", name: "Exercise", habitType: .positive, suggestedUnit: "minutes", icon: "figure.run"),
        MetricPreset(id: "reading", name: "Reading", habitType: .positive, suggestedUnit: "pages", icon: "book.fill"),
        MetricPreset(id: "meditation", name: "Meditation", habitType: .positive, suggestedUnit: "minutes", icon: "brain.head.profile"),
        MetricPreset(id: "drink-water", name: "Drink water", habitType: .positive, suggestedUnit: nil, icon: "drop.fill")
    ]

    static let vicePresets: [MetricPreset] = [
        MetricPreset(id: "social-media", name: "Social media", habitType: .vice, suggestedUnit: nil, icon: "iphone"),
        MetricPreset(id: "smoking", name: "Smoking", habitType: .vice, suggestedUnit: "cigarettes", icon: "smoke.fill"),
        MetricPreset(id: "alcohol", name: "Alcohol", habitType: .vice, suggestedUnit: "drinks", icon: "wineglass.fill"),
        MetricPreset(id: "late-snacks", name: "Late-night snacks", habitType: .vice, suggestedUnit: nil, icon: "moon.stars.fill")
    ]

    static func presets(for habitType: HabitType) -> [MetricPreset] {
        habitType == .positive ? habitPresets : vicePresets
    }

    /// Starter rows when onboarding completes with no chip selection.
    static let onboardingPlaceholders: [MetricPreset] = [
        MetricPreset(id: "placeholder-habit", name: "My habit", habitType: .positive, suggestedUnit: nil, icon: "plus.circle"),
        MetricPreset(id: "placeholder-vice", name: "My vice", habitType: .vice, suggestedUnit: nil, icon: "plus.circle")
    ]
}

// MARK: - MetricPresetFactory
enum MetricPresetFactory {
    static func defaultMonthlyTarget(for habitType: HabitType) -> Int {
        habitType == .vice ? 8 : 20
    }

    @discardableResult
    static func createMetrics(
        from presets: [MetricPreset],
        in context: ModelContext
    ) -> [Metric] {
        var created: [Metric] = []
        for preset in presets {
            let metric = Metric(name: preset.name, habitType: preset.habitType)
            context.insert(metric)

            let goal = Goal(
                goalType: .boolean,
                period: .monthly,
                target: defaultMonthlyTarget(for: preset.habitType)
            )
            goal.metric = metric
            context.insert(goal)

            created.append(metric)
        }

        if !created.isEmpty {
            context.saveChanges(operation: "create preset metrics", entity: "Metric")
        }
        return created
    }

    @discardableResult
    static func createOnboardingPlaceholders(in context: ModelContext) -> [Metric] {
        createMetrics(from: MetricPreset.onboardingPlaceholders, in: context)
    }
}
