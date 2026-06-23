import SwiftUI

/// Branded splash shown while bootstrap finishes; pairs with solid-color `UILaunchScreen`.
struct LaunchSplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var footerAppeared = false

    private let animateFooter: Bool
    private let showsBackground: Bool

    init(animateFooter: Bool = true, showsBackground: Bool = true) {
        self.animateFooter = animateFooter
        self.showsBackground = showsBackground
        _footerAppeared = State(initialValue: !animateFooter)
    }

    private var markSize: CGFloat {
        horizontalSizeClass == .regular ? 112 : 96
    }

    private var wordmarkFont: Font {
        if dynamicTypeSize.isAccessibilitySize {
            return .system(.title, design: .rounded).weight(.bold)
        }
        return .system(size: 32, weight: .heavy, design: .rounded)
    }

    var body: some View {
        ZStack {
            if showsBackground {
                Color("LaunchBackground")
                    .ignoresSafeArea()
            }

            splashContent
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("TrackBoth is loading")
        .accessibilityIdentifier(AccessibilityIdentifiers.launchSplash)
        .onAppear(perform: runEntranceAnimation)
    }

    private var splashContent: some View {
        VStack(spacing: 24) {
            BrandMarkView(size: markSize)

            VStack(spacing: 8) {
                Text("TrackBoth")
                    .font(wordmarkFont)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("Habits & Vices")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.currentPrimary)
                    .tracking(0.4)
                    .multilineTextAlignment(.center)

                LaunchDotsIndicator()
                    .padding(.top, 8)
            }
            .opacity(footerAppeared ? 1 : 0)
        }
        .padding(.horizontal, 32)
    }

    private func runEntranceAnimation() {
        guard animateFooter else { return }
        if reduceMotion {
            footerAppeared = true
            return
        }
        withAnimation(.easeOut(duration: 0.35).delay(0.12)) {
            footerAppeared = true
        }
    }
}

private struct LaunchDotsIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let dotSize: CGFloat = 7
    private let inactiveOpacity = 0.35
    private let stepInterval: TimeInterval = 0.42

    var body: some View {
        Group {
            if reduceMotion {
                dotRow(activeIndex: 0)
            } else {
                TimelineView(.periodic(from: .now, by: stepInterval)) { context in
                    dotRow(activeIndex: activeStep(for: context.date))
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func activeStep(for date: Date) -> Int {
        Int(date.timeIntervalSinceReferenceDate / stepInterval) % 3
    }

    private func dotRow(activeIndex: Int) -> some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.currentPrimary)
                    .frame(width: dotSize, height: dotSize)
                    .opacity(index == activeIndex ? 1 : inactiveOpacity)
                    .scaleEffect(index == activeIndex ? 1.15 : 1)
                    .trackBothAnimation(TrackBothMotion.quick, value: activeIndex, reduceMotion: reduceMotion)
            }
        }
    }
}

#Preview("Launch Splash") {
    LaunchSplashView(animateFooter: false)
}
