//
//  TrackBothApp.swift
//  TrackBoth
//
//  Created by Jacob Rozell on 9/10/25.
//

import SwiftUI
import SwiftData

@main
struct TrackBothApp: App {
    @State private var themeManager = ThemeManager.shared

    init() {
        logger.info("TrackBothApp initializing", category: .general)
        applyLaunchEnvironmentOverrides()
    }

    let sharedModelContainer: ModelContainer = {
        logger.info("Creating SwiftData ModelContainer", category: .data)
        let startTime = Date()
        let container = BootstrapStoreRecovery.makeContainer()
        let duration = Date().timeIntervalSince(startTime)
        logger.logPerformance("SwiftData ModelContainer creation", duration: duration)
        if BootstrapStoreRecovery.mode == .inMemoryFallback {
            logger.warn("SwiftData ModelContainer using in-memory fallback", category: .data)
        } else {
            logger.info("SwiftData ModelContainer created successfully", category: .data)
        }
        return container
    }()

    var body: some Scene {
        WindowGroup {
            LaunchSplashOverlay {
                ContentView()
                    .environment(themeManager)
                    .preferredColorScheme(themeManager.preferredColorScheme)
                    .tint(themeManager.currentAppTheme.primaryColor)
                    .onAppear {
                        logger.info("App window appeared", category: .ui)
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func applyLaunchEnvironmentOverrides() {
        let env = ProcessInfo.processInfo.environment
        if env["UI_TEST_RESET"] == "1", let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        if env["RESET_ONBOARDING"] == "1" {
            UserDefaults.standard.set(false, forKey: ThemePreferences.hasCompletedOnboarding)
        }
    }
}
