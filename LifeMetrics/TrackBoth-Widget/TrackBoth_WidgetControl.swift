import AppIntents
import SwiftUI
import WidgetKit

struct TrackBoth_WidgetControl: ControlWidget {
    static let kind = "com.jacobrozell.TrackBoth.QuickLogControl"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                value.isLoggedLabel,
                isOn: value.isSuccess,
                action: LogMetricControlIntent(metricID: value.metricID, name: value.metricName)
            ) { isOn in
                Label(
                    isOn ? value.loggedTitle : value.unloggedTitle,
                    systemImage: value.isVice ? "shield.fill" : "checkmark.circle.fill"
                )
            }
        }
        .displayName("Quick Log")
        .description("Log one habit or vice from Control Center.")
        .promptsForUserConfiguration()
    }
}

extension TrackBoth_WidgetControl {
    struct Value {
        var metricID: String
        var metricName: String
        var isVice: Bool
        var isSuccess: Bool
        var isLogged: Bool

        var isLoggedLabel: String { metricName }

        var loggedTitle: String {
            isVice ? "Avoided" : "Done"
        }

        var unloggedTitle: String {
            isVice ? "Avoid" : "Log"
        }
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: ControlMetricConfiguration) -> Value {
            value(for: configuration, snapshot: .placeholder)
        }

        func currentValue(configuration: ControlMetricConfiguration) async throws -> Value {
            let snapshot = WidgetSnapshotStore.load() ?? .empty
            return value(for: configuration, snapshot: snapshot)
        }

        private func value(for configuration: ControlMetricConfiguration, snapshot: WidgetSnapshotV1) -> Value {
            let metric = resolvedMetric(configuration: configuration, snapshot: snapshot)
            return Value(
                metricID: metric.id,
                metricName: metric.name,
                isVice: metric.habitType == HabitTypeSnapshot.vice,
                isSuccess: metric.today.isSuccess,
                isLogged: metric.today.isLogged
            )
        }

        private func resolvedMetric(
            configuration: ControlMetricConfiguration,
            snapshot: WidgetSnapshotV1
        ) -> WidgetMetricSnapshot {
            if let id = configuration.metric?.id, let metric = snapshot.metric(id: id) {
                return metric
            }
            return snapshot.metrics.first
                ?? .placeholder(id: "0", name: "TrackBoth", habitType: "positive", streak: 0, logged: false)
        }
    }
}

struct LogMetricControlIntent: SetValueIntent {
    static var title: LocalizedStringResource = "Log Metric"

    @Parameter(title: "Metric ID")
    var metricID: String

    @Parameter(title: "Metric Name")
    var name: String

    @Parameter(title: "Logged success")
    var value: Bool

    init() {}

    init(metricID: String, name: String) {
        self.metricID = metricID
        self.name = name
    }

    func perform() async throws -> some IntentResult {
        WidgetLogWriter.apply(metricID: metricID, success: value)
        try await donate()
        return .result()
    }
}
