import Foundation

// MARK: - MilestoneEvaluator
/// Lightweight milestone detection (no full achievement system).
enum MilestoneEvaluator {
    static let thresholds = [7, 14, 30, 60, 90, 365]

    /// Lowest unawarded threshold the current streak has reached.
    static func nextPendingMilestone(streak: Int, awarded: Set<Int>) -> Int? {
        thresholds.first { streak >= $0 && !awarded.contains($0) }
    }

    static func pendingMilestone(
        for metric: Metric,
        entries: [MetricEntry],
        awarded: Set<Int>
    ) -> Int? {
        guard TrackingSemantics.streakEligible(metric: metric) else { return nil }
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries)
        return nextPendingMilestone(streak: streak, awarded: awarded)
    }

    /// First metric with a pending milestone (habits before vices, then name order).
    static func firstPending(
        metrics: [Metric],
        entries: [MetricEntry],
        awardedLookup: (UUID) -> Set<Int>
    ) -> MilestoneAnnouncement? {
        let sorted = metrics.sorted {
            if $0.habitType != $1.habitType {
                return $0.habitType == .positive
            }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }

        for metric in sorted {
            let awarded = awardedLookup(metric.id)
            guard let threshold = pendingMilestone(for: metric, entries: entries, awarded: awarded) else {
                continue
            }
            return MilestoneAnnouncement(
                metricID: metric.id,
                metricName: metric.name,
                habitType: metric.habitType,
                threshold: threshold
            )
        }
        return nil
    }
}

// MARK: - MilestoneAnnouncement
struct MilestoneAnnouncement: Identifiable, Equatable {
    var id: String { "\(metricID.uuidString)-\(threshold)" }
    let metricID: UUID
    let metricName: String
    let habitType: HabitType
    let threshold: Int

    var message: String {
        MilestoneCopy.message(metricName: metricName, habitType: habitType, days: threshold)
    }
}

// MARK: - MilestoneCopy
enum MilestoneCopy {
    static func message(metricName: String, habitType: HabitType, days: Int) -> String {
        switch habitType {
        case .positive:
            return "\(days)-day streak on \(metricName)!"
        case .vice:
            return "\(days) days clean from \(metricName)!"
        }
    }
}
