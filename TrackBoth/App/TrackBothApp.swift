import SwiftUI
import SwiftData

@main
struct TrackBothApp: App {
    private let container = BootstrapStoreRecovery.makeContainer()

    init() {
        LaunchConfiguration.applyArguments()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(AppRouter.shared)
        }
        .modelContainer(container)
    }
}
