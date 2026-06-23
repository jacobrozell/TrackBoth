import UIKit

// MARK: - HapticFeedback
enum HapticFeedback {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func soft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func toggle(wasCompleted: Bool) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = wasCompleted ? .soft : .light
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
