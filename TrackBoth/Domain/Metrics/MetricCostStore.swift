import Foundation

// MARK: - MetricCostStore
/// Optional per-vice unit cost stored outside SwiftData until schema migration.
enum MetricCostStore {
    private static let storageKey = "metricCostPerUnit"

    static func costPerUnit(for metricID: UUID) -> Decimal? {
        let map = loadMap()
        guard let string = map[metricID.uuidString],
              let decimal = Decimal(string: string),
              decimal > 0 else {
            return nil
        }
        return decimal
    }

    static func setCostPerUnit(_ value: Decimal?, for metricID: UUID) {
        var map = loadMap()
        if let value, value > 0 {
            map[metricID.uuidString] = NSDecimalNumber(decimal: value).stringValue
        } else {
            map.removeValue(forKey: metricID.uuidString)
        }
        saveMap(map)
    }

    static func remove(for metricID: UUID) {
        setCostPerUnit(nil, for: metricID)
    }

    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    static func encodedCostPerUnit(for metricID: UUID) -> String? {
        guard let cost = costPerUnit(for: metricID) else { return nil }
        return NSDecimalNumber(decimal: cost).stringValue
    }

    static func applyEncodedCostPerUnit(_ encoded: String?, for metricID: UUID) {
        guard let encoded,
              let cost = Decimal(string: encoded),
              cost > 0 else {
            remove(for: metricID)
            return
        }
        setCostPerUnit(cost, for: metricID)
    }

    private static func loadMap() -> [String: String] {
        UserDefaults.standard.dictionary(forKey: storageKey) as? [String: String] ?? [:]
    }

    private static func saveMap(_ map: [String: String]) {
        UserDefaults.standard.set(map, forKey: storageKey)
    }
}
