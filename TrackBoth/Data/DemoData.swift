import Foundation
import SwiftData

enum LaunchConfiguration {
    static func applyArguments(_ arguments: [String] = ProcessInfo.processInfo.arguments) {
        if arguments.contains("-skip_onboarding") {
            Preferences.hasCompletedOnboarding = true
            Preferences.hasAcceptedDisclaimer = true
        }
    }

    static var shouldSeedDemo: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("-seed_demo") || arguments.contains("-screenshot_demo")
    }

    static var initialTab: AppTab? {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-tab_progress") { return .progress }
        if arguments.contains("-tab_settings") { return .settings }
        return nil
    }

    static var opensFirstDetail: Bool {
        ProcessInfo.processInfo.arguments.contains("-open_first_detail")
    }

    static var presentsSlip: Bool {
        ProcessInfo.processInfo.arguments.contains("-present_slip")
    }

    static var startsOnVices: Bool {
        ProcessInfo.processInfo.arguments.contains("-onboarding_vices")
    }

    static var initialPresentation: PresentedFlow? {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-present_checkin") { return .checkIn }
        if arguments.contains("-present_urge") { return .urge(nil) }
        return nil
    }
}

enum DemoData {
    @MainActor
    static func seedIfEmpty(context: ModelContext, now: Date = Date(), calendar: Calendar = .current) throws {
        let existing = try context.fetch(FetchDescriptor<Metric>())
        guard existing.isEmpty else { return }
        try seed(context: context, now: now, calendar: calendar)
    }

    @MainActor
    static func seed(context: ModelContext, now: Date = Date(), calendar: Calendar = .current) throws {
        let store = RecoveryStore(context: context, calendar: calendar)
        let alcoholStart = calendar.date(byAdding: .day, value: -23, to: now) ?? now
        let socialDay = calendar.date(byAdding: .day, value: -6, to: now) ?? now
        let socialStart = calendar.date(bySettingHour: 9, minute: 15, second: 0, of: socialDay) ?? socialDay
        let slipAt = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: -9, to: now) ?? now) ?? now

        let alcohol = try store.addMetric(
            name: "Alcohol",
            habitType: .vice,
            iconName: "wineglass",
            startedAt: alcoholStart,
            costPerDay: 8,
            firstReason: "For my health"
        )
        try store.setPlan(alcohol, plan: "When I feel the urge, I will go for a walk.")
        try store.addReason("For my family", to: alcohol)
        try store.addReason("To feel in control", to: alcohol)
        try store.logSlip(alcohol, occurredAt: slipAt, triggers: [.tired, .routine], note: nil)
        for offset in [-1, -2, -3, -4] {
            if let day = calendar.date(byAdding: .day, value: offset, to: now) {
                try store.markFree(alcohol, on: day, now: day)
            }
        }

        _ = try store.addMetric(
            name: "Social media",
            habitType: .vice,
            iconName: "iphone",
            startedAt: socialStart,
            costPerDay: nil,
            firstReason: nil
        )

        let walk = try store.addMetric(
            name: "Go for a walk",
            habitType: .positive,
            iconName: "figure.walk",
            startedAt: alcoholStart,
            costPerDay: nil,
            firstReason: nil
        )
        let call = try store.addMetric(
            name: "Call a friend",
            habitType: .positive,
            iconName: "phone",
            startedAt: alcoholStart,
            costPerDay: nil,
            firstReason: nil
        )
        for offset in [-1, -2, -3, -4, -6] {
            if let day = calendar.date(byAdding: .day, value: offset, to: now) {
                try store.setHabitDone(walk, on: day, done: true, now: day)
            }
        }
        for offset in [-2, -3, -4] {
            if let day = calendar.date(byAdding: .day, value: offset, to: now) {
                try store.setHabitDone(call, on: day, done: true, now: day)
            }
        }

        let outcomes: [UrgeOutcome] = [.resisted, .resisted, .resisted, .resisted, .slipped, .unknown]
        for (index, outcome) in outcomes.enumerated() {
            let started = calendar.date(byAdding: .day, value: -(index + 1), to: now) ?? now
            let urge = try store.startUrge(for: alcohol, intensity: (index % 5) + 1, now: started)
            try store.finishUrge(urge, outcome: outcome, triggers: index.isMultiple(of: 2) ? [.stressed] : [], note: nil, now: started)
        }
        let seededMetrics = try context.fetch(FetchDescriptor<Metric>())
        let seededEntries = try context.fetch(FetchDescriptor<MetricEntry>())
        let seededReasons = try context.fetch(FetchDescriptor<Reason>())
        for request in MilestoneCenter.pending(metrics: seededMetrics, entries: seededEntries, reasons: seededReasons, now: now, calendar: calendar) {
            MilestoneLedger.record(request.threshold, for: request.metricID)
        }
    }
}
