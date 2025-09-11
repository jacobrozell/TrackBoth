import SwiftUI
import Combine

// MARK: - ContentView
/// Main container view with tab navigation
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingOnboarding = false
    
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
            
            HistoryView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("History")
                }
                .tag(1)
            
            GoalsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
                .tag(2)
            
            ChartsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Charts")
                }
                .tag(3)
            
            MotivationView()
                .tabItem {
                    Image(systemName: "heart.text.square")
                    Text("Motivation")
                }
                .tag(4)
                }
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
