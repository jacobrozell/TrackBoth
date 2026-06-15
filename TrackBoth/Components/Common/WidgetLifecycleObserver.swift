import SwiftUI
import SwiftData

// MARK: - Widget Lifecycle Observer
/// Observes scene phase and syncs widget data when the widget surface is enabled.
struct WidgetLifecycleObserver: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .onChange(of: scenePhase) { _, phase in
                WidgetSyncCoordinator.handleLifecycle(phase: phase, context: modelContext)
            }
    }
}
