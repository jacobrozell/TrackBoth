import Foundation
import SwiftData

// MARK: - Migration Utilities
/// Handles data migration for the logged status feature
struct MigrationUtils {

    /// Migrate metrics to set hasBeenLogged based on existing logged entries
    static func migrateLoggedStatus(in modelContext: ModelContext) {
        logger.info("Starting logged status migration", category: .data)
        let startTime = Date()

        do {
            let metrics = try modelContext.fetch(FetchDescriptor<Metric>())
            let entries = try modelContext.fetch(FetchDescriptor<MetricEntry>())

            var updatedMetrics = 0
            var updatedEntries = 0

            let loggedMetricIDs = Set(
                entries
                    .filter { $0.hasBeenLogged || $0.hasContent }
                    .map(\.metricID)
            )

            for metric in metrics where !metric.hasBeenLogged {
                if loggedMetricIDs.contains(metric.id) {
                    metric.hasBeenLogged = true
                    updatedMetrics += 1
                }
            }

            for entry in entries where !entry.hasBeenLogged && entry.hasContent {
                entry.hasBeenLogged = true
                updatedEntries += 1
            }

            try modelContext.save()

            let duration = Date().timeIntervalSince(startTime)
            logger.logPerformance("Logged status migration", duration: duration)
            logger.info(
                "Migration completed - Updated \(updatedMetrics) metrics, \(updatedEntries) entries",
                category: .data
            )
        } catch {
            logger.error("Migration failed: \(error.localizedDescription)", category: .data)
        }
    }

    /// Check if migration is needed
    static func needsMigration(in modelContext: ModelContext) -> Bool {
        do {
            let metrics = try modelContext.fetch(FetchDescriptor<Metric>())
            if metrics.contains(where: { !$0.hasBeenLogged }) {
                let entries = try modelContext.fetch(FetchDescriptor<MetricEntry>())
                if entries.contains(where: { $0.hasBeenLogged || $0.hasContent }) {
                    return true
                }
            }

            let entries = try modelContext.fetch(FetchDescriptor<MetricEntry>())
            return entries.contains { !$0.hasBeenLogged && $0.hasContent }
        } catch {
            logger.error("Failed to check migration status: \(error.localizedDescription)", category: .data)
            return false
        }
    }

    /// Run migration if needed
    static func runMigrationIfNeeded(in modelContext: ModelContext) {
        if needsMigration(in: modelContext) {
            logger.info("Running logged status migration", category: .data)
            migrateLoggedStatus(in: modelContext)
        } else {
            logger.info("No migration needed", category: .data)
        }
    }
}
