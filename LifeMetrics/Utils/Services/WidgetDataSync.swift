import SwiftUI
import SwiftData
import WidgetKit

// MARK: - Widget Data Sync
/// Handles automatic synchronization of app data with widgets
class WidgetDataSync: ObservableObject {
    static let shared = WidgetDataSync()
    
    private let widgetIntegration = WidgetIntegration.shared
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Sync all data with widgets
    func syncAllData(metrics: [Metric], entries: [MetricEntry]) {
        logger.info("Syncing all data with widgets - Metrics: \(metrics.count), Entries: \(entries.count)", category: .widget)
        let startTime = Date()
        
        widgetIntegration.updateAllData(metrics: metrics, entries: entries)
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("Widget data sync", duration: duration)
        logger.debug("Widget data sync completed", category: .widget)
    }
    
    /// Sync when a habit is logged
    func onHabitLogged(metric: Metric, entry: MetricEntry, allMetrics: [Metric], allEntries: [MetricEntry]) {
        logger.logUserAction("Habit logged - syncing with widgets", details: "Metric: \(metric.name)")
        widgetIntegration.onHabitLogged(metric: metric, entry: entry)
        syncAllData(metrics: allMetrics, entries: allEntries)
    }
    
    /// Sync when a metric is created or updated
    func onMetricChanged(metric: Metric, allMetrics: [Metric], allEntries: [MetricEntry]) {
        logger.logUserAction("Metric changed - syncing with widgets", details: "Metric: \(metric.name)")
        widgetIntegration.onMetricChanged(metric: metric, entries: allEntries)
        syncAllData(metrics: allMetrics, entries: allEntries)
    }
    
    /// Sync when data is imported or restored
    func onDataImported(metrics: [Metric], entries: [MetricEntry]) {
        widgetIntegration.onDataImported(metrics: metrics, entries: entries)
    }
    
    /// Sync when app becomes active
    func onAppBecameActive(metrics: [Metric], entries: [MetricEntry]) {
        syncAllData(metrics: metrics, entries: entries)
    }
}

// MARK: - View Model Integration
/// Extension to easily integrate widget sync with existing view models
extension WidgetDataSync {
    
    /// Call this in HomeViewModel when a habit is toggled
    func syncHabitToggle(metric: Metric, entry: MetricEntry, allMetrics: [Metric], allEntries: [MetricEntry]) {
        onHabitLogged(metric: metric, entry: entry, allMetrics: allMetrics, allEntries: allEntries)
    }
    
    /// Call this in SettingsViewModel when data is exported/imported
    func syncDataChange(metrics: [Metric], entries: [MetricEntry]) {
        onDataImported(metrics: metrics, entries: entries)
    }
    
    /// Call this in any view model when metrics are modified
    func syncMetricChange(metrics: [Metric], entries: [MetricEntry]) {
        syncAllData(metrics: metrics, entries: entries)
    }
}

// MARK: - App Lifecycle Integration
/// Handles widget updates based on app lifecycle events
extension WidgetDataSync {
    
    /// Call this in the main app's onAppear or scene phase changes
    func handleAppLifecycle(phase: ScenePhase, metrics: [Metric], entries: [MetricEntry]) {
        switch phase {
        case .active:
            onAppBecameActive(metrics: metrics, entries: entries)
        case .background:
            // Optional: Sync when going to background
            syncAllData(metrics: metrics, entries: entries)
        case .inactive:
            break
        @unknown default:
            break
        }
    }
}
