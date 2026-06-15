import XCTest
import SwiftData
@testable import TrackBoth

final class WidgetSyncCoordinatorTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Metric.self, MetricEntry.self, Goal.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = ModelContext(container)
    }

    func testSyncRespectsWidgetSurfaceGate() {
        #if DEBUG
        XCTAssertTrue(ProductSurface.showsWidget)
        #else
        XCTAssertFalse(ProductSurface.showsWidget)
        #endif

        MetricStore(context: context).insert(Metric(name: "Read", habitType: .positive))
        WidgetSyncCoordinator.syncIfEnabled(context: context)
        WidgetSyncCoordinator.onDataChanged(context: context)
        WidgetSyncCoordinator.handleLifecycle(phase: .active, context: context)
    }

    func testHabitLoggedSyncRespectsWidgetSurfaceGate() throws {
        let metric = Metric(name: "Read", habitType: .positive)
        MetricStore(context: context).insert(metric)
        let entry = MetricEntry(metricID: metric.id, date: Date(), value: true, hasBeenLogged: true)
        EntryStore(context: context).insert(entry)

        WidgetSyncCoordinator.onHabitLogged(metric: metric, entry: entry, context: context)

        #if DEBUG
        XCTAssertNotNil(WidgetSnapshotStore.load())
        #endif
    }
}
