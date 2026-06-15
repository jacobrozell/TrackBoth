import Foundation
import SwiftData

// MARK: - Metric Model
/// Core data model representing a habit or vice to be tracked
/// Can have multiple goals with different periods
@Model
class Metric {
    var id: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date()
    var habitType: HabitType = HabitType.positive
    var primaryMotivation: String? // Primary motivation set when creating the habit/vice
    var hasBeenLogged: Bool = false // User has ever explicitly logged this metric
    
    // Relationship to goals (one metric can have multiple goals)
    @Relationship(deleteRule: .cascade, inverse: \Goal.metric)
    var goals: [Goal]? = []
    
    // MARK: - Initialization
    init(name: String, habitType: HabitType = .positive, primaryMotivation: String? = nil) {
        logger.debug("Creating new Metric - Name: \(name), Type: \(habitType.rawValue)", category: .data)
        
        self.name = name
        self.habitType = habitType
        self.primaryMotivation = primaryMotivation
    }
    
    // MARK: - Computed Properties
    
    /// Get all boolean goals for this metric
    var booleanGoals: [Goal] {
        return goals?.filter { $0.goalType == .boolean } ?? []
    }
    
    /// Get all quantity goals for this metric
    var quantityGoals: [Goal] {
        return goals?.filter { $0.goalType == .quantity } ?? []
    }
    
    /// Get goals for a specific period
    func goals(for period: GoalPeriod) -> [Goal] {
        return goals?.filter { $0.period == period } ?? []
    }
    
    /// Get boolean goal for a specific period
    func booleanGoal(for period: GoalPeriod) -> Goal? {
        return goals?.first { $0.goalType == .boolean && $0.period == period }
    }
    
    /// Get quantity goal for a specific period
    func quantityGoal(for period: GoalPeriod) -> Goal? {
        return goals?.first { $0.goalType == .quantity && $0.period == period }
    }
    
    /// Check if metric has any goals
    var hasAnyGoals: Bool {
        return !(goals?.isEmpty ?? true)
    }
    
    /// Check if metric has goals for a specific period
    func hasGoals(for period: GoalPeriod) -> Bool {
        return !goals(for: period).isEmpty
    }
}
