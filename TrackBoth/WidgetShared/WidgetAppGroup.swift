import Foundation

enum WidgetAppGroup {
    static let identifier = "group.com.trackboth.app"
    static let snapshotKey = "widget_snapshot_v1"
    static let pendingLogsKey = "widget_pending_logs_v1"

    static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }
}
