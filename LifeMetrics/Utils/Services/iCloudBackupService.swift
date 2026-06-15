import Foundation
import UIKit
import CloudKit
import SwiftData

// MARK: - iCloud Backup Service
/// Service for backing up and restoring app data to/from iCloud
@Observable
class iCloudBackupService {

    private static let containerIdentifier = "iCloud.com.jacobrozell.TrackBoth"

    private var cloudContainer: CKContainer {
        CKContainer(identifier: Self.containerIdentifier)
    }

    private func cloudDatabase() -> CKDatabase {
        cloudContainer.privateCloudDatabase
    }
    
    // MARK: - Backup Data Models
    struct BackupData: Codable {
        let version: String
        let timestamp: Date
        let metrics: [BackupMetric]
        let entries: [BackupEntry]
        let deviceInfo: DeviceInfo
        
        struct DeviceInfo: Codable {
            let deviceName: String
            let systemVersion: String
            let appVersion: String
        }
    }
    
    struct BackupMetric: Codable {
        let id: String
        let name: String
        let createdAt: Date
        let habitType: String?
        let primaryMotivation: String?
        let costPerUnit: String?
        let goals: [BackupGoal]
    }
    
    struct BackupGoal: Codable {
        let id: String
        let goalType: String
        let period: String
        let target: Int
        let createdAt: Date
        let quantityGoalType: String?
        let defaultUnit: String?
        let maxDailyQuantity: Int?
    }
    
    struct BackupEntry: Codable {
        let id: String
        let metricID: String
        let date: Date
        let value: Bool
        let motivation: String?
        let starred: Bool?
        let details: String?
        let quantity: Int?
        let unit: String?
        let mood: String?
    }
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Backup Methods
    
    /// Create a backup of all app data
    func createBackup(metrics: [Metric], entries: [MetricEntry]) async throws -> BackupData {
        logger.info("Creating iCloud backup - Metrics: \(metrics.count), Entries: \(entries.count)", category: .network)
        let startTime = Date()
        
        let backupMetrics = metrics.map { metric in
            let backupGoals = metric.goals?.map { goal in
                BackupGoal(
                    id: goal.id.uuidString,
                    goalType: goal.goalType.rawValue,
                    period: goal.period.rawValue,
                    target: goal.target,
                    createdAt: goal.createdAt,
                    quantityGoalType: goal.quantityGoalType?.rawValue,
                    defaultUnit: goal.defaultUnit,
                    maxDailyQuantity: goal.maxDailyQuantity
                )
            } ?? []
            
            return BackupMetric(
                id: metric.id.uuidString,
                name: metric.name,
                createdAt: metric.createdAt,
                habitType: metric.habitType.rawValue,
                primaryMotivation: metric.primaryMotivation,
                costPerUnit: MetricCostStore.encodedCostPerUnit(for: metric.id),
                goals: backupGoals
            )
        }
        
        let backupEntries = entries.map { entry in
            BackupEntry(
                id: entry.id.uuidString,
                metricID: entry.metricID.uuidString,
                date: entry.date,
                value: entry.value,
                motivation: entry.motivation,
                starred: entry.starred,
                details: entry.details,
                quantity: entry.quantity,
                unit: entry.unit,
                mood: entry.mood
            )
        }
        
        let deviceInfo = await BackupData.DeviceInfo(
            deviceName: UIDevice.current.name,
            systemVersion: UIDevice.current.systemVersion,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        )
        
        let backupData = BackupData(
            version: "1.0",
            timestamp: Date(),
            metrics: backupMetrics,
            entries: backupEntries,
            deviceInfo: deviceInfo
        )
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("iCloud backup creation", duration: duration)
        logger.info("iCloud backup created successfully - Size: \(backupMetrics.count) metrics, \(backupEntries.count) entries", category: .network)
        
        return backupData
    }
    
    /// Upload backup to iCloud
    func uploadBackup(_ backupData: BackupData) async throws {
        logger.info("Uploading backup to iCloud - Timestamp: \(DateFormatter.dateFormatter.string(from: backupData.timestamp))", category: .network)
        let startTime = Date()
        
        let record = CKRecord(recordType: "TrackBothBackup")
        record["timestamp"] = backupData.timestamp
        record["version"] = backupData.version
        
        // Convert to JSON data
        let jsonData = try JSONEncoder().encode(backupData)
        let asset = CKAsset(fileURL: try saveToTemporaryFile(jsonData))
        record["backupData"] = asset
        
        try await cloudDatabase().save(record)
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("iCloud backup upload", duration: duration)
        logger.info("Backup uploaded to iCloud successfully", category: .network)
    }
    
