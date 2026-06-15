import SwiftData
import SwiftUI

// MARK: - Widget Sync Coordinator
/// Gates widget data sync behind `ProductSurface.showsWidget`.
enum WidgetSyncCoordinator {

    /// Sync full app data to widgets when the widget surface is enabled.
    static func syncIfEnabled(context: ModelContext) {
        guard ProductSurface.showsWidget else { return }

        do {
            let metrics = try MetricStore(context: context).fetchAll(sortedByName: false)
            let entries = try EntryStore(context: context).fetchAll()
            syncAll(metrics: metrics, entries: entries)
        } catch {
            logger.logError(error, context: "Widget sync failed to load store data")
        }
    }

    /// Sync when the caller already holds a full metrics/entries snapshot.
    static func syncIfEnabled(metrics: [Metric], entries: [MetricEntry]) {
        guard ProductSurface.showsWidget else { return }
        syncAll(metrics: metrics, entries: entries)
    }

    static func onHabitLogged(
        metric: Metric,
        entry: MetricEntry,
        context: ModelContext
    ) {
        guard ProductSurface.showsWidget else { return }

        do {
            let metrics = try MetricStore(context: context).fetchAll(sortedByName: false)
            let entries = try EntryStore(context: context).fetchAll()
            WidgetDataSync.shared.onHabitLogged(
                metric: metric,
                entry: entry,
                allMetrics: metrics,
                allEntries: entries
            )
        } catch {
            logger.logError(error, context: "Widget habit-log sync failed to load store data")
        }
    }

    static func onDataChanged(context: ModelContext) {
        guard ProductSurface.showsWidget else { return }

        do {
            let metrics = try MetricStore(context: context).fetchAll(sortedByName: false)
            let entries = try EntryStore(context: context).fetchAll()
            WidgetDataSync.shared.onDataImported(metrics: metrics, entries: entries)
        } catch {
            logger.logError(error, context: "Widget data-change sync failed to load store data")
        }
    }

    static func handleLifecycle(
        phase: ScenePhase,
        context: ModelContext
    ) {
        guard ProductSurface.showsWidget else { return }
        if phase == .active {
            WidgetPendingLogProcessor.drainIfNeeded(context: context)
        }
        WidgetDataSync.shared.handleAppLifecycle(
            phase: phase,
            metrics: (try? MetricStore(context: context).fetchAll(sortedByName: false)) ?? [],
            entries: (try? EntryStore(context: context).fetchAll()) ?? []
        )
    }

    private static func syncAll(metrics: [Metric], entries: [MetricEntry]) {
        WidgetDataSync.shared.syncAllData(metrics: metrics, entries: entries)
    }
}
