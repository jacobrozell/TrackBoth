import WidgetKit
import SwiftUI

struct SnapshotEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshotV1
}

struct SnapshotProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnapshotEntry {
        SnapshotEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        completion(SnapshotEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
        let snapshot = WidgetSnapshotStore.load() ?? .empty
        let entry = SnapshotEntry(date: Date(), snapshot: snapshot)
        let nextRefresh = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

// MARK: - Today Progress

struct TodayProgressWidget: Widget {
    let kind = "TodayProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SnapshotProvider()) { entry in
            TodayProgressWidgetView(snapshot: entry.snapshot)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today")
        .description("See what's left to log today.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

struct TodayProgressWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: WidgetSnapshotV1

    var body: some View {
        Group {
            switch family {
            case .accessoryRectangular:
                WidgetAccessoryViews.todayRectangular(snapshot: snapshot)
            case .accessoryInline:
                WidgetAccessoryViews.todayInline(snapshot: snapshot)
            default:
                homeScreenBody
            }
        }
        .widgetURL(WidgetDeepLink.home)
    }

    private var homeScreenBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today")
                    .font(.headline)
                Spacer()
                Text(snapshot.today.date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text("\(snapshot.today.completedCount)/\(snapshot.today.totalCount)")
                .font(.system(size: 34, weight: .bold, design: .rounded))

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            if !snapshot.unloggedMetrics().isEmpty {
                Spacer(minLength: 0)
                FlowChips(metrics: snapshot.unloggedMetrics(limit: 3))
            }
        }
    }

    private var subtitle: String {
        var parts: [String] = []
        let habitsLeft = snapshot.today.habitsTotal - snapshot.today.habitsCompleted
        let vicesLeft = snapshot.today.vicesTotal - snapshot.today.vicesAvoided
        if snapshot.today.habitsTotal > 0 { parts.append("\(habitsLeft) habits left") }
        if snapshot.today.vicesTotal > 0 { parts.append("\(vicesLeft) vices left") }
        return parts.isEmpty ? "All logged" : parts.joined(separator: " · ")
    }
}

struct FlowChips: View {
    let metrics: [WidgetMetricSnapshot]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(metrics) { metric in
                Button(intent: TrackBothLogIntent(metricID: metric.id)) {
                    HStack(spacing: 6) {
                        Image(systemName: metric.habitType == HabitTypeSnapshot.positive ? "checkmark.circle" : "shield")
                        Text(metric.name)
                            .lineLimit(1)
                    }
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - TrackBoth Log

struct TrackBothLogWidget: Widget {
    let kind = "TrackBothLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SnapshotProvider()) { entry in
            TrackBothLogWidgetView(snapshot: entry.snapshot)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("TrackBoth Log")
        .description("Log habits and vices without opening the app.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct TrackBothLogWidgetView: View {
    let snapshot: WidgetSnapshotV1

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TrackBoth")
                .font(.headline)

            HStack(alignment: .top, spacing: 12) {
                logSection(title: "Habits", tint: .green, metrics: Array(snapshot.habits().prefix(4)))
                logSection(title: "Vices", tint: .red, metrics: Array(snapshot.vices().prefix(4)))
            }
        }
        .widgetURL(WidgetDeepLink.home)
    }

    @ViewBuilder
    private func logSection(title: String, tint: Color, metrics: [WidgetMetricSnapshot]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(tint)
                .fontWeight(.semibold)

            if metrics.isEmpty {
                Text("None")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(metrics) { metric in
                    TrackBothLogRow(metric: metric, tint: tint)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TrackBothLogRow: View {
    let metric: WidgetMetricSnapshot
    let tint: Color

    var body: some View {
        Button(intent: TrackBothLogIntent(metricID: metric.id)) {
            HStack(spacing: 8) {
                Image(systemName: metric.today.isSuccess ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(metric.today.isSuccess ? tint : .secondary)
                VStack(alignment: .leading, spacing: 1) {
                    Text(metric.name)
                        .font(.caption)
                        .lineLimit(1)
                    if let recovery = metric.recovery?.compactLabel {
                        Text(recovery)
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Streak Spotlight

struct StreakSpotlightWidget: Widget {
    let kind = "StreakSpotlightWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: StreakSpotlightConfiguration.self, provider: StreakSpotlightProvider()) { entry in
            StreakSpotlightWidgetView(metric: entry.metric)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Streak")
        .description("Your streak at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline])
    }
}

struct StreakSpotlightProvider: AppIntentTimelineProvider {
    typealias Entry = StreakSpotlightEntry
    typealias Intent = StreakSpotlightConfiguration

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), metric: .placeholder(id: "1", name: "Exercise", habitType: "positive", streak: 12, logged: true))
    }

    func snapshot(for configuration: StreakSpotlightConfiguration, in context: Context) async -> Entry {
        Entry(date: Date(), metric: resolvedMetric(configuration: configuration))
    }

    func timeline(for configuration: StreakSpotlightConfiguration, in context: Context) async -> Timeline<Entry> {
        let entry = Entry(date: Date(), metric: resolvedMetric(configuration: configuration))
        let nextRefresh = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }

    private func resolvedMetric(configuration: StreakSpotlightConfiguration) -> WidgetMetricSnapshot {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        if let id = configuration.metric?.id, let metric = snapshot.metric(id: id) {
            return metric
        }
        return snapshot.metrics.max(by: { $0.streak.current < $1.streak.current })
            ?? .placeholder(id: "0", name: "Add a metric", habitType: "positive", streak: 0, logged: false)
    }
}

struct StreakSpotlightEntry: TimelineEntry {
    let date: Date
    let metric: WidgetMetricSnapshot
}

struct StreakSpotlightWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let metric: WidgetMetricSnapshot

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                WidgetAccessoryViews.streakCircular(metric: metric)
            case .accessoryInline:
                WidgetAccessoryViews.streakInline(metric: metric)
            default:
                homeScreenBody
            }
        }
        .widgetURL(WidgetDeepLink.home)
    }

    private var homeScreenBody: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(metric.name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text("\(metric.streak.current)")
                .font(.system(size: 40, weight: .bold, design: .rounded))

            Text(metric.habitType == HabitTypeSnapshot.vice ? "clean days" : "day streak")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let recovery = metric.recovery?.compactLabel {
                Text(recovery)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Vice Recovery

struct ViceRecoveryWidget: Widget {
    let kind = "ViceRecoveryWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ViceRecoveryConfiguration.self, provider: ViceRecoveryProvider()) { entry in
            ViceRecoveryWidgetView(metric: entry.metric)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Recovery")
        .description("Time recovering since your last slip.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct ViceRecoveryProvider: AppIntentTimelineProvider {
    typealias Entry = ViceRecoveryEntry
    typealias Intent = ViceRecoveryConfiguration

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), metric: .placeholder(id: "2", name: "Social media", habitType: "vice", streak: 14, logged: true, recovery: "14d recovering"))
    }

    func snapshot(for configuration: ViceRecoveryConfiguration, in context: Context) async -> Entry {
        Entry(date: Date(), metric: resolvedMetric(configuration: configuration))
    }

    func timeline(for configuration: ViceRecoveryConfiguration, in context: Context) async -> Timeline<Entry> {
        let entry = Entry(date: Date(), metric: resolvedMetric(configuration: configuration))
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(nextHour))
    }

    private func resolvedMetric(configuration: ViceRecoveryConfiguration) -> WidgetMetricSnapshot {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        if let id = configuration.vice?.id, let metric = snapshot.metric(id: id) {
            return metric
        }
        return snapshot.vices().first(where: { $0.recovery != nil })
            ?? snapshot.vices().first
            ?? .placeholder(id: "0", name: "Pick a vice", habitType: "vice", streak: 0, logged: false)
    }
}

struct ViceRecoveryEntry: TimelineEntry {
    let date: Date
    let metric: WidgetMetricSnapshot
}

struct ViceRecoveryWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let metric: WidgetMetricSnapshot

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                WidgetAccessoryViews.recoveryCircular(metric: metric)
            case .accessoryRectangular:
                WidgetAccessoryViews.recoveryRectangular(metric: metric)
            case .accessoryInline:
                WidgetAccessoryViews.recoveryInline(metric: metric)
            default:
                homeScreenBody
            }
        }
        .widgetURL(WidgetDeepLink.home)
    }

    private var homeScreenBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(metric.name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            if metric.showRecoveryTimer, let recovery = metric.recovery {
                Text(recovery.label)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                Text("\(metric.streak.current) clean days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if metric.showRecoveryTimer {
                Text("No slips logged")
                    .font(.headline)
            } else {
                Text("Enable recovery timer in app")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
