import SwiftUI
import SwiftData
import Combine

// MARK: - ContentView
/// Main container view with tab navigation
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var showingOnboarding = Self.shouldShowOnboarding
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("dismissedStoreRecoveryBanner") private var dismissedStoreRecoveryBanner = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private static var shouldShowOnboarding: Bool {
        let skipOnboarding = ProcessInfo.processInfo.arguments.contains("-skip_onboarding")
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        return !hasCompletedOnboarding && !skipOnboarding
    }

    private var shouldShowRecoveryBanner: Bool {
        BootstrapStoreRecovery.mode == .inMemoryFallback && !dismissedStoreRecoveryBanner
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
                ZStack(alignment: .top) {
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tabItem {
                                Image(systemName: "house.fill")
                                Text("Home")
                            }
                            .tag(0)

                        GoalsView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tabItem {
                                Image(systemName: "target")
                                Text("Goals")
                            }
                            .tag(1)

                        MotivationsView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tabItem {
                                Image(systemName: "heart.fill")
                                Text("Motivation")
                            }
                            .tag(2)

                        HistoryView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tabItem {
                                Image(systemName: "calendar.badge.clock")
                                Text("History")
                            }
                            .tag(3)

                        if ProductSurface.showsCharts {
                            ChartsView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .tabItem {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                    Text("Charts")
                                }
                                .tag(4)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .publishAdaptiveLayoutMode(
                        horizontal: horizontalSizeClass,
                        vertical: verticalSizeClass
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            logger.info("ContentView appeared")
            MigrationUtils.runMigrationIfNeeded(in: modelContext)
            seedDemoDataIfRequested()
            checkFirstLaunch()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OnboardingCompleted"))) { _ in
            logger.info("Onboarding completed notification received")
            checkFirstLaunch()
        }
        .onChange(of: themeManager.currentAppTheme) { _, _ in
            // Force TabView refresh when theme changes
        }
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
