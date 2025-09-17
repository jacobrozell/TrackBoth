import Foundation
import SwiftData

// MARK: - Migration Utilities
/// Handles data migration for the logged status feature
struct MigrationUtils {
    
    /// Migrate existing metrics to set hasBeenLogged based on existing entries
    static func migrateLoggedStatus(in modelContext: ModelContext) {
        logger.info("Starting logged status migration", category: .data)
        let startTime = Date()
        
        do {
            // Fetch all entries
            let entriesDescriptor = FetchDescriptor<MetricEntry>()
            let entries = try modelContext.fetch(entriesDescriptor)
            
            var updatedMetricsCount = 0
            
            // Update metrics based on existing entries
            for entry in entries {
                if !entry.hasBeenLogged {
                    entry.hasBeenLogged = true
                    updatedMetricsCount += 1
                    logger.debug("Updated entry for metric '\(entry.metricID)' to hasBeenLogged=true", category: .data)
                }
            }

            // Save changes
            try modelContext.save()
            
            let duration = Date().timeIntervalSince(startTime)
            logger.logPerformance("Logged status migration", duration: duration)
            logger.info("Migration completed successfully - Updated \(updatedMetricsCount) metrics", category: .data)
            
        } catch {
            logger.error("Migration failed: \(error.localizedDescription)", category: .data)
        }
    }
    
    /// Check if migration is needed
    static func needsMigration(in modelContext: ModelContext) -> Bool {
        do {
            let entriesDescriptor = FetchDescriptor<MetricEntry>()
            let entries = try modelContext.fetch(entriesDescriptor)
            
            for entry in entries {
                if !entry.hasBeenLogged {
                    logger.debug("Migration needed - Entry for metric '\(entry.metricID)' has hasBeenLogged=false", category: .data)
                    return true
                }
            }
            
            return false
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
    
    /// Force run migration (for testing/debugging)
    static func forceMigration(in modelContext: ModelContext) {
        logger.info("Force running logged status migration", category: .data)
        migrateLoggedStatus(in: modelContext)
    }
}
