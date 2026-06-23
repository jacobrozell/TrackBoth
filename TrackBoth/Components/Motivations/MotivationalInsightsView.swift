import SwiftUI

// MARK: - MotivationalInsightsView Component
struct MotivationalInsightsView: View {
    let entries: [MetricEntry]
    let metrics: [Metric]
    let filter: MetricFilter
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animateInsights = false
    
    private var insights: [Insight] {
        var insights: [Insight] = []
        
        // Calculate basic stats
        let loggedEntries = entries.filter { entry in
            matchesFilter(entry: entry) && TrackingSemantics.isLoggedForDay(entry: entry)
        }
        let successfulEntries = loggedEntries.filter(isLoggedSuccessfulEntry)
        let successRate = loggedEntries.isEmpty
            ? 0
            : Double(successfulEntries.count) / Double(loggedEntries.count)
        
        // Current streak
        let currentStreak = calculateCurrentStreak()
        if currentStreak > 0 {
            insights.append(Insight(
                type: .streak,
                title: streakTitle,
                value: "\(currentStreak) days",
                description: streakDescription(currentStreak),
                icon: streakIcon,
                color: .currentWarning
            ))
        }
        
        // Weekly completion
        let weeklyCompletion = calculateWeeklyCompletion()
        if weeklyCompletion > 0 {
            insights.append(Insight(
                type: .weekly,
                title: weeklyTitle,
                value: "\(weeklyCompletion) \(weeklyValueLabel)",
                description: weeklyDescription(weeklyCompletion),
                icon: weeklyIcon,
                color: .currentSuccess
            ))
        }
        
        // Success rate
        if successRate > 0 {
            insights.append(Insight(
                type: .consistency,
                title: consistencyTitle,
                value: "\(Int(successRate * 100))%",
                description: consistencyDescription(successRate),
                icon: "percent",
                color: .currentPrimary
            ))
        }
        
        // Best day
        let bestDay = findBestDay()
        if let bestDay = bestDay {
            insights.append(Insight(
                type: .bestDay,
                title: bestDayTitle,
                value: "\(bestDay.count) \(bestDayValueLabel)",
                description: "On \(bestDay.dayName)",
                icon: "star.fill",
                color: .currentWarning
            ))
        }
        
        return insights
    }
    
    private func matchesFilter(entry: MetricEntry) -> Bool {
        FilterUtils.matchesFilter(filter, entry: entry, metrics: metrics)
    }
    
    private func isLoggedSuccessfulEntry(_ entry: MetricEntry) -> Bool {
        guard let metric = metrics.first(where: { $0.id == entry.metricID }) else { return false }
        return TrackingSemantics.isLoggedForDay(entry: entry)
            && TrackingSemantics.isSuccessful(habitType: metric.habitType, value: entry.value)
    }
    
    private var consistencyTitle: String {
        switch filter {
        case .allVices:
            return "Avoidance Rate"
        case .allHabits:
            return "Completion Rate"
        case .all:
            return "Success Rate"
        case .specific(let metric):
            return metric.habitType == .vice ? "Avoidance Rate" : "Completion Rate"
        }
    }
    
    private var streakTitle: String {
        switch filter {
        case .allVices:
            return "Clean Streak"
        case .allHabits:
            return "Current Streak"
        case .all:
            return "Current Streak"
        case .specific(let metric):
            return metric.habitType == .vice ? "Clean Streak" : "Current Streak"
        }
    }
    
    private var streakIcon: String {
        switch filter {
        case .allVices:
            return "shield.checkered"
        case .allHabits:
            return "flame.fill"
        case .all:
            return "flame.fill"
        case .specific(let metric):
            return metric.habitType == .vice ? "shield.checkered" : "flame.fill"
        }
    }
    
    private var weeklyTitle: String {
        switch filter {
        case .allVices:
            return "This Week"
        case .allHabits:
            return "This Week"
        case .all:
            return "This Week"
        case .specific(_):
            return "This Week"
        }
    }
    
    private var weeklyValueLabel: String {
        switch filter {
        case .allVices:
            return "avoidances"
        case .allHabits:
            return "habits"
        case .all:
            return "successes"
        case .specific(let metric):
            return metric.habitType == .vice ? "avoidances" : "habits"
        }
    }
    
    private var weeklyIcon: String {
        switch filter {
        case .allVices:
            return "calendar.badge.minus"
        case .allHabits:
            return "calendar.badge.checkmark"
        case .all:
            return "calendar.badge.checkmark"
        case .specific(let metric):
            return metric.habitType == .vice ? "calendar.badge.minus" : "calendar.badge.checkmark"
        }
    }
    
    private var bestDayTitle: String {
        switch filter {
        case .allVices:
            return "Best Avoidance Day"
        case .allHabits:
            return "Best Day"
        case .all:
            return "Best Day"
        case .specific(let metric):
            return metric.habitType == .vice ? "Best Avoidance Day" : "Best Day"
        }
    }
    
