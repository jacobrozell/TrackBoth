import Foundation
import SwiftData

// MARK: - Metric Model
/// Core data model representing a habit or vice to be tracked
/// Contains embedded goal information for tracking progress
@Model
class Metric {
    var id: UUID
    var name: String
    var createdAt: Date
    var habitType: HabitType?
    var primaryMotivation: String? // Primary motivation set when creating the habit/vice
    // Embedded goal fields (migrated from separate Goal model)
    var goalPeriod: GoalPeriod?
    var goalTarget: Int?
    
    // MARK: - Initialization
    init(name: String, habitType: HabitType = .positive, primaryMotivation: String? = nil, goalPeriod: GoalPeriod? = nil, goalTarget: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.habitType = habitType
        self.primaryMotivation = primaryMotivation
        self.goalPeriod = goalPeriod
        self.goalTarget = goalTarget
    }
    
    // MARK: - Computed Properties
    /// Safely access habitType with default value
    var safeHabitType: HabitType {
        return habitType ?? .positive
    }
}
