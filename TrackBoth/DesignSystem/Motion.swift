import SwiftUI

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

    func trackBothEntrance(isVisible: Bool, reduceMotion: Bool) -> some View {
        opacity(isVisible ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (isVisible ? 0 : 12))
    }
}
