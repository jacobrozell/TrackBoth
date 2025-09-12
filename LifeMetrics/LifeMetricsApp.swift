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
    
    init() {
        logger.info("LifeMetricsApp initializing", category: .general)
    }
    
    var sharedModelContainer: ModelContainer = {
        logger.info("Creating SwiftData ModelContainer", category: .data)
        let startTime = Date()
        
        do {
            // Create a simple container with just the basic models
            let container = try ModelContainer(for: Metric.self, MetricEntry.self)
            let duration = Date().timeIntervalSince(startTime)
            logger.logPerformance("SwiftData ModelContainer creation", duration: duration)
            logger.info("SwiftData ModelContainer created successfully", category: .data)
            return container
        } catch {
            logger.error("SwiftData Error: \(error.localizedDescription)", category: .data)
            logger.warn("Attempting fallback with explicit schema and in-memory storage", category: .data)
            
            // Try with explicit schema
            do {
                let schema = Schema([Metric.self, MetricEntry.self])
                let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let container = try ModelContainer(for: schema, configurations: [config])
                let duration = Date().timeIntervalSince(startTime)
                logger.logPerformance("SwiftData ModelContainer creation (fallback)", duration: duration)
                logger.warn("SwiftData ModelContainer created with in-memory storage", category: .data)
                return container
            } catch {
                logger.fatal("Even in-memory storage failed: \(error.localizedDescription)", category: .data)
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()
    
    private var currentTheme: Theme {
        let theme = Theme(rawValue: selectedTheme) ?? .system
        logger.debug("Current theme: \(theme.rawValue)", category: .ui)
        return theme
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(currentTheme.colorScheme)
                .onAppear {
                    logger.info("App window appeared", category: .ui)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
