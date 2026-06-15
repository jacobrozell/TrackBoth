import XCTest
@testable import TrackBoth

final class WidgetSnapshotSharedTests: XCTestCase {

    override func tearDown() {
        WidgetAppGroup.userDefaults?.removeObject(forKey: WidgetAppGroup.snapshotKey)
        WidgetAppGroup.userDefaults?.removeObject(forKey: WidgetAppGroup.pendingLogsKey)
        super.tearDown()
    }

    func testSnapshotRoundTrip() {
        let snapshot = WidgetSnapshotV1.placeholder
        WidgetSnapshotStore.save(snapshot)
        let loaded = WidgetSnapshotStore.load()
        XCTAssertEqual(loaded?.schemaVersion, snapshot.schemaVersion)
        XCTAssertEqual(loaded?.metrics.count, snapshot.metrics.count)
        XCTAssertEqual(loaded?.today.completedCount, snapshot.today.completedCount)
    }

    func testPendingLogDrain() {
        WidgetPendingLogStore.enqueue(
            WidgetPendingLog(metricID: "abc", day: "2026-06-15", storedValue: true, requestedAt: Date())
        )
        let drained = WidgetPendingLogStore.drain()
        XCTAssertEqual(drained.count, 1)
        XCTAssertTrue(WidgetPendingLogStore.drain().isEmpty)
    }

    func testApplyLogSetsExplicitSuccess() {
        var snapshot = WidgetSnapshotV1.placeholder
        guard let vice = snapshot.vices().first else {
            XCTFail("Missing vice")
            return
        }
        XCTAssertTrue(vice.today.isSuccess)

        let stored = snapshot.applyLog(metricID: vice.id, success: false)
        XCTAssertEqual(stored, true)
        XCTAssertFalse(snapshot.metric(id: vice.id)?.today.isSuccess == true)
    }
}