    /// Download latest backup from iCloud
    func downloadLatestBackup() async throws -> BackupData {
        let query = CKQuery(recordType: "TrackBothBackup", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        let results = try await cloudDatabase().records(matching: query)
        
        guard let record = results.matchResults.first?.1,
              case .success(let recordData) = record else {
            throw BackupError.noBackupFound
        }
        
        guard let asset = recordData["backupData"] as? CKAsset,
              let fileURL = asset.fileURL else {
            throw BackupError.invalidBackupData
        }
        
        let jsonData = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(BackupData.self, from: jsonData)
    }
    
    /// Restore data from backup
    func restoreFromBackup(_ backupData: BackupData, context: ModelContext) throws {
        logger.info("Restoring data from iCloud backup - Metrics: \(backupData.metrics.count), Entries: \(backupData.entries.count)", category: .network)
        let startTime = Date()
        
        // Clear existing data
        try clearAllData(context: context)
        MetricCostStore.clearAll()
        MetricDisplayPreferences.clearAll()

        // Restore metrics
        for backupMetric in backupData.metrics {
            let metric = Metric(
                name: backupMetric.name,
                habitType: HabitType(rawValue: backupMetric.habitType ?? "positive") ?? .positive,
                primaryMotivation: backupMetric.primaryMotivation
            )
            
            // Set the original ID
            metric.id = UUID(uuidString: backupMetric.id) ?? UUID()
            MetricCostStore.applyEncodedCostPerUnit(backupMetric.costPerUnit, for: metric.id)

            // Restore goals
            for backupGoal in backupMetric.goals {
                let goal = Goal(
                    goalType: GoalType(rawValue: backupGoal.goalType) ?? .boolean,
                    period: GoalPeriod(rawValue: backupGoal.period) ?? .monthly,
                    target: backupGoal.target,
                    quantityGoalType: backupGoal.quantityGoalType != nil ? QuantityGoalType(rawValue: backupGoal.quantityGoalType!) : nil,
                    defaultUnit: backupGoal.defaultUnit,
                    maxDailyQuantity: backupGoal.maxDailyQuantity
                )
                
                goal.id = UUID(uuidString: backupGoal.id) ?? UUID()
                goal.createdAt = backupGoal.createdAt
                goal.metric = metric
                metric.goals?.append(goal)
                context.insert(goal)
            }
            
            context.insert(metric)
        }
        
        // Restore entries
        for backupEntry in backupData.entries {
            let entry = MetricEntry(
                metricID: UUID(uuidString: backupEntry.metricID) ?? UUID(),
                date: backupEntry.date,
                value: backupEntry.value,
                motivation: backupEntry.motivation,
                starred: backupEntry.starred,
                details: backupEntry.details,
                quantity: backupEntry.quantity,
                unit: backupEntry.unit,
                mood: backupEntry.mood,
                hasBeenLogged: true
            )

            // Set the original ID
            entry.id = UUID(uuidString: backupEntry.id) ?? UUID()
            context.insert(entry)
        }

        let restoredMetrics = try context.fetch(FetchDescriptor<Metric>())
        let loggedMetricIDs = Set(backupData.entries.map(\.metricID))
        for metric in restoredMetrics where loggedMetricIDs.contains(metric.id.uuidString) {
            metric.hasBeenLogged = true
        }

        try context.save()
        
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("iCloud backup restore", duration: duration)
        logger.info("Data restored from iCloud backup successfully - Restored \(backupData.metrics.count) metrics and \(backupData.entries.count) entries", category: .network)
    }
    
    /// Check if iCloud is available
    func checkiCloudAvailability() async -> Bool {
        do {
            let status = try await cloudContainer.accountStatus()
            return status == .available
        } catch {
            return false
        }
    }
    
    /// Get backup info
    func getBackupInfo() async throws -> BackupInfo {
        guard await checkiCloudAvailability() else {
            throw BackupError.iCloudUnavailable
        }

        let query = CKQuery(recordType: "TrackBothBackup", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        let results = try await cloudDatabase().records(matching: query)
        
        guard let record = results.matchResults.first?.1,
              case .success(let recordData) = record else {
            throw BackupError.noBackupFound
        }
        
        let timestamp = recordData["timestamp"] as? Date ?? Date()
        let version = recordData["version"] as? String ?? "Unknown"
        
        return BackupInfo(
            timestamp: timestamp,
            version: version,
            recordID: recordData.recordID.recordName
        )
    }
    
    // MARK: - Private Methods
    
    private func saveToTemporaryFile(_ data: Data) throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
        try data.write(to: tempURL)
        return tempURL
    }
    
    private func clearAllData(context: ModelContext) throws {
        // Get all metrics and entries
        let metrics = try context.fetch(FetchDescriptor<Metric>())
        let entries = try context.fetch(FetchDescriptor<MetricEntry>())
        
        // Delete all entries first
        for entry in entries {
            context.delete(entry)
        }
        
        // Delete all metrics
        for metric in metrics {
            context.delete(metric)
        }
        
        // Save changes
        try context.save()
    }
}

// MARK: - Backup Info Model
struct BackupInfo {
    let timestamp: Date
    let version: String
    let recordID: String
}

// MARK: - Backup Errors
enum BackupError: LocalizedError {
    case noBackupFound
    case invalidBackupData
    case iCloudUnavailable
    case restoreFailed
    
    var errorDescription: String? {
        switch self {
        case .noBackupFound:
            return "No backup found in iCloud"
        case .invalidBackupData:
            return "Invalid backup data format"
        case .iCloudUnavailable:
            return "iCloud is not available"
        case .restoreFailed:
            return "Failed to restore from backup"
        }
    }
}
