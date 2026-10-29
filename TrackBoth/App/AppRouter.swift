import Foundation
import Observation

enum AppTab: Hashable {
    case today, progress, settings
}

enum PresentedFlow: Identifiable, Equatable {
    case urge(UUID?)
    case checkIn
    case celebration(UUID)

    var id: String {
        switch self {
        case .urge(let metricID): "urge-\(metricID?.uuidString ?? "any")"
        case .checkIn: "check-in"
        case .celebration(let metricID): "celebration-\(metricID.uuidString)"
        }
    }
}

@MainActor
@Observable
final class AppRouter {
    static let shared = AppRouter()

    var selectedTab: AppTab = .today
    var presented: PresentedFlow?
    var pendingQuickAction: PresentedFlow?

    func present(_ flow: PresentedFlow) {
        presented = flow
    }

    @discardableResult
    func handleQuickAction(type: String) -> Bool {
        guard type == "com.jacobrozell.TrackBoth.urge" else { return false }
        pendingQuickAction = .urge(nil)
        return true
    }
}
