import Foundation

// MARK: - MetricDisplayPreferences
/// Per-metric UI preferences stored outside SwiftData.
enum MetricDisplayPreferences {
    private static let slipTimerKey = "metricShowSlipTimer"

    static func showTimeSinceSlip(for metricID: UUID) -> Bool {
        let map = loadSlipTimerMap()
        return map[metricID.uuidString] == true
    }

    static func setShowTimeSinceSlip(_ enabled: Bool, for metricID: UUID) {
        var map = loadSlipTimerMap()
        if enabled {
            map[metricID.uuidString] = true
        } else {
            map.removeValue(forKey: metricID.uuidString)
        }
        saveSlipTimerMap(map)
    }

    static func remove(for metricID: UUID) {
        setShowTimeSinceSlip(false, for: metricID)
    }

    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: slipTimerKey)
    }

    private static func loadSlipTimerMap() -> [String: Bool] {
        UserDefaults.standard.dictionary(forKey: slipTimerKey) as? [String: Bool] ?? [:]
    }

    private static func saveSlipTimerMap(_ map: [String: Bool]) {
        UserDefaults.standard.set(map, forKey: slipTimerKey)
    }
}
