import Foundation
import SwiftData
import WidgetKit

// MARK: - Widget Pending Log Processor
/// Drains widget intent queue into SwiftData when the app is active.
enum WidgetPendingLogProcessor {
    static func drainIfNeeded(context: ModelContext) {
        guard ProductSurface.showsWidget else { return }
        let pending = WidgetPendingLogStore.drain()
        guard !pending.isEmpty else { return }

        do {
            let metricStore = MetricStore(context: context)
            let entryStore = EntryStore(context: context)
            let metrics = try metricStore.fetchAll(sortedByName: false)
            var entries = try entryStore.fetchAll()
            let calendar = Calendar.current

            for log in pending {
                guard let metricID = UUID(uuidString: log.metricID),
                      let metric = metrics.first(where: { $0.id == metricID }) else { continue }

                let day = WidgetDateCodec.dayString(from: Date()) == log.day
                    ? calendar.startOfDay(for: Date())
                    : parseDay(log.day) ?? calendar.startOfDay(for: Date())

                let existing = MetricEntry.find(for: metricID, date: day, in: entries)
                let entry: MetricEntry
                if let existing {
                    entry = existing
                } else {
                    entry = MetricEntry(metricID: metricID, date: day, value: log.storedValue, hasBeenLogged: false)
                    context.insert(entry)
                    entries.append(entry)
                }

                entry.value = log.storedValue
                MetricEntry.markLogged(entry: entry, metric: metric)
            }

            if context.saveChanges(operation: "widget pending logs", entity: "MetricEntry") {
                WidgetSyncCoordinator.syncIfEnabled(context: context)
            }
        } catch {
            logger.logError(error, context: "Widget pending log drain failed")
        }
    }

    private static func parseDay(_ day: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = Calendar.current.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: day)
    }
}
