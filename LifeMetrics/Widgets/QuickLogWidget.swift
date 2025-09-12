import WidgetKit
import SwiftUI
import SwiftData

// MARK: - QuickLog Widget
/// Main widget configuration for QuickLog
struct QuickLogWidget: Widget {
    let kind: String = "QuickLogWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickLogTimelineProvider()) { entry in
            QuickLogWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("QuickLog")
        .description("Track your habits and vices at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Entry
/// Timeline entry containing widget data
struct QuickLogEntry: TimelineEntry {
    let date: Date
    let metrics: [WidgetMetricData]
    let todaysEntries: [WidgetEntryData]
    let streaks: [WidgetStreakInfo]
    let goals: [WidgetGoalInfo]
}

// MARK: - Timeline Provider
/// Provides timeline entries for the widget
struct QuickLogTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickLogEntry {
        QuickLogEntry(
            date: Date(),
            metrics: [
                WidgetMetricData(id: "1", name: "Exercise", habitType: "positive", isCompletedToday: true, streak: 5),
                WidgetMetricData(id: "2", name: "No Smoking", habitType: "vice", isCompletedToday: false, streak: 3)
            ],
            todaysEntries: [],
            streaks: [],
            goals: []
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuickLogEntry) -> ()) {
        logger.debug("Widget snapshot requested", category: .widget)
        // For preview/snapshot, return placeholder data
        completion(placeholder(in: context))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickLogEntry>) -> ()) {
        logger.info("Widget timeline requested", category: .widget)
        let startTime = Date()
        
        // Load data from App Groups shared container
        let entry = loadWidgetData()
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Widget timeline generation", duration: duration)
        logger.debug("Widget timeline generated - Metrics: \(entry.metrics.count), Entries: \(entry.todaysEntries.count)", category: .widget)
        
        completion(timeline)
    }
    
    private func loadWidgetData() -> QuickLogEntry {
        // Load data from the shared App Groups container
        let dataManager = WidgetDataManager.shared
        let metrics = dataManager.loadMetrics()
        let entries = dataManager.loadEntries()
        let streaks = dataManager.loadStreaks()
        let goals = dataManager.loadGoals()
        
        return QuickLogEntry(
            date: Date(),
            metrics: metrics,
            todaysEntries: entries,
            streaks: streaks,
            goals: goals
        )
    }
}

// MARK: - Widget View
/// Main widget view that adapts to different sizes
struct QuickLogWidgetView: View {
    let entry: QuickLogEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (2x2)
struct SmallWidgetView: View {
    let entry: QuickLogEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("QuickLog")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // Today's Progress
            VStack(spacing: 4) {
                Text("Today")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                let completedCount = entry.metrics.filter { $0.isCompletedToday }.count
                let totalCount = entry.metrics.count
                
                Text("\(completedCount)/\(totalCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("completed")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Medium Widget (4x2)
struct MediumWidgetView: View {
    let entry: QuickLogEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Left side - Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                    Text("QuickLog")
                        .font(.headline)
                    Spacer()
                }
                
                let completedCount = entry.metrics.filter { $0.isCompletedToday }.count
                let totalCount = entry.metrics.count
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(completedCount) of \(totalCount) completed")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ProgressView(value: totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                }
            }
            
            // Right side - Quick actions
            VStack(spacing: 8) {
                Text("Quick Log")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(entry.metrics.prefix(3), id: \.id) { metric in
                    Button(intent: LogHabitIntent(metricID: metric.id, value: !metric.isCompletedToday)) {
                        HStack {
                            Image(systemName: metric.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(metric.habitType == "vice" ? .orange : .green)
                            
                            Text(metric.name)
                                .font(.caption)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }
}

// MARK: - Large Widget (4x4)
struct LargeWidgetView: View {
    let entry: QuickLogEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("QuickLog Dashboard")
                    .font(.headline)
                Spacer()
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress Summary
            HStack(spacing: 16) {
                let completedCount = entry.metrics.filter { $0.isCompletedToday }.count
                let totalCount = entry.metrics.count
                
                VStack {
                    Text("\(completedCount)/\(totalCount)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(entry.streaks.map { $0.currentStreak }.max() ?? 0)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Best Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(entry.goals.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Active Goals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Habits List
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Habits")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(entry.metrics.prefix(5), id: \.id) { metric in
                    Button(intent: LogHabitIntent(metricID: metric.id, value: !metric.isCompletedToday)) {
                        HStack {
                            Image(systemName: metric.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(metric.habitType == "vice" ? .orange : .green)
                            
                            Text(metric.name)
                                .font(.body)
                            
                            Spacer()
                            
                            if metric.streak > 0 {
                                Text("\(metric.streak) day streak")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Widget Bundle
@main
struct QuickLogWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuickLogWidget()
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    QuickLogWidget()
} timeline: {
    QuickLogEntry(
        date: Date(),
        metrics: [
            WidgetMetricData(id: "1", name: "Exercise", habitType: "positive", isCompletedToday: true, streak: 5),
            WidgetMetricData(id: "2", name: "No Smoking", habitType: "vice", isCompletedToday: false, streak: 3)
        ],
        todaysEntries: [],
        streaks: [],
        goals: []
    )
}
