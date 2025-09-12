//
//  LifeMetricsApp.swift
//  LifeMetrics
//
//  Created by Jacob Rozell on 9/10/25.
//

import SwiftUI
import SwiftData

@main
struct LifeMetricsApp: App {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.system.rawValue
    
    var sharedModelContainer: ModelContainer = {
        do {
            // Create a simple container with just the basic models
            let container = try ModelContainer(for: Metric.self, MetricEntry.self)
            print("✅ SwiftData ModelContainer created successfully")
            return container
        } catch {
            print("❌ SwiftData Error: \(error)")
            print("Error details: \(error.localizedDescription)")
            
            // Try with explicit schema
            do {
                let schema = Schema([Metric.self, MetricEntry.self])
                let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let container = try ModelContainer(for: schema, configurations: [config])
                print("✅ SwiftData ModelContainer created with in-memory storage")
                return container
            } catch {
                print("❌ Even in-memory storage failed: \(error)")
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()
    
    private var currentTheme: Theme {
        Theme(rawValue: selectedTheme) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(currentTheme.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
