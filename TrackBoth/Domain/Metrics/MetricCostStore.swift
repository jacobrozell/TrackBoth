import Foundation

// MARK: - MetricCostStore
/// Legacy UserDefaults storage for per-vice unit cost. Used only for one-time backfill into SwiftData.
enum MetricCostStore {
    private static let storageKey = "metricCostPerUnit"

    static func legacyCostMap() -> [String: String] {
        UserDefaults.standard.dictionary(forKey: storageKey) as? [String: String] ?? [:]
    }

    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
