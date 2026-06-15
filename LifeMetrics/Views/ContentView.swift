import SwiftUI
import SwiftData

// MARK: - ContentView
/// Main container view with tab navigation
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
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
                    ZStack(alignment: .top) {
                        TabView(selection: $selectedTab) {
                            HomeView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .accessibilityIdentifier(AccessibilityIdentifiers.tabHome)
                                .tabItem { tabItem(for: .home, systemImage: "house.fill") }
                                .tag(0)

                            GoalsView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .accessibilityIdentifier(AccessibilityIdentifiers.tabGoals)
                                .tabItem { tabItem(for: .goals, systemImage: "target") }
                                .tag(1)

                            MotivationsView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .accessibilityIdentifier(AccessibilityIdentifiers.tabMotivation)
                                .tabItem { tabItem(for: .motivation, systemImage: "heart.fill") }
                                .tag(2)

                            HistoryView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .accessibilityIdentifier(AccessibilityIdentifiers.tabHistory)
                                .tabItem { tabItem(for: .history, systemImage: "calendar.badge.clock") }
                                .tag(3)

                            if ProductSurface.showsCharts {
                                ChartsView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .accessibilityIdentifier(AccessibilityIdentifiers.tabCharts)
                                    .tabItem { tabItem(for: .charts, systemImage: "chart.line.uptrend.xyaxis") }
                                    .tag(4)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .publishAdaptiveLayoutMode(
                            horizontal: horizontalSizeClass,
                            vertical: verticalSizeClass,
                            size: geometry.size
                        )
                        .id(themeManager.currentAppTheme.name)
                        .onChange(of: selectedTab) { oldValue, newValue in
                            let tabNames = ["Home", "Goals", "Motivation", "History", "Charts"]
                            let tabName = newValue < tabNames.count ? tabNames[newValue] : "Unknown"
                            logger.logUserAction("Tab changed", details: "From \(oldValue) to \(newValue) (\(tabName))")
                        }

                        if shouldShowRecoveryBanner {
                            MigrationRecoveryView(
                                onExportTapped: { selectedTab = 0 },
                                onDismiss: { dismissedStoreRecoveryBanner = true }
                            )
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .onChange(of: themeManager.currentAppTheme) { _, _ in
            // Force TabView refresh when theme changes
        }
    }

    @ViewBuilder
    private func tabItem(for tab: AccessibilityCopy.TabItem, systemImage: String) -> some View {
        Image(systemName: systemImage)
            .accessibilityLabel(tab.accessibilityTitle)
        Text(AccessibilityCopy.tabLabel(tab, iconOnly: usesIconOnlyTabs))
    }

    private func checkFirstLaunch() {
        showingOnboarding = Self.shouldShowOnboarding
        logger.info("First launch check - showing onboarding: \(showingOnboarding)")
    }

    private func seedDemoDataIfRequested() {
        let force = ProcessInfo.processInfo.arguments.contains("-force_seed_demo")
        let seed = ProcessInfo.processInfo.arguments.contains("-seed_demo_data")
        guard force || seed else { return }
        if force {
            DemoDataGenerator.clearDemoData(modelContext: modelContext)
        }
        guard force || !DemoDataGenerator.hasDemoData() else { return }
        DemoDataGenerator.generateDemoData(modelContext: modelContext)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
