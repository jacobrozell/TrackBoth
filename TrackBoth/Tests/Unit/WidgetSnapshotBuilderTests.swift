import XCTest
import SwiftData
@testable import TrackBoth

final class WidgetSnapshotBuilderTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Metric.self, MetricEntry.self, Goal.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = ModelContext(container)
    }

    func testBuildsTodaySummaryAndStreak() throws {
        let metric = Metric(name: "Exercise", habitType: .positive)
        metric.hasBeenLogged = true
        MetricStore(context: context).insert(metric)

        let today = Calendar.current.startOfDay(for: Date())
        let entry = MetricEntry(metricID: metric.id, date: today, value: true, hasBeenLogged: true)
        EntryStore(context: context).insert(entry)

        let snapshot = WidgetSnapshotBuilder.build(
            metrics: [metric],
            entries: [entry]
        )

        XCTAssertEqual(snapshot.today.completedCount, 1)
        XCTAssertEqual(snapshot.today.totalCount, 1)
        XCTAssertEqual(snapshot.metrics.first?.streak.current, 1)
        XCTAssertTrue(snapshot.metrics.first?.today.isSuccess == true)
    }

    func testBuildsRecoveryForViceWithSlip() throws {
        let metric = Metric(name: "Social media", habitType: .vice)
        metric.hasBeenLogged = true
        MetricStore(context: context).insert(metric)
        MetricDisplayPreferences.setShowTimeSinceSlip(true, for: metric.id)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let slipDay = calendar.date(byAdding: .day, value: -7, to: today) else {
            XCTFail("Could not build slip day")
            return
        }
        _ = slipDay
        let entries = (0...7).compactMap { offset -> MetricEntry? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            if offset == 7 {
                return MetricEntry(metricID: metric.id, date: day, value: true, hasBeenLogged: true)
            }
            return MetricEntry(metricID: metric.id, date: day, value: false, hasBeenLogged: true)
        }
        entries.forEach { EntryStore(context: context).insert($0) }

        let snapshot = WidgetSnapshotBuilder.build(metrics: [metric], entries: entries)

        XCTAssertEqual(snapshot.metrics.first?.recovery?.compactLabel, "7d recovering")
        XCTAssertEqual(snapshot.metrics.first?.streak.current, 7)
    }

    func testBuildsGoalSnapshot() throws {
        let metric = Metric(name: "Exercise", habitType: .positive)
        metric.hasBeenLogged = true
        MetricStore(context: context).insert(metric)

        let goal = Goal(goalType: .boolean, period: .monthly, target: 20)
        goal.metric = metric
        metric.goals?.append(goal)
        context.insert(goal)

        let today = Calendar.current.startOfDay(for: Date())
        let entry = MetricEntry(metricID: metric.id, date: today, value: true, hasBeenLogged: true)
        EntryStore(context: context).insert(entry)

        let snapshot = WidgetSnapshotBuilder.build(metrics: [metric], entries: [entry])
        XCTAssertEqual(snapshot.metrics.first?.goal?.target, 20)
        XCTAssertEqual(snapshot.metrics.first?.goal?.current, 1)
    }

    func testBuildsSavingsSnapshot() throws {
        let metric = Metric(name: "Smoking", habitType: .vice)
        metric.hasBeenLogged = true
        MetricStore(context: context).insert(metric)
        metric.setCostPerUnitDecimal(12)

        let today = Calendar.current.startOfDay(for: Date())
        let entry = MetricEntry(metricID: metric.id, date: today, value: false, hasBeenLogged: true)
        EntryStore(context: context).insert(entry)

        let snapshot = WidgetSnapshotBuilder.build(metrics: [metric], entries: [entry])
        XCTAssertEqual(snapshot.metrics.first?.savings?.label, "$12 saved")
    }

    func testSnapshotToggleSemanticsForVice() {
        var snapshot = WidgetSnapshotV1.placeholder
        guard let vice = snapshot.vices().first else {
            XCTFail("Missing vice placeholder")
            return
        }
        XCTAssertTrue(vice.today.isSuccess)

        let storedValue = snapshot.applyQuickToggle(metricID: vice.id)
        XCTAssertEqual(storedValue, true)
        XCTAssertFalse(snapshot.metric(id: vice.id)?.today.isSuccess == true)
    }
}
