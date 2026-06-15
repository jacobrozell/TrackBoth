import Foundation

// MARK: - StreakCopy
enum StreakCopy {
    static func habitStreak(_ count: Int) -> String {
        "\(count) \(count == 1 ? "day" : "days") streak"
    }

    static func viceClean(_ count: Int) -> String {
        "\(count) \(count == 1 ? "day" : "days") clean"
    }
}
