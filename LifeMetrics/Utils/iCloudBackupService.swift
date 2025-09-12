import Foundation
import UIKit
import CloudKit
import SwiftData

// MARK: - iCloud Backup Service
/// Service for backing up and restoring app data to/from iCloud
@Observable
class iCloudBackupService {
    
    // MARK: - Properties
    private let container = CKContainer.default()
    private let database: CKDatabase
    
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
        let goalPeriod: String?
        let goalTarget: Int?
        let enableQuantity: Bool?
        let defaultUnit: String?
        let maxDailyQuantity: Int?
        let quantityGoalType: String?
        let quantityGoalTarget: Int?
        let quantityGoalPeriod: String?
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
    }
    
    // MARK: - Initialization
    init() {
        self.database = container.privateCloudDatabase
    }
    
    // MARK: - Backup Methods
    
    /// Create a backup of all app data
    func createBackup(metrics: [Metric], entries: [MetricEntry]) async throws -> BackupData {
        let backupMetrics = metrics.map { metric in
            BackupMetric(
                id: metric.id.uuidString,
                name: metric.name,
                createdAt: metric.createdAt,
                habitType: metric.habitType?.rawValue,
                primaryMotivation: metric.primaryMotivation,
                goalPeriod: metric.goalPeriod?.rawValue,
                goalTarget: metric.goalTarget,
                enableQuantity: metric.enableQuantity,
                defaultUnit: metric.defaultUnit,
                maxDailyQuantity: metric.maxDailyQuantity,
                quantityGoalType: metric.quantityGoalType?.rawValue,
                quantityGoalTarget: metric.quantityGoalTarget,
                quantityGoalPeriod: metric.quantityGoalPeriod?.rawValue
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
                unit: entry.unit
            )
        }
        
        let deviceInfo = await BackupData.DeviceInfo(
            deviceName: UIDevice.current.name,
            systemVersion: UIDevice.current.systemVersion,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        )
        
        return BackupData(
            version: "1.0",
            timestamp: Date(),
            metrics: backupMetrics,
            entries: backupEntries,
            deviceInfo: deviceInfo
        )
    }
    
    /// Upload backup to iCloud
    func uploadBackup(_ backupData: BackupData) async throws {
        let record = CKRecord(recordType: "QuickLogBackup")
        record["timestamp"] = backupData.timestamp
        record["version"] = backupData.version
        
        // Convert to JSON data
        let jsonData = try JSONEncoder().encode(backupData)
        let asset = CKAsset(fileURL: try saveToTemporaryFile(jsonData))
        record["backupData"] = asset
        
        try await database.save(record)
    }
    
    /// Download latest backup from iCloud
    func downloadLatestBackup() async throws -> BackupData {
        let query = CKQuery(recordType: "QuickLogBackup", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        let results = try await database.records(matching: query)
        
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
        // Clear existing data
        try clearAllData(context: context)
        
        // Restore metrics
        for backupMetric in backupData.metrics {
            let metric = Metric(
                name: backupMetric.name,
                habitType: HabitType(rawValue: backupMetric.habitType ?? "positive") ?? .positive,
                primaryMotivation: backupMetric.primaryMotivation,
                goalPeriod: backupMetric.goalPeriod != nil ? GoalPeriod(rawValue: backupMetric.goalPeriod!) : nil,
                goalTarget: backupMetric.goalTarget,
                enableQuantity: backupMetric.enableQuantity,
                defaultUnit: backupMetric.defaultUnit,
                maxDailyQuantity: backupMetric.maxDailyQuantity,
                quantityGoalType: backupMetric.quantityGoalType != nil ? QuantityGoalType(rawValue: backupMetric.quantityGoalType!) : nil,
                quantityGoalTarget: backupMetric.quantityGoalTarget,
                quantityGoalPeriod: backupMetric.quantityGoalPeriod != nil ? GoalPeriod(rawValue: backupMetric.quantityGoalPeriod!) : nil
            )
            
            // Set the original ID
            metric.id = UUID(uuidString: backupMetric.id) ?? UUID()
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
                unit: backupEntry.unit
            )
            
            // Set the original ID
            entry.id = UUID(uuidString: backupEntry.id) ?? UUID()
            context.insert(entry)
        }
        
        try context.save()
    }
    
    /// Check if iCloud is available
    func checkiCloudAvailability() async -> Bool {
        do {
            let status = try await container.accountStatus()
            return status == .available
        } catch {
            return false
        }
    }
    
    /// Get backup info
    func getBackupInfo() async throws -> BackupInfo {
        let query = CKQuery(recordType: "QuickLogBackup", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        let results = try await database.records(matching: query)
        
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
