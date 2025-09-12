import SwiftUI
import SwiftData

// MARK: - Widget Integration Example
/// Example of how to integrate widget sync with the main app

// Example 1: Add to LifeMetricsApp.swift
/*
@main
struct LifeMetricsApp: App {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.system.rawValue
    @StateObject private var widgetDataSync = WidgetDataSync.shared
    
    var sharedModelContainer: ModelContainer = {
        // ... existing container setup
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(currentTheme.colorScheme)
                .onAppear {
                    // Sync widget data when app launches
                    widgetDataSync.onAppBecameActive(metrics: [], entries: [])
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
*/

// Example 2: Add to HomeViewModel.swift
/*
class HomeViewModel: ObservableObject {
    @Published var metrics: [Metric] = []
    @Published var entries: [MetricEntry] = []
    private let widgetDataSync = WidgetDataSync.shared
    
    // ... existing code ...
    
    func toggleHabit(_ metric: Metric, date: Date) {
        // ... existing toggle logic ...
        
        // Sync with widgets after toggling
        if let entry = updatedEntry {
            widgetDataSync.syncHabitToggle(
                metric: metric,
                entry: entry,
                allMetrics: metrics,
                allEntries: entries
            )
        }
    }
}
*/

// Example 3: Add to SettingsViewModel.swift
/*
class SettingsViewModel: ObservableObject {
    private let widgetDataSync = WidgetDataSync.shared
    
    // ... existing code ...
    
    func clearAllData(in modelContext: ModelContext, metrics: [Metric], entries: [MetricEntry]) {
        // ... existing clear logic ...
        
        // Sync with widgets after clearing
        widgetDataSync.syncDataChange(metrics: [], entries: [])
    }
}
*/

// Example 4: Add to ContentView.swift
/*
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    @StateObject private var widgetDataSync = WidgetDataSync.shared
    
    var body: some View {
        TabView {
            // ... existing tabs ...
        }
        .onAppear {
            // Sync widget data when content view appears
            widgetDataSync.syncAllData(metrics: metrics, entries: entries)
        }
        .onChange(of: metrics) { _, newMetrics in
            // Sync when metrics change
            widgetDataSync.syncMetricChange(metrics: newMetrics, entries: entries)
        }
        .onChange(of: entries) { _, newEntries in
            // Sync when entries change
            widgetDataSync.syncMetricChange(metrics: metrics, entries: newEntries)
        }
    }
}
*/

// MARK: - Widget Setup Instructions
/*
To set up widgets in your QuickLog app:

1. Add Widget Extension Target:
   - File → New → Target
   - Select "Widget Extension"
   - Name: "QuickLogWidget"
   - Include Configuration Intent: No

2. Add App Groups:
   - Select main app target
   - Signing & Capabilities → + Capability → App Groups
   - Add group: "group.com.quicklog.app"
   - Repeat for widget extension target

3. Copy Widget Files:
   - Copy all files from LifeMetrics/Widgets/ to the widget extension
   - Make sure to include WidgetDataModels.swift

4. Update Info.plist:
   - Add widget configuration to both targets
   - Set supported families: small, medium, large

5. Integrate with Main App:
   - Add WidgetDataSync.shared calls to your view models
   - Sync data when habits are logged or data changes
   - Test on physical device (widgets don't work in simulator)

6. Test Widgets:
   - Build and run on device
   - Long press home screen → + → QuickLog
   - Add widgets and test interactions
*/
