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

                    ChartsView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Charts")
                        }
                        .tag(2)

                    MotivationView()
                        .tabItem {
                            Image(systemName: "heart.fill")
                            Text("Motivation")
                        }
                        .tag(3)

                    HistoryView()
                        .tabItem {
                            Image(systemName: "calendar.badge.clock")
                            Text("History")
                        }
                        .tag(4)

                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                        .tag(5)
                }
                .themedBackground()
            }
        }
        .onAppear {
            checkFirstLaunch()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OnboardingCompleted"))) { _ in
            checkFirstLaunch()
        }
    }

    private func checkFirstLaunch() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        showingOnboarding = !hasCompletedOnboarding
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
