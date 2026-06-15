import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Week heatmap

struct WidgetWeekHeatmapView: View {
    let week: [Bool?]

    private static let weekdaySymbols: [String] = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.veryShortWeekdaySymbols
    }()

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { index in
                    Text(dayLabel(for: index))
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(color(for: week[safe: index] ?? nil))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }

    private func dayLabel(for index: Int) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let day = calendar.date(byAdding: .day, value: index - 6, to: today) else { return "" }
        let weekday = calendar.component(.weekday, from: day) - 1
        guard weekday >= 0, weekday < Self.weekdaySymbols.count else { return "" }
        return Self.weekdaySymbols[weekday]
    }

    private func color(for value: Bool?) -> Color {
        guard let value else { return Color.gray.opacity(0.25) }
        return value ? .green : .red.opacity(0.85)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Week at a Glance

struct WeekGlanceWidget: Widget {
    let kind = "WeekGlanceWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: WeekGlanceConfiguration.self, provider: WeekGlanceProvider()) { entry in
            WeekGlanceWidgetView(metric: entry.metric)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Week")
        .description("Seven-day history for one metric.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct WeekGlanceProvider: AppIntentTimelineProvider {
    typealias Entry = WeekGlanceEntry
    typealias Intent = WeekGlanceConfiguration

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), metric: .placeholder(id: "1", name: "Exercise", habitType: "positive", streak: 12, logged: true))
    }

    func snapshot(for configuration: WeekGlanceConfiguration, in context: Context) async -> Entry {
        Entry(date: Date(), metric: resolvedMetric(configuration: configuration))
    }

    func timeline(for configuration: WeekGlanceConfiguration, in context: Context) async -> Timeline<Entry> {
        let entry = Entry(date: Date(), metric: resolvedMetric(configuration: configuration))
        let nextRefresh = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }

    private func resolvedMetric(configuration: WeekGlanceConfiguration) -> WidgetMetricSnapshot {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        if let id = configuration.metric?.id, let metric = snapshot.metric(id: id) {
            return metric
        }
        return snapshot.metrics.first
            ?? .placeholder(id: "0", name: "Add a metric", habitType: "positive", streak: 0, logged: false)
    }
}

struct WeekGlanceEntry: TimelineEntry {
    let date: Date
    let metric: WidgetMetricSnapshot
}

struct WeekGlanceWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let metric: WidgetMetricSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(metric.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text("\(metric.streak.current)d")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
            }

            WidgetWeekHeatmapView(week: metric.week)

            if family == .systemLarge {
                HStack {
                    Text(metric.habitType == HabitTypeSnapshot.vice ? "Green = avoided" : "Green = completed")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                    if !metric.today.isSuccess || !metric.today.isLogged {
                        Button(intent: QuickLogIntent(metricID: metric.id)) {
                            Label("Log today", systemImage: "checkmark.circle")
                                .font(.caption)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    } else {
                        Label("Logged today", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .widgetURL(WidgetDeepLink.home)
    }
}

// MARK: - Daily Motivation

struct DailyMotivationWidget: Widget {
    let kind = "DailyMotivationWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: DailyMotivationConfiguration.self, provider: DailyMotivationProvider()) { entry in
            DailyMotivationWidgetView(metric: entry.metric)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Why")
        .description("Your reason, on the Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DailyMotivationProvider: AppIntentTimelineProvider {
    typealias Entry = DailyMotivationEntry
    typealias Intent = DailyMotivationConfiguration

    func placeholder(in context: Context) -> Entry {
        Entry(
            date: Date(),
            metric: .placeholder(
                id: "2",
                name: "Smoking",
                habitType: "vice",
                streak: 21,
                logged: true,
                primaryMotivation: "Breathe easier. Save for travel."
            )
        )
    }

    func snapshot(for configuration: DailyMotivationConfiguration, in context: Context) async -> Entry {
        Entry(date: Date(), metric: resolvedMetric(configuration: configuration))
    }

    func timeline(for configuration: DailyMotivationConfiguration, in context: Context) async -> Timeline<Entry> {
        let entry = Entry(date: Date(), metric: resolvedMetric(configuration: configuration))
        let nextRefresh = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date().addingTimeInterval(3600)
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }

    private func resolvedMetric(configuration: DailyMotivationConfiguration) -> WidgetMetricSnapshot {
        let snapshot = WidgetSnapshotStore.load() ?? .placeholder
        if let id = configuration.metric?.id, let metric = snapshot.metric(id: id) {
            return metric
        }
        return snapshot.metricsWithMotivation().first
            ?? .placeholder(id: "0", name: "Add motivation", habitType: "vice", streak: 0, logged: false)
    }
}

struct DailyMotivationEntry: TimelineEntry {
    let date: Date
    let metric: WidgetMetricSnapshot
}

struct DailyMotivationWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let metric: WidgetMetricSnapshot

    var body: some View {
        Group {
            if let motivation = metric.primaryMotivation, !motivation.isEmpty {
                if family == .systemMedium {
                    mediumContent(motivation: motivation)
                } else {
                    smallContent(motivation: motivation)
                }
            } else {
                emptyContent
            }
        }
        .widgetURL(WidgetDeepLink.home)
    }

    private func smallContent(motivation: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("“\(motivation)”")
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(5)
                .minimumScaleFactor(0.85)
            Spacer(minLength: 0)
            Text(metric.name)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func mediumContent(motivation: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("“\(motivation)”")
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(4)
            HStack {
                Label("\(metric.streak.current)d", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Spacer(minLength: 0)
                Button(intent: QuickLogIntent(metricID: metric.id)) {
                    Label("Log", systemImage: "checkmark.circle")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
            Text(metric.name)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Why")
                .font(.headline)
            Text("Add a motivation in app")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
