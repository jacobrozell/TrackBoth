import Foundation

// MARK: - Accessibility Identifiers
/// Central registry for UI test and VoiceOver-adjacent identifiers on lean 1.0 surfaces.
enum AccessibilityIdentifiers {
    static let tabHome = "tab_home"
    static let tabGoals = "tab_goals"
    static let tabMotivation = "tab_motivation"
    static let tabHistory = "tab_history"
    static let tabCharts = "tab_charts"

    static let fabAddMetric = "fab_add_metric"
    static let settingsButton = "settings_button"
    static let settingsExportData = "settings_export_data"
    static let settingsImportData = "settings_import_data"

    static let loggingSaveButton = "logging_save_button"
    static let loggingStatusToggle = "logging_status_toggle"
    static let onboardingGetStarted = "onboarding_get_started"
    static let migrationRecoveryBanner = "migration_recovery_banner"

    static func metricRow(_ metricID: UUID) -> String {
        "metric_row_\(metricID.uuidString)"
    }

    static func metricToggle(_ metricID: UUID) -> String {
        "metric_toggle_\(metricID.uuidString)"
    }
}
