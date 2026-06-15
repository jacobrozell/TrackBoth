import Foundation
import SwiftData

// MARK: - Migration Utilities
/// Handles data migration for the logged status feature
struct MigrationUtils {

    /// Whether a legacy entry should be promoted to `hasBeenLogged` during migration.
    /// Motivation-only rows are excluded to avoid phantom vice avoidances.
    static func shouldMigrateEntryToLogged(_ entry: MetricEntry) -> Bool {
        if entry.hasBeenLogged { return false }
        if entry.hasQuantity { return true }
        if let details = entry.details, !details.isEmpty { return true }
        if let motivation = entry.motivation, !motivation.isEmpty { return false }
        return true
    }

    /// Migrate metrics to set hasBeenLogged based on existing logged entries
    static func migrateLoggedStatus(in modelContext: ModelContext) {
        logger.info("Starting logged status migration", category: .data)
        let startTime = Date()

        do {
            let metrics = try modelContext.fetch(FetchDescriptor<Metric>())
            let entries = try modelContext.fetch(FetchDescriptor<MetricEntry>())

            var updatedMetrics = 0
            var updatedEntries = 0

            for entry in entries where shouldMigrateEntryToLogged(entry) {
                entry.hasBeenLogged = true
                updatedEntries += 1
            }

            let loggedMetricIDs = Set(
                entries
                    .filter { $0.hasBeenLogged }
                    .map(\.metricID)
            )

            for metric in metrics where !metric.hasBeenLogged {
                if loggedMetricIDs.contains(metric.id) {
                    metric.hasBeenLogged = true
                    updatedMetrics += 1
                }
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
            let entries = try modelContext.fetch(FetchDescriptor<MetricEntry>())

            if metrics.contains(where: { !$0.hasBeenLogged }) {
                if entries.contains(where: \.hasBeenLogged) {
                    return true
                }
                if entries.contains(where: shouldMigrateEntryToLogged) {
                    return true
                }
            }

            return entries.contains(where: shouldMigrateEntryToLogged)
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
