import Foundation
import WidgetKit

// MARK: - Widget Data Manager
/// Persists widget snapshots to the App Group and reloads timelines.
final class WidgetDataManager {
    static let shared = WidgetDataManager()

    private init() {}

    func saveSnapshot(_ snapshot: WidgetSnapshotV1) {
        logger.info("Saving widget snapshot — metrics: \(snapshot.metrics.count)", category: .widget)
        WidgetSnapshotStore.save(snapshot)
        reloadWidgets()
    }

    func loadSnapshot() -> WidgetSnapshotV1? {
        WidgetSnapshotStore.load()
    }

    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
