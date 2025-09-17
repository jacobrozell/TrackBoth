import SwiftUI
import SwiftData

// MARK: - Shared State Manager
/// Centralized state management for common UI states across the app
@Observable
class SharedStateManager {
    
    // MARK: - Navigation States
    var showingAddMetric = false
    var showingSettings = false
    var showingAddGoal = false
    var showingAddMotivation = false
    
    // MARK: - Sheet States
    var showingExportSheet = false
    var showingShareSheet = false
    var showingBackupSheet = false
    var showingRestoreSheet = false
    var showingDatePicker = false
    var showingDeleteConfirmation = false
    
    // MARK: - Edit States
    var showingEditGoal = false
    var showingEditMetric = false
    var showingEditMotivation = false
    var showingHistory = false
    
    // MARK: - Alert States
    var showingConflictAlert = false
    var showingSuccessAlert = false
    var showingConfirmAlert = false
    
    // MARK: - Input States
    var showingUnitPicker = false
    var showingCustomInput = false
    var showingQuantityInput = false
    
    // MARK: - Data States
    var metricToDelete: Metric?
    var metricToEdit: Metric?
    var goalToEdit: Goal?
    var motivationToEdit: String?
    
    // MARK: - Singleton
    static let shared = SharedStateManager()
    
    private init() {}
    
    // MARK: - Reset Methods
    func resetNavigationStates() {
        showingAddMetric = false
        showingSettings = false
        showingAddGoal = false
        showingAddMotivation = false
    }
    
    func resetSheetStates() {
        showingExportSheet = false
        showingShareSheet = false
        showingBackupSheet = false
        showingRestoreSheet = false
        showingDatePicker = false
        showingDeleteConfirmation = false
    }
    
    func resetEditStates() {
        showingEditGoal = false
        showingEditMetric = false
        showingEditMotivation = false
        showingHistory = false
    }
    
    func resetAlertStates() {
        showingConflictAlert = false
        showingSuccessAlert = false
        showingConfirmAlert = false
    }
    
    func resetInputStates() {
        showingUnitPicker = false
        showingCustomInput = false
        showingQuantityInput = false
    }
    
    func resetDataStates() {
        metricToDelete = nil
        metricToEdit = nil
        goalToEdit = nil
        motivationToEdit = nil
    }
    
    func resetAllStates() {
        resetNavigationStates()
        resetSheetStates()
        resetEditStates()
        resetAlertStates()
        resetInputStates()
        resetDataStates()
    }
}

// MARK: - View Modifier for Shared State
struct SharedStateModifier: ViewModifier {
    @State private var stateManager = SharedStateManager.shared
    
    func body(content: Content) -> some View {
        content
            .environment(\.sharedState, stateManager)
    }
}

// MARK: - Environment Key
private struct SharedStateKey: EnvironmentKey {
    static let defaultValue = SharedStateManager.shared
}

extension EnvironmentValues {
    var sharedState: SharedStateManager {
        get { self[SharedStateKey.self] }
        set { self[SharedStateKey.self] = newValue }
    }
}

// MARK: - Convenience Extensions
extension View {
    func withSharedState() -> some View {
        modifier(SharedStateModifier())
    }
}

// MARK: - State Management Helpers
extension SharedStateManager {
    
    /// Show add metric sheet
    func showAddMetric() {
        logger.logUserAction("Show add metric sheet")
        showingAddMetric = true
    }
    
    /// Show settings sheet
    func showSettings() {
        logger.logUserAction("Show settings sheet")
        showingSettings = true
    }
    
    /// Show add goal sheet
    func showAddGoal() {
        logger.logUserAction("Show add goal sheet")
        showingAddGoal = true
    }
    
    /// Show edit goal sheet
    func showEditGoal(_ goal: Goal) {
        logger.logUserAction("Show edit goal sheet", details: "Goal: \(goal.id.uuidString)")
        goalToEdit = goal
        showingEditGoal = true
    }
    
    /// Show edit metric sheet
    func showEditMetric(_ metric: Metric) {
        logger.logUserAction("Show edit metric sheet", details: "Metric: \(metric.name)")
        metricToEdit = metric
        showingEditMetric = true
    }
    
    /// Show delete confirmation for metric
    func showDeleteConfirmation(for metric: Metric) {
        logger.logUserAction("Show delete confirmation", details: "Metric: \(metric.name)")
        metricToDelete = metric
        showingDeleteConfirmation = true
    }
    
    /// Show export sheet
    func showExportSheet() {
        logger.logUserAction("Show export sheet")
        showingExportSheet = true
    }
    
    /// Show backup sheet
    func showBackupSheet() {
        logger.logUserAction("Show backup sheet")
        showingBackupSheet = true
    }
    
    /// Show restore sheet
    func showRestoreSheet() {
        logger.logUserAction("Show restore sheet")
        showingRestoreSheet = true
    }
    
    /// Show date picker
    func showDatePicker() {
        logger.logUserAction("Show date picker")
        showingDatePicker = true
    }
    
    /// Show success alert
    func showSuccessAlert() {
        logger.logUserAction("Show success alert")
        showingSuccessAlert = true
    }
    
    /// Show conflict alert
    func showConflictAlert() {
        logger.logUserAction("Show conflict alert")
        showingConflictAlert = true
    }
}
