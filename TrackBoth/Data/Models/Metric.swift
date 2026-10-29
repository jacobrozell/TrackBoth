import Foundation
import SwiftData

@Model
final class Metric {
    var id: UUID = UUID()
    var name: String = ""
    var habitType: HabitType = HabitType.vice
    var iconName: String = "circle.dashed"
    var createdAt: Date = Date()
    /// Vice: when the current quit attempt began. Habit: when tracking began.
    var startedAt: Date = Date()
    /// Vice only. Money the vice cost per day, decimal string, e.g. "12.50".
    var costPerDayRaw: String?
    /// Vice only. "When I feel the urge, I will …"
    var ifThenPlan: String?
    var sortOrder: Int = 0
    var isArchived: Bool = false

    init(name: String, habitType: HabitType, iconName: String, startedAt: Date = Date(), sortOrder: Int = 0) {
        self.name = name
        self.habitType = habitType
        self.iconName = iconName
        self.startedAt = startedAt
        self.sortOrder = sortOrder
    }

    var costPerDay: Decimal? {
        get {
            guard let costPerDayRaw, let value = Decimal(string: costPerDayRaw), value > 0 else { return nil }
            return value
        }
        set {
            if let newValue, newValue > 0 {
                costPerDayRaw = NSDecimalNumber(decimal: newValue).stringValue
            } else {
                costPerDayRaw = nil
            }
        }
    }
}
