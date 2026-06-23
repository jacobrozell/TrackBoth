import SwiftUI

// MARK: - TrackBothMotion
enum TrackBothMotion {
    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.82)
    static let celebrationSpring = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let quick = Animation.easeInOut(duration: 0.2)
    static let highlightFade = Animation.easeOut(duration: 0.3)

    static func animation(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }
}

extension View {
    @ViewBuilder
    func trackBothAnimation<V: Equatable>(
        _ animation: Animation,
        value: V,
        reduceMotion: Bool
    ) -> some View {
        if reduceMotion {
            self
        } else {
            self.animation(animation, value: value)
        }
    }

    /// Gentle fade-and-rise entrance for empty states and inline banners.
    func trackBothEntrance(isVisible: Bool, reduceMotion: Bool) -> some View {
        opacity(isVisible ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (isVisible ? 0 : 12))
    }

    /// Chart/content reveal that respects Reduce Motion.
    func chartReveal(isRevealed: Bool, reduceMotion: Bool, delay: TimeInterval = 0) -> some View {
        opacity(isRevealed || reduceMotion ? 1 : 0)
            .trackBothAnimation(
                TrackBothMotion.spring.delay(delay),
                value: isRevealed,
                reduceMotion: reduceMotion
            )
    }
}

// MARK: - ToggleIconMotionModifier
struct ToggleIconMotionModifier: ViewModifier {
    let reduceMotion: Bool
    let effectTrigger: Int

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, value: effectTrigger)
        }
    }
}
