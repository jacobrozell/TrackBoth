import Foundation
import SwiftData
import WidgetKit

// MARK: - Widget Integration
/// Handles integration between the main app and widgets.
final class WidgetIntegration {
    static let shared = WidgetIntegration()

    private let widgetDataManager = WidgetDataManager.shared

    private init() {}

    func updateAllData(metrics: [Metric], entries: [MetricEntry]) {
        let snapshot = WidgetSnapshotBuilder.build(metrics: metrics, entries: entries)
        widgetDataManager.saveSnapshot(snapshot)
    }

    func onHabitLogged(metric: Metric, entry: MetricEntry, allMetrics: [Metric], allEntries: [MetricEntry]) {
        updateAllData(metrics: allMetrics, entries: allEntries)
    }

    func onMetricChanged(metric: Metric, entries: [MetricEntry], allMetrics: [Metric]) {
        updateAllData(metrics: allMetrics, entries: entries)
    }

    func onDataImported(metrics: [Metric], entries: [MetricEntry]) {
        updateAllData(metrics: metrics, entries: entries)
    }
}
