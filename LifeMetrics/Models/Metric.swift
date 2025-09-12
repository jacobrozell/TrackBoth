import Foundation
import SwiftData

// MARK: - Metric Model
/// Core data model representing a habit or vice to be tracked
/// Contains embedded goal information for tracking progress
@Model
class Metric {
    var id: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date()
    var habitType: HabitType?
    var primaryMotivation: String? // Primary motivation set when creating the habit/vice
    // Embedded goal fields (migrated from separate Goal model)
    var goalPeriod: GoalPeriod?
    var goalTarget: Int?
    // Quantity tracking fields
    var enableQuantity: Bool?
    var defaultUnit: String?
    var maxDailyQuantity: Int?
    // Quantity-based goal fields
    var quantityGoalType: QuantityGoalType?
    var quantityGoalTarget: Int?
    var quantityGoalPeriod: GoalPeriod?
    
    // MARK: - Initialization
    init(name: String, habitType: HabitType = .positive, primaryMotivation: String? = nil, goalPeriod: GoalPeriod? = nil, goalTarget: Int? = nil, enableQuantity: Bool? = nil, defaultUnit: String? = nil, maxDailyQuantity: Int? = nil, quantityGoalType: QuantityGoalType? = nil, quantityGoalTarget: Int? = nil, quantityGoalPeriod: GoalPeriod? = nil) {
        self.name = name
        self.habitType = habitType
        self.primaryMotivation = primaryMotivation
        self.goalPeriod = goalPeriod
        self.goalTarget = goalTarget
        self.enableQuantity = enableQuantity
        self.defaultUnit = defaultUnit
        self.maxDailyQuantity = maxDailyQuantity
        self.quantityGoalType = quantityGoalType
        self.quantityGoalTarget = quantityGoalTarget
        self.quantityGoalPeriod = quantityGoalPeriod
    }
    
    // MARK: - Computed Properties
    /// Safely access habitType with default value
    var safeHabitType: HabitType {
        return habitType ?? .positive
    }
    
    /// Safely access enableQuantity with default value
    var safeEnableQuantity: Bool {
        return enableQuantity ?? false
    }
    
    /// Safely access defaultUnit with default value
    var safeDefaultUnit: String {
        return defaultUnit ?? "times"
    }
    
    /// Safely access maxDailyQuantity with default value
    var safeMaxDailyQuantity: Int? {
        return maxDailyQuantity
    }
    
    /// Safely access quantityGoalType with default value
    var safeQuantityGoalType: QuantityGoalType? {
        return quantityGoalType
    }
    
    /// Safely access quantityGoalTarget with default value
    var safeQuantityGoalTarget: Int? {
        return quantityGoalTarget
    }
    
    /// Safely access quantityGoalPeriod with default value
    var safeQuantityGoalPeriod: GoalPeriod? {
        return quantityGoalPeriod
    }
}
