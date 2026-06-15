import Foundation

enum WidgetSnapshotStore {
    static func save(_ snapshot: WidgetSnapshotV1) {
        guard let defaults = WidgetAppGroup.userDefaults else { return }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        defaults.set(data, forKey: WidgetAppGroup.snapshotKey)
    }

    static func load() -> WidgetSnapshotV1? {
        guard let defaults = WidgetAppGroup.userDefaults,
              let data = defaults.data(forKey: WidgetAppGroup.snapshotKey) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(WidgetSnapshotV1.self, from: data)
    }
}
