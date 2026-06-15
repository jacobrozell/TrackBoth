import Foundation

// MARK: - Widget Sync Coordinator
/// Gates widget data sync behind `ProductSurface.showsWidget`.
/// Wire `WidgetDataSync.shared.syncAllData` here when the widget surface ships.
enum WidgetSyncCoordinator {
    static func syncIfEnabled(metrics: [Metric], entries: [MetricEntry]) {
        guard ProductSurface.showsWidget else { return }
        logger.info(
            "Widget sync requested — metrics: \(metrics.count), entries: \(entries.count)",
            category: .widget
        )
    }
}
