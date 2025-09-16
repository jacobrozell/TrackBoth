import SwiftUI
import Combine

// MARK: - ContentView
/// Main container view with tab navigation
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingOnboarding = false
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Group {
            if showingOnboarding {
                OnboardingView()
                    .onAppear {
                        logger.info("OnboardingView displayed")
                    }
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)

                    GoalsView()
                        .tabItem {
                            Image(systemName: "target")
                            Text("Goals")
                        }
                        .tag(1)

                    MotivationView()
                        .tabItem {
                            Image(systemName: "heart.fill")
                            Text("Motivation")
                        }
                        .tag(2)

                    ChartsView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Charts")
                        }
                        .tag(3)

                    HistoryView()
                        .tabItem {
                            Image(systemName: "calendar.badge.clock")
                            Text("History")
                        }
                        .tag(4)
                }
                .themedBackground()
                .onChange(of: selectedTab) { oldValue, newValue in
                    let tabNames = ["Home", "Goals", "Charts", "Motivation", "History", "Settings"]
                    let tabName = newValue < tabNames.count ? tabNames[newValue] : "Unknown"
                    logger.logUserAction("Tab changed", details: "From \(oldValue) to \(newValue) (\(tabName))")
                }
            }
        }
        .onAppear {
            logger.info("ContentView appeared")
            checkFirstLaunch()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OnboardingCompleted"))) { _ in
            logger.info("Onboarding completed notification received")
            checkFirstLaunch()
        }
    }

    private func checkFirstLaunch() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        showingOnboarding = !hasCompletedOnboarding
        logger.info("First launch check - Onboarding completed: \(hasCompletedOnboarding), showing onboarding: \(showingOnboarding)")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
