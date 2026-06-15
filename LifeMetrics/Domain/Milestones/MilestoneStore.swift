import Foundation

// MARK: - MilestoneStore
/// Persists which milestone thresholds have been shown per metric.
enum MilestoneStore {
    private static let storageKey = "awardedMilestones"

    static func awarded(for metricID: UUID) -> Set<Int> {
        let map = loadMap()
        return Set(map[metricID.uuidString] ?? [])
    }

    static func markAwarded(metricID: UUID, threshold: Int) {
        var map = loadMap()
        var thresholds = map[metricID.uuidString] ?? []
        guard !thresholds.contains(threshold) else { return }
        thresholds.append(threshold)
        map[metricID.uuidString] = thresholds.sorted()
        saveMap(map)
    }

    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private static func loadMap() -> [String: [Int]] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let map = try? JSONDecoder().decode([String: [Int]].self, from: data) else {
            return [:]
        }
        return map
    }

    private static func saveMap(_ map: [String: [Int]]) {
        guard let data = try? JSONEncoder().encode(map) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
