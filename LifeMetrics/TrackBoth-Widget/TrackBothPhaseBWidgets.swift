import WidgetKit
import SwiftUI

// MARK: - Accessory helpers

enum WidgetAccessoryViews {
    @ViewBuilder
    static func todayRectangular(snapshot: WidgetSnapshotV1) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Today")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("\(snapshot.today.completedCount)/\(snapshot.today.totalCount) logged")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    static func todayInline(snapshot: WidgetSnapshotV1) -> some View {
        Text("📅 \(snapshot.today.completedCount)/\(snapshot.today.totalCount) logged")
    }

    @ViewBuilder
    static func streakCircular(metric: WidgetMetricSnapshot) -> some View {
        Gauge(value: 1, in: 0...1) {
            Image(systemName: metric.habitType == HabitTypeSnapshot.vice ? "shield.fill" : "flame.fill")
        } currentValueLabel: {
            Text("\(metric.streak.current)")
                .font(.title3)
                .fontWeight(.bold)
        }
        .gaugeStyle(.accessoryCircular)
    }

    @ViewBuilder
    static func streakInline(metric: WidgetMetricSnapshot) -> some View {
        let icon = metric.habitType == HabitTypeSnapshot.vice ? "🛡" : "🔥"
        Text("\(icon) \(metric.streak.current)d \(metric.name)")
    }

    @ViewBuilder
    static func recoveryCircular(metric: WidgetMetricSnapshot) -> some View {
        if let recovery = metric.recovery?.compactLabel {
            Gauge(value: 1, in: 0...1) {
                Image(systemName: "arrow.uturn.backward")
            } currentValueLabel: {
                Text(recovery.replacingOccurrences(of: " recovering", with: ""))
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .gaugeStyle(.accessoryCircular)
        } else {
            streakCircular(metric: metric)
        }
    }

    @ViewBuilder
    static func recoveryRectangular(metric: WidgetMetricSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let recovery = metric.recovery?.compactLabel {
                Text(recovery)
                    .font(.headline)
                    .foregroundStyle(.orange)
            } else {
                Text("\(metric.streak.current)d clean")
                    .font(.headline)
            }
            Text(metric.name)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    static func recoveryInline(metric: WidgetMetricSnapshot) -> some View {
        if let recovery = metric.recovery?.compactLabel {
            Text("↩ \(recovery) · \(metric.name)")
        } else {
            streakInline(metric: metric)
        }
    }
}

extension WidgetSavingsSnapshot {
    var amountText: String {
        label.replacingOccurrences(of: " saved", with: "")
    }
}

// MARK: - Money Saved

struct MoneySavedWidget: Widget {
    let kind = "MoneySavedWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: MoneySavedConfiguration.self, provider: MoneySavedProvider()) { entry in
            MoneySavedWidgetView(metric: entry.metric)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Savings")
        .description("Money saved on your vice streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MoneySavedProvider: AppIntentTimelineProvider {
    typealias Entry = MoneySavedEntry
    typealias Intent = MoneySavedConfiguration

    func placeholder(in context: Context) -> Entry {
        Entry(
            date: Date(),
            metric: .placeholder(id: "2", name: "Smoking", habitType: "vice", streak: 21, logged: true, savings: "$252 saved")
        )
    }

    func snapshot(for configuration: MoneySavedConfiguration, in context: Context) async -> Entry {
        Entry(date: Date(), metric: resolvedMetric(configuration: configuration))
    }

    func timeline(for configuration: MoneySavedConfiguration, in context: Context) async -> Timeline<Entry> {
        let entry = Entry(date: Date(), metric: resolvedMetric(configuration: configuration))
        let nextRefresh = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }

    private func resolvedMetric(configuration: MoneySavedConfiguration) -> WidgetMetricSnapshot {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        if let id = configuration.vice?.id, let metric = snapshot.metric(id: id) {
            return metric
        }
        return snapshot.vicesWithSavings().max(by: { $0.streak.current < $1.streak.current })
            ?? .placeholder(id: "0", name: "Add vice cost", habitType: "vice", streak: 0, logged: false)
    }
}

struct MoneySavedEntry: TimelineEntry {
    let date: Date
    let metric: WidgetMetricSnapshot
}

struct MoneySavedWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let metric: WidgetMetricSnapshot

    var body: some View {
        Group {
            if let savings = metric.savings {
                if family == .systemMedium {
                    mediumContent(savings: savings)
                } else {
                    smallContent(savings: savings)
                }
            } else {
                emptyContent
            }
        }
        .widgetURL(WidgetDeepLink.home)
    }

    private func smallContent(savings: WidgetSavingsSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(savings.amountText)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.green)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text("saved")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(metric.name)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text("\(metric.streak.current) clean days")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func mediumContent(savings: WidgetSavingsSnapshot) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(savings.amountText)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                Text("saved · \(metric.name)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text("\(metric.streak.current) clean days")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            if let motivation = metric.primaryMotivation, !motivation.isEmpty {
                Text(motivation)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private var emptyContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Money Saved")
                .font(.headline)
            Text("Add cost per unit in app")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Goal Progress

struct GoalProgressWidget: Widget {
    let kind = "GoalProgressWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: GoalProgressConfiguration.self, provider: GoalProgressProvider()) { entry in
            GoalProgressWidgetView(goals: entry.goals)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Goals")
        .description("Monthly goal progress.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct GoalProgressProvider: AppIntentTimelineProvider {
    typealias Entry = GoalProgressEntry
    typealias Intent = GoalProgressConfiguration

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), goals: WidgetSnapshotV1.placeholder.metricsWithGoals())
    }

    func snapshot(for configuration: GoalProgressConfiguration, in context: Context) async -> Entry {
        Entry(date: Date(), goals: resolvedGoals(configuration: configuration))
    }

    func timeline(for configuration: GoalProgressConfiguration, in context: Context) async -> Timeline<Entry> {
        let entry = Entry(date: Date(), goals: resolvedGoals(configuration: configuration))
        let nextRefresh = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }

    private func resolvedGoals(configuration: GoalProgressConfiguration) -> [WidgetMetricSnapshot] {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        if let id = configuration.metric?.id, let metric = snapshot.metric(id: id), metric.goal != nil {
            return [metric]
        }
        return snapshot.metricsWithGoals().sorted { ($0.goal?.progress ?? 0) > ($1.goal?.progress ?? 0) }
    }
}

struct GoalProgressEntry: TimelineEntry {
    let date: Date
    let goals: [WidgetMetricSnapshot]
}

struct GoalProgressWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let goals: [WidgetMetricSnapshot]

    private var limit: Int {
        family == .systemLarge ? 4 : 2
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Goals")
                .font(.headline)

            if goals.isEmpty {
                Text("Add goals in the app")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(goals.prefix(limit))) { metric in
                    if let goal = metric.goal {
                        GoalProgressRow(metricName: metric.name, goal: goal)
                    }
                }
            }
        }
        .widgetURL(WidgetDeepLink.home)
    }
}

struct GoalProgressRow: View {
    let metricName: String
    let goal: WidgetGoalSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(metricName)
                    .font(.caption)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(goal.progressLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: goal.progress)
                .tint(.blue)
        }
    }
}
