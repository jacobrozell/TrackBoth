import Foundation
import SwiftData

@Model
final class MetricEntry {
    var id: UUID = UUID()
    var metricID: UUID = UUID()
    /// Local-noon anchor of the calendar day (DayMath.anchor).
    var day: Date = Date()
    var statusRaw: String = EntryStatus.free.rawValue
    /// When it happened. For slips this restarts the free clock.
    var occurredAt: Date = Date()
    var note: String?
    var triggersRaw: String = ""

    init(metricID: UUID, day: Date, status: EntryStatus, occurredAt: Date) {
        self.metricID = metricID
        self.day = day
        self.statusRaw = status.rawValue
        self.occurredAt = occurredAt
    }

    var status: EntryStatus {
        get { EntryStatus(rawValue: statusRaw) ?? .free }
        set { statusRaw = newValue.rawValue }
    }

    var triggers: [TriggerTag] {
        get { TriggerTag.decode(triggersRaw) }
        set { triggersRaw = TriggerTag.encode(newValue) }
    }
}

enum EntryStatus: String, Codable, CaseIterable {
    case free
    case slipped
    case done
}
