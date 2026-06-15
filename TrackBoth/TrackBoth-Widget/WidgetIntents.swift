import AppIntents
import Foundation
import WidgetKit

struct TrackBothLogIntent: AppIntent {
    static var title: LocalizedStringResource = "Log with TrackBoth"
    static var description = IntentDescription("Log a habit or vice for today.")

    @Parameter(title: "Metric ID")
    var metricID: String

    init() {}

    init(metricID: String) {
        self.metricID = metricID
    }

    func perform() async throws -> some IntentResult {
        guard var snapshot = WidgetSnapshotStore.load() else { return .result() }
        guard let storedValue = snapshot.applyQuickToggle(metricID: metricID) else { return .result() }

        WidgetSnapshotStore.save(snapshot)
        WidgetPendingLogStore.enqueue(
            WidgetPendingLog(
                metricID: metricID,
                day: snapshot.today.date,
                storedValue: storedValue,
                requestedAt: Date()
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
        try await donate()
        return .result()
    }
}

enum WidgetLogWriter {
    static func apply(metricID: String, success: Bool) {
        guard var snapshot = WidgetSnapshotStore.load(),
              let storedValue = snapshot.applyLog(metricID: metricID, success: success) else { return }
        WidgetSnapshotStore.save(snapshot)
        WidgetPendingLogStore.enqueue(
            WidgetPendingLog(
                metricID: metricID,
                day: snapshot.today.date,
                storedValue: storedValue,
                requestedAt: Date()
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct TodayProgressConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Today"
    static var description = IntentDescription("See what's left to log today.")
}

struct TrackBothLogConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "TrackBoth Log"
    static var description = IntentDescription("Log habits and vices from the Home Screen.")
}

struct StreakSpotlightConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Streak Spotlight"
    static var description = IntentDescription("Highlight one metric's streak.")

    @Parameter(title: "Metric")
    var metric: MetricEntity?
}

struct ViceRecoveryConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Recovery"
    static var description = IntentDescription("Time recovering since your last slip.")

    @Parameter(title: "Vice")
    var vice: ViceMetricEntity?
}

struct MoneySavedConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Money Saved"
    static var description = IntentDescription("Savings from your vice streak.")

    @Parameter(title: "Vice")
    var vice: ViceWithSavingsEntity?
}

struct GoalProgressConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Goals"
    static var description = IntentDescription("Monthly goal progress.")

    @Parameter(title: "Metric")
    var metric: MetricEntity?
}

struct WeekGlanceConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Week at a Glance"
    static var description = IntentDescription("Seven-day history for one metric.")

    @Parameter(title: "Metric")
    var metric: MetricEntity?
}

struct DailyMotivationConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Daily Motivation"
    static var description = IntentDescription("Your reason on the Home Screen.")

    @Parameter(title: "Metric")
    var metric: MotivatedMetricEntity?
}

struct ControlMetricConfiguration: ControlConfigurationIntent {
    static var title: LocalizedStringResource = "TrackBoth Control"
    static var description = IntentDescription("Log one metric from Control Center.")

    @Parameter(title: "Metric")
    var metric: MetricEntity?
}

enum WidgetDeepLink {
    static let home = URL(string: "trackboth://home")!
}
