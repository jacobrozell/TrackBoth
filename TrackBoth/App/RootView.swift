import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @State private var onboarded = Preferences.hasCompletedOnboarding

    var body: some View {
        Group {
            if onboarded {
                MainTabView()
            } else {
                OnboardingPlaceholder {
                    Preferences.hasCompletedOnboarding = true
                    onboarded = true
                }
            }
        }
        .background(Color.tbBackground)
        .task {
            guard LaunchConfiguration.shouldSeedDemo else { return }
            try? DemoData.seedIfEmpty(context: modelContext)
        }
        .safeAreaInset(edge: .top) {
            if BootstrapStoreRecovery.mode == .inMemoryFallback {
                StoreRecoveryBanner()
            }
        }
    }
}

private struct MainTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            TodayScreen()
                .tabItem { Label("Today", systemImage: "sun.max").accessibilityIdentifier(AccessibilityIdentifiers.tabToday) }
                .tag(AppTab.today)
            ProgressScreen()
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis").accessibilityIdentifier(AccessibilityIdentifiers.tabProgress) }
                .tag(AppTab.progress)
            SettingsScreen()
                .tabItem { Label("Settings", systemImage: "gearshape").accessibilityIdentifier(AccessibilityIdentifiers.tabSettings) }
                .tag(AppTab.settings)
        }
        .tint(Color.tbBrand)
    }
}

private struct OnboardingPlaceholder: View {
    var skip: () -> Void

    var body: some View {
        VStack(spacing: Spacing.l) {
            BrandMark(size: 72)
            Text("Onboarding coming soon")
                .font(.title2)
                .foregroundStyle(Color.tbTextPrimary)
            if ProductSurface.showsDebugTools {
                Button("Skip", action: skip)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.tbBrand)
                    .frame(minHeight: 44)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.tbBackground)
    }
}
