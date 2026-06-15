import XCTest
@testable import TrackBoth

final class MilestoneEvaluatorTests: XCTestCase {
    func testNextPendingMilestoneReturnsLowestUnawarded() {
        XCTAssertEqual(MilestoneEvaluator.nextPendingMilestone(streak: 10, awarded: []), 7)
        XCTAssertNil(MilestoneEvaluator.nextPendingMilestone(streak: 10, awarded: [7]))
        XCTAssertEqual(MilestoneEvaluator.nextPendingMilestone(streak: 14, awarded: [7]), 14)
        XCTAssertNil(MilestoneEvaluator.nextPendingMilestone(streak: 5, awarded: []))
    }

    func testMilestoneCopyForHabitAndVice() {
        XCTAssertEqual(
            MilestoneCopy.message(metricName: "Exercise", habitType: .positive, days: 7),
            "7-day streak on Exercise!"
        )
        XCTAssertEqual(
            MilestoneCopy.message(metricName: "Smoking", habitType: .vice, days: 14),
            "14 days clean from Smoking!"
        )
    }

    func testFirstPendingReturnsHabitBeforeVice() {
        let habit = Metric(name: "Zebra", habitType: .positive)
        habit.hasBeenLogged = true
        let vice = Metric(name: "Alpha", habitType: .vice)
        vice.hasBeenLogged = true

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var entries: [MetricEntry] = []
        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            entries.append(MetricEntry(metricID: habit.id, date: day, value: true, hasBeenLogged: true))
            entries.append(MetricEntry(metricID: vice.id, date: day, value: false, hasBeenLogged: true))
        }

        let announcement = MilestoneEvaluator.firstPending(
            metrics: [vice, habit],
            entries: entries,
            awardedLookup: { _ in [] }
        )

        XCTAssertEqual(announcement?.metricName, "Zebra")
        XCTAssertEqual(announcement?.threshold, 7)
    }

    func testBackdatedEntriesDoNotAwardFalseMilestones() {
        let vice = Metric(name: "Snacks", habitType: .vice)
        vice.hasBeenLogged = true

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var entries: [MetricEntry] = []

        // Only log 3 consecutive avoided days — not enough for 7-day milestone
        for offset in 0..<3 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            entries.append(MetricEntry(metricID: vice.id, date: day, value: false, hasBeenLogged: true))
        }

        let announcement = MilestoneEvaluator.firstPending(
            metrics: [vice],
            entries: entries,
            awardedLookup: { _ in [] }
        )

        XCTAssertNil(announcement)
    }
}
