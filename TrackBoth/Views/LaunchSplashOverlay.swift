import SwiftUI

/// Bridges the system launch screen into the main app with a brief branded overlay.
struct LaunchSplashOverlay<Content: View>: View {
    @ViewBuilder var content: () -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isActive = LaunchSplashOverlay.shouldShowInitially
    @State private var logoOpacity = 1.0
    @State private var scrimOpacity = 1.0

    private var splash: some View {
        ZStack {
            Color("LaunchBackground")
                .opacity(scrimOpacity)
                .ignoresSafeArea()

            LaunchSplashView(animateFooter: false, showsBackground: false)
                .opacity(logoOpacity)
        }
        .allowsHitTesting(scrimOpacity > 0.05)
    }

    var body: some View {
        ZStack {
            content()

            if isActive {
                splash
                    .accessibilityHidden(true)
            }
        }
        .onAppear(perform: runTransition)
    }

    private func runTransition() {
        guard isActive else { return }

        if Self.shouldSkipTransition {
            isActive = false
            return
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            withAnimation(.easeInOut(duration: 0.35)) { logoOpacity = 0 }
            withAnimation(.easeInOut(duration: 0.75)) { scrimOpacity = 0 }
            try? await Task.sleep(for: .milliseconds(800))
            isActive = false
        }
    }

    private static var shouldSkipTransition: Bool {
        ProcessInfo.processInfo.arguments.contains("-skip_splash")
            || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private static var shouldShowInitially: Bool {
        !shouldSkipTransition
    }
}
