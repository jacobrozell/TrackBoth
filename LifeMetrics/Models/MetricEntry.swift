import Foundation
import SwiftData

// MARK: - MetricEntry Model
/// Data model representing individual entries for metrics
/// Stores daily tracking data including completion status, details, and motivation
@Model
class MetricEntry {
    var id: UUID
    var metricID: UUID
    var date: Date
    var value: Bool
    var motivation: String?
    var starred: Bool?
    var details: String?
    
    // MARK: - Initialization
    init(metricID: UUID, date: Date, value: Bool, motivation: String? = nil, starred: Bool? = nil, details: String? = nil) {
        self.id = UUID()
        self.metricID = metricID
        self.date = date
        self.value = value
        self.motivation = motivation
        self.starred = starred
        self.details = details
    }
    
    // MARK: - Computed Properties
    /// Safely access starred with default value
    var safeStarred: Bool {
        return starred ?? false
    }
    
    /// Check if entry has meaningful content (value, motivation, or details)
    var hasContent: Bool {
        return value || 
               (details != nil && !details!.isEmpty) || 
               (motivation != nil && !motivation!.isEmpty)
    }
    
    // MARK: - Static Methods
    /// Get existing entry or create new one for a specific metric and date
    static func getOrCreate(for metricID: UUID, date: Date, in context: ModelContext, entries: [MetricEntry]) -> MetricEntry {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Look for existing entry for this metric and date
        if let existingEntry = entries.first(where: { 
            $0.metricID == metricID && calendar.isDate($0.date, inSameDayAs: startOfDay) 
        }) {
            return existingEntry
        }
        
        // Create new entry
        let newEntry = MetricEntry(metricID: metricID, date: startOfDay, value: false)
        context.insert(newEntry)
        return newEntry
    }
}

// MARK: - Entry Management Utilities
extension MetricEntry {
    /// Updates or creates an entry for a specific metric and date
    static func updateOrCreate(
        for metricID: UUID, 
        date: Date, 
        value: Bool? = nil,
        details: String? = nil,
        motivation: String? = nil,
        starred: Bool? = nil,
        in context: ModelContext,
        entries: [MetricEntry]
    ) -> MetricEntry {
        let entry = getOrCreate(for: metricID, date: date, in: context, entries: entries)
        
        // Update fields if provided
        if let value = value {
            entry.value = value
        }
        if let details = details {
            entry.details = details.isEmpty ? nil : details
        }
        if let motivation = motivation {
            entry.motivation = motivation.isEmpty ? nil : motivation
        }
        if let starred = starred {
            entry.starred = starred
        }
        
        return entry
    }
    
    /// Cleans up empty entries (entries with no meaningful content)
    static func cleanupEmptyEntries(in context: ModelContext, entries: [MetricEntry]) {
        let emptyEntries = entries.filter { !$0.hasContent }
        for entry in emptyEntries {
            context.delete(entry)
        }
    }
}
