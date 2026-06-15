import Foundation

struct WidgetPendingLog: Codable, Equatable {
    let metricID: String
    let day: String
    let storedValue: Bool
    let requestedAt: Date
}

enum WidgetPendingLogStore {
    static func enqueue(_ log: WidgetPendingLog) {
        var queue = load()
        queue.append(log)
        save(queue)
    }

    static func drain() -> [WidgetPendingLog] {
        let queue = load()
        save([])
        return queue
    }

    private static func load() -> [WidgetPendingLog] {
        guard let defaults = WidgetAppGroup.userDefaults,
              let data = defaults.data(forKey: WidgetAppGroup.pendingLogsKey) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([WidgetPendingLog].self, from: data)) ?? []
    }

    private static func save(_ logs: [WidgetPendingLog]) {
        guard let defaults = WidgetAppGroup.userDefaults else { return }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(logs) else { return }
        defaults.set(data, forKey: WidgetAppGroup.pendingLogsKey)
    }
}
