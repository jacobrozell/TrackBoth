import Foundation

// MARK: - App Events
/// Typed cross-cutting events. Prefer these over raw notification name strings.
enum AppEvent: String {
    case onboardingCompleted
    case switchToTrack
    case openAddMetric
    case presentAddMetric

    var notificationName: Notification.Name {
        Notification.Name("app.\(rawValue)")
    }

    static func post(_ event: AppEvent) {
        NotificationCenter.default.post(name: event.notificationName, object: nil)
    }

    static func publisher(for event: AppEvent) -> NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: event.notificationName)
    }
}
