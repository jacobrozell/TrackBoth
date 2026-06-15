import Foundation
import SwiftData

// MARK: - MetricEntry Model
/// Data model representing individual entries for metrics
/// Stores daily tracking data including completion status, details, and motivation
@Model
class MetricEntry {
    var id: UUID = UUID()
    var metricID: UUID = UUID()
    var date: Date = Date()
    var value: Bool = false
    var motivation: String?
    var starred: Bool?
    var details: String?
    var quantity: Int?
    var unit: String?
    var hasBeenLogged: Bool = false // Tracks if this specific entry has been logged
    
    // MARK: - Initialization
    init(metricID: UUID, date: Date, value: Bool, motivation: String? = nil, starred: Bool? = nil, details: String? = nil, quantity: Int? = nil, unit: String? = nil, hasBeenLogged: Bool = false) {
        logger.debug("Creating new MetricEntry - MetricID: \(metricID.uuidString), Date: \(DateFormatter.dateFormatter.string(from: date)), Value: \(value)", category: .data)
        
        self.metricID = metricID
        self.date = date
        self.value = value
        self.motivation = motivation
        self.starred = starred
        self.details = details
        self.quantity = quantity
        self.unit = unit
        self.hasBeenLogged = hasBeenLogged
    }
    
    // MARK: - Computed Properties
    /// Safely access starred with default value
    var safeStarred: Bool {
        return starred ?? false
    }
    
    /// Check if entry has meaningful content (explicit log, motivation, details, or quantity)
    var hasContent: Bool {
        if hasBeenLogged { return true }
        return (details != nil && !details!.isEmpty) ||
               (motivation != nil && !motivation!.isEmpty) ||
               (quantity != nil && quantity! > 0)
    }
    
    /// Check if entry has quantity data
    var hasQuantity: Bool {
        return quantity != nil && quantity! > 0
    }
    
    /// Get formatted quantity string (e.g., "3 times", "30 minutes")
    var quantityString: String? {
        guard let quantity = quantity, quantity > 0 else { return nil }
        let unitText = unit ?? "times"
        return "\(quantity) \(unitText)"
    }
    
    // MARK: - Static Methods
    /// Get existing entry or create new one for a specific metric and date
    static func getOrCreate(for metricID: UUID, date: Date, in context: ModelContext, entries: [MetricEntry], metric: Metric? = nil) -> MetricEntry {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Look for existing entry for this metric and date
        if let existingEntry = entries.first(where: { 
            $0.metricID == metricID && calendar.isDate($0.date, inSameDayAs: startOfDay) 
        }) {
            return existingEntry
        }
        
        // Create new entry (not marked logged until user explicitly saves)
        let newEntry = MetricEntry(metricID: metricID, date: startOfDay, value: false, hasBeenLogged: false)
        context.insert(newEntry)
        
        return newEntry
    }

    /// Find entry for metric and date without creating one.
    static func find(for metricID: UUID, date: Date, in entries: [MetricEntry]) -> MetricEntry? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return entries.first {
            $0.metricID == metricID && Calendar.current.isDate($0.date, inSameDayAs: startOfDay)
        }
    }

    /// Mark entry and metric as explicitly logged by the user.
    static func markLogged(entry: MetricEntry, metric: Metric?) {
        entry.hasBeenLogged = true
        metric?.hasBeenLogged = true
    }
}

// MARK: - Entry Management Utilities
extension MetricEntry {
    /// Updates or creates an entry for a specific metric and date
    @discardableResult
    static func updateOrCreate(
        for metricID: UUID, 
        date: Date, 
        value: Bool? = nil,
        details: String? = nil,
        motivation: String? = nil,
        starred: Bool? = nil,
        quantity: Int? = nil,
        unit: String? = nil,
        in context: ModelContext,
        entries: [MetricEntry],
        metric: Metric? = nil
    ) -> MetricEntry {
        let entry = getOrCreate(for: metricID, date: date, in: context, entries: entries, metric: metric)
        
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
        if let quantity = quantity {
            entry.quantity = quantity > 0 ? quantity : nil
        }
        if let unit = unit {
            entry.unit = unit.isEmpty ? nil : unit
        }

        if value != nil || details != nil || quantity != nil {
            MetricEntry.markLogged(entry: entry, metric: metric)
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
