import Foundation
import SwiftData

// MARK: - Goal Model
/// Represents a goal for a specific metric with a specific period
@Model
class Goal {
    var id: UUID = UUID()
    var goalType: GoalType = GoalType.boolean
    var period: GoalPeriod = GoalPeriod.weekly
    var target: Int = 1
    var createdAt: Date = Date()
    
    // Quantity-specific fields (only used when goalType is .quantity)
    var quantityGoalType: QuantityGoalType?
    var defaultUnit: String?
    var maxDailyQuantity: Int?
    
    // Relationship to metric
    var metric: Metric?
    
    // MARK: - Initialization
    init(
        goalType: GoalType,
        period: GoalPeriod,
        target: Int,
        quantityGoalType: QuantityGoalType? = nil,
        defaultUnit: String? = nil,
        maxDailyQuantity: Int? = nil
    ) {
        self.goalType = goalType
        self.period = period
        self.target = target
        self.quantityGoalType = quantityGoalType
        self.defaultUnit = defaultUnit
        self.maxDailyQuantity = maxDailyQuantity
    }
    
    // MARK: - Computed Properties
    /// Safely access defaultUnit with fallback
    var safeDefaultUnit: String {
        return defaultUnit ?? "times"
    }
    
    /// Safely access maxDailyQuantity
    var safeMaxDailyQuantity: Int? {
        return maxDailyQuantity
    }
    
    /// Check if this is a quantity goal
    var isQuantityGoal: Bool {
        return goalType == .quantity
    }
    
    /// Check if this is a boolean goal
    var isBooleanGoal: Bool {
        return goalType == .boolean
    }
}

// MARK: - GoalType Enum
enum GoalType: String, CaseIterable, Codable {
    case boolean = "boolean"
    case quantity = "quantity"
    
    var displayName: String {
        switch self {
        case .boolean: return "Boolean"
        case .quantity: return "Quantity"
        }
    }
    
    var icon: String {
        switch self {
        case .boolean: return "target"
        case .quantity: return "chart.bar.fill"
        }
    }
    
    var description: String {
        switch self {
        case .boolean: return "Yes/No tracking"
        case .quantity: return "Amount tracking"
        }
    }
}
