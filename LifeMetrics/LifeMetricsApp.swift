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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Metric.self,
            MetricEntry.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