    private var bestDayValueLabel: String {
        switch filter {
        case .allVices:
            return "avoidances"
        case .allHabits:
            return "habits"
        case .all:
            return "successes"
        case .specific(let metric):
            return metric.habitType == .vice ? "avoidances" : "habits"
        }
    }
    
    private func calculateCurrentStreak() -> Int {
        StreakUtils.calculateFilterCurrentStreak(filter: filter, metrics: metrics, entries: entries)
    }

    private func calculateWeeklyCompletion() -> Int {
        let startOfWeek = CalendarHelper.startOfWeek(for: Date())
        let endOfWeek = CalendarHelper.endOfWeek(for: Date())

        return entries.filter { entry in
            entry.date >= startOfWeek &&
            entry.date < endOfWeek &&
            matchesFilter(entry: entry) &&
            isLoggedSuccessfulEntry(entry)
        }.count
    }

    private func findBestDay() -> (count: Int, dayName: String)? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"

        var dayCounts: [String: Int] = [:]

        for entry in entries where matchesFilter(entry: entry) && isLoggedSuccessfulEntry(entry) {
            let dayName = formatter.string(from: entry.date)
            dayCounts[dayName, default: 0] += 1
        }
        
        if let bestDay = dayCounts.max(by: { $0.value < $1.value }) {
            return (count: bestDay.value, dayName: bestDay.key)
        }
        
        return nil
    }
    
    private func streakDescription(_ streak: Int) -> String {
        let isViceFilter = isViceFilter()
        switch streak {
        case 1...3:
            return isViceFilter ? "Great start! Keep avoiding" : "Great start! Keep the momentum going"
        case 4...7:
            return isViceFilter ? "You're building strong resistance!" : "You're building a solid habit!"
        case 8...14:
            return isViceFilter ? "Excellent self-control!" : "Excellent consistency!"
        case 15...30:
            return isViceFilter ? "Outstanding willpower!" : "Outstanding dedication!"
        default:
            return isViceFilter ? "You're a vice-master!" : "You're a habit master!"
        }
    }
    
    private func weeklyDescription(_ count: Int) -> String {
        let isViceFilter = isViceFilter()
        switch count {
        case 0...5:
            return isViceFilter ? "Every avoidance counts!" : "Every habit counts!"
        case 6...15:
            return isViceFilter ? "Good resistance this week" : "Good progress this week"
        case 16...25:
            return isViceFilter ? "Excellent self-control!" : "Excellent week!"
        default:
            return isViceFilter ? "Amazing willpower!" : "Amazing dedication!"
        }
    }
    
    private func consistencyDescription(_ rate: Double) -> String {
        let isViceFilter = isViceFilter()
        switch rate {
        case 0..<0.3:
            return isViceFilter ? "Room for improvement" : "Room for improvement"
        case 0.3..<0.6:
            return isViceFilter ? "Building resistance!" : "Getting there!"
        case 0.6..<0.8:
            return isViceFilter ? "Great self-control!" : "Great consistency!"
        default:
            return isViceFilter ? "Outstanding willpower!" : "Outstanding!"
        }
    }
    
    private func isViceFilter() -> Bool {
        switch filter {
        case .allVices:
            return true
        case .allHabits:
            return false
        case .all:
            return false
        case .specific(let metric):
            return metric.habitType == .vice
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Insights")
                    .h4()
                    .foregroundColor(.currentText)
                Spacer()
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.currentWarning)
            }
            
            if insights.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.currentSecondaryText.opacity(0.6))
                    
                    Text("Start tracking to unlock insights")
                        .foregroundColor(.currentSecondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 120)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                    ForEach(Array(insights.enumerated()), id: \.element.type) { index, insight in
                        InsightCard(insight: insight)
                            .trackBothEntrance(isVisible: animateInsights, reduceMotion: reduceMotion)
                            .offset(y: reduceMotion ? 0 : (animateInsights ? 0 : 20))
                            .trackBothAnimation(
                                TrackBothMotion.spring.delay(Double(index) * 0.08),
                                value: animateInsights,
                                reduceMotion: reduceMotion
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color.currentBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .chartVoiceOverSummary(ChartAccessibilitySummary.insightsSummary(insights))
        .onAppear {
            animateInsights = true
        }
    }
}

// MARK: - InsightCard Component
struct InsightCard: View {
    let insight: Insight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.icon)
                    .foregroundColor(insight.color)
                    .font(.title2)
                Spacer()
            }
            
            Text(insight.title)
                .caption()
                .foregroundColor(.currentSecondaryText)
            
            Text(insight.value)
                .h2()
                .foregroundColor(.currentText)
            
            Text(insight.description)
                .captionSmall()
                .foregroundColor(.currentSecondaryText)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(insight.title), \(insight.value), \(insight.description)")
    }
}

// MARK: - Insight Model
struct Insight {
    let type: InsightType
    let title: String
    let value: String
    let description: String
    let icon: String
    let color: Color
}

enum InsightType {
    case streak
    case weekly
    case consistency
    case bestDay
}

#Preview {
    MotivationalInsightsView(
        entries: [],
        metrics: [],
        filter: .all
    )
}
