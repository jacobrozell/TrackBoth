import SwiftUI
import SwiftData

// MARK: - ContentView
/// Main container view with tab navigation
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = MainTab.track.rawValue
    @State private var showingOnboarding = Self.shouldShowOnboarding
    @Environment(ThemeManager.self) private var themeManager
    @AppStorage("dismissedStoreRecoveryBanner") private var dismissedStoreRecoveryBanner = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private static var shouldShowOnboarding: Bool {
        let skipOnboarding = ProcessInfo.processInfo.arguments.contains("-skip_onboarding")
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: ThemePreferences.hasCompletedOnboarding)
        return !hasCompletedOnboarding && !skipOnboarding
    }

    private var shouldShowRecoveryBanner: Bool {
        BootstrapStoreRecovery.mode == .inMemoryFallback && !dismissedStoreRecoveryBanner
    }

    private var usesIconOnlyTabs: Bool {
        dynamicTypeSize.usesExpandedChrome
    }

    private func usesCompactTabLabels(for deviceLayout: DeviceLayout) -> Bool {
        usesIconOnlyTabs || deviceLayout.isLandscape
    }

    var body: some View {
        ZStack {
            Color.currentBackground.ignoresSafeArea()

            if showingOnboarding {
                OnboardingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        logger.info("OnboardingView displayed")
                    }
            } else {
                GeometryReader { geometry in
                    let deviceLayout = DeviceLayout.resolve(
                        horizontal: horizontalSizeClass,
                        vertical: verticalSizeClass,
                        size: geometry.size
                    )
                    ZStack(alignment: .top) {
                        TabView(selection: $selectedTab) {
                            TrackScreen()
                                .accessibilityIdentifier(AccessibilityIdentifiers.tabTrack)
                                .tabItem { tabItem(for: .track, systemImage: "checkmark.circle.fill", deviceLayout: deviceLayout) }
                                .tag(MainTab.track.rawValue)

                            if ProductSurface.showsInsights {
                                InsightsView()
                                    .accessibilityIdentifier(AccessibilityIdentifiers.tabInsights)
                                    .tabItem { tabItem(for: .insights, systemImage: "chart.bar.xaxis", deviceLayout: deviceLayout) }
                                    .tag(MainTab.insights.rawValue)
                            }

                            if ProductSurface.showsGoals {
                                GoalsView()
                                    .accessibilityIdentifier(AccessibilityIdentifiers.tabGoals)
                                    .tabItem { tabItem(for: .goals, systemImage: "target", deviceLayout: deviceLayout) }
                                    .tag(MainTab.goals.rawValue)
                            }

                            if ProductSurface.showsMotivation {
                                MotivationsView()
                                    .accessibilityIdentifier(AccessibilityIdentifiers.tabMotivation)
                                    .tabItem { tabItem(for: .motivation, systemImage: "heart.fill", deviceLayout: deviceLayout) }
                                    .tag(MainTab.motivation.rawValue)
                            }

                            SettingsView()
                                .accessibilityIdentifier(AccessibilityIdentifiers.tabSettings)
                                .tabItem { tabItem(for: .settings, systemImage: "gear", deviceLayout: deviceLayout) }
                                .tag(MainTab.settings.rawValue)
                        }
                        .environment(\.deviceLayout, deviceLayout)
                        .publishAdaptiveLayoutMode(
                            horizontal: horizontalSizeClass,
                            vertical: verticalSizeClass,
                            size: geometry.size
                        )
                        .id(themeManager.currentAppTheme.name)
                        .onChange(of: selectedTab) { oldValue, newValue in
                            logger.logUserAction("Tab changed", details: "From \(oldValue) to \(newValue) (\(MainTab(rawValue: newValue)?.logName ?? "Unknown"))")
                        }

                        if shouldShowRecoveryBanner {
                            MigrationRecoveryView(
                                onExportTapped: { selectedTab = MainTab.settings.rawValue },
                                onDismiss: { dismissedStoreRecoveryBanner = true }
                            )
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            WidgetLifecycleObserver()
        }
        .onAppear {
            logger.info("ContentView appeared")
            MigrationUtils.runMigrationIfNeeded(in: modelContext)
            seedDemoDataIfRequested()
            checkFirstLaunch()
        }
        .onReceive(AppEvent.publisher(for: .onboardingCompleted)) { _ in
            logger.info("Onboarding completed notification received")
            checkFirstLaunch()
        }
        .onReceive(AppEvent.publisher(for: .switchToTrack)) { _ in
            selectedTab = MainTab.track.rawValue
        }
        .onReceive(AppEvent.publisher(for: .openAddMetric)) { _ in
            selectedTab = MainTab.track.rawValue
            // TrackScreen owns the add sheet; post after tab switch settles.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                AppEvent.post(.presentAddMetric)
            }
        }
        .onChange(of: themeManager.currentAppTheme) { _, _ in
            // Force TabView refresh when theme changes
        }
        .onOpenURL { url in
            guard url.scheme == "trackboth" else { return }
            selectedTab = MainTab.track.rawValue
        }
    }

    @ViewBuilder
    private func tabItem(for tab: AccessibilityCopy.TabItem, systemImage: String, deviceLayout: DeviceLayout) -> some View {
        Image(systemName: systemImage)
            .accessibilityLabel(tab.accessibilityTitle)
        Text(AccessibilityCopy.tabLabel(tab, iconOnly: usesCompactTabLabels(for: deviceLayout)))
    }

    private func checkFirstLaunch() {
        showingOnboarding = Self.shouldShowOnboarding
        logger.info("First launch check - showing onboarding: \(showingOnboarding)")
    }

    private func seedDemoDataIfRequested() {
        let force = ProcessInfo.processInfo.arguments.contains("-force_seed_demo")
        let seed = ProcessInfo.processInfo.arguments.contains("-seed_demo_data")
        let screenshot = ProcessInfo.processInfo.arguments.contains("-screenshot_demo")
        guard force || seed || screenshot else { return }
        if force || screenshot {
            DemoDataGenerator.clearDemoData(modelContext: modelContext)
        }
        guard force || screenshot || !DemoDataGenerator.hasDemoData() else { return }
        DemoDataGenerator.generateDemoData(modelContext: modelContext)
    }
}

// MARK: - MainTab
private enum MainTab: Int {
    case track = 0
    case insights = 1
    case goals = 2
    case motivation = 3
    case settings = 4

    var logName: String {
        switch self {
        case .track: return "Track"
        case .insights: return "Insights"
        case .goals: return "Goals"
        case .motivation: return "Motivation"
        case .settings: return "Settings"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
