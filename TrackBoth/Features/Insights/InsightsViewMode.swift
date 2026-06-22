import Foundation

// MARK: - Insights View Mode
/// Calendar = day picker + entries; Trends = chart visualizations.
enum InsightsViewMode: String, CaseIterable, Identifiable {
    case calendar = "Calendar"
    case trends = "Trends"

    var id: String { rawValue }
}
