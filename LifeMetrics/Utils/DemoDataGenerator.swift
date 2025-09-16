import Foundation
import SwiftData

// MARK: - DemoDataGenerator
struct DemoDataGenerator {
    
    static func generateDemoData(modelContext: ModelContext) {
        // Mark that demo data has been generated
        UserDefaults.standard.set(true, forKey: "hasDemoData")
        
        // Create demo metrics
        let demoMetrics = [
            Metric(name: "Morning Exercise", habitType: .positive),
            Metric(name: "Read 30 minutes", habitType: .positive),
            Metric(name: "Meditation", habitType: .positive),
            Metric(name: "Drink Water", habitType: .positive),
            Metric(name: "Social Media", habitType: .vice),
            Metric(name: "Late Night Snacks", habitType: .vice),
            // Quantity-type metrics for testing quantity charts
            Metric(name: "Steps Walked", habitType: .positive),
            Metric(name: "Pages Read", habitType: .positive),
            Metric(name: "Cigarettes Smoked", habitType: .vice),
            Metric(name: "Cups of Coffee", habitType: .vice)
        ]
        
        // Insert metrics
        for metric in demoMetrics {
            modelContext.insert(metric)
        }
        
        // Generate entries for the last 30 days
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        
        var currentDate = startDate
        while currentDate <= endDate {
            // Generate entries for each metric
            for metric in demoMetrics {
                let shouldComplete = generateCompletionProbability(
                    for: metric,
                    on: currentDate,
                    daysSinceStart: calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
                )
                
                if shouldComplete {
                    // Generate quantity data for quantity-type metrics
                    let (quantity, unit) = generateQuantityData(for: metric)
                    
                    let entry = MetricEntry(
                        metricID: metric.id,
                        date: currentDate,
                        value: true,
                        quantity: quantity,
                        unit: unit
                    )
                    modelContext.insert(entry)
                }
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Save the context
        try? modelContext.save()
    }
    
    private static func generateCompletionProbability(
        for metric: Metric,
        on date: Date,
        daysSinceStart: Int
    ) -> Bool {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        // Base probability based on metric type
        var baseProbability: Double
        switch metric.safeHabitType {
        case .positive:
            baseProbability = 0.6 // 60% base chance for habits
        case .vice:
            baseProbability = 0.3 // 30% base chance for vices (we want to avoid them)
        }
        
        // Adjust based on days since start (habits get easier, vices get harder to avoid)
        let progressFactor = Double(daysSinceStart) / 30.0
        if metric.safeHabitType == .positive {
            baseProbability += progressFactor * 0.2 // Habits get easier over time
        } else {
            baseProbability -= progressFactor * 0.1 // Vices get harder to avoid over time
        }
        
        // Weekend adjustment
        if dayOfWeek == 1 || dayOfWeek == 7 { // Sunday or Saturday
            if metric.safeHabitType == .positive {
                baseProbability *= 0.8 // Habits are harder on weekends
            } else {
                baseProbability *= 1.3 // Vices are more likely on weekends
            }
        }
        
        // Specific metric adjustments
        switch metric.name {
        case "Morning Exercise":
            baseProbability *= 0.7 // Exercise is harder
        case "Read 30 minutes":
            baseProbability *= 1.1 // Reading is easier
        case "Meditation":
            baseProbability *= 0.8 // Meditation requires discipline
        case "Drink Water":
            baseProbability *= 1.2 // Drinking water is easier
        case "Social Media":
            baseProbability *= 1.1 // Social media is tempting
        case "Late Night Snacks":
            baseProbability *= 0.9 // Snacks are moderately tempting
        case "Steps Walked":
            baseProbability *= 1.0 // Moderate difficulty
        case "Pages Read":
            baseProbability *= 0.9 // Reading pages requires effort
        case "Cigarettes Smoked":
            baseProbability *= 0.8 // Smoking is a vice to avoid
        case "Cups of Coffee":
            baseProbability *= 1.2 // Coffee is tempting but trackable
        default:
            break
        }
        
        // Add some randomness
        let randomFactor = Double.random(in: 0.8...1.2)
        baseProbability *= randomFactor
        
        // Ensure probability is between 0 and 1
        baseProbability = max(0.0, min(1.0, baseProbability))
        
        return Double.random(in: 0...1) < baseProbability
    }
    
    private static func generateQuantityData(for metric: Metric) -> (Int?, String?) {
        switch metric.name {
        case "Steps Walked":
            return (Int.random(in: 3000...15000), "steps")
        case "Pages Read":
            return (Int.random(in: 5...50), "pages")
        case "Cigarettes Smoked":
            return (Int.random(in: 1...20), "cigarettes")
        case "Cups of Coffee":
            return (Int.random(in: 1...8), "cups")
        default:
            // For boolean-type metrics, return nil for quantity
            return (nil, nil)
        }
    }
    
    static func clearDemoData(modelContext: ModelContext) {
        // Clear the demo data flag
        UserDefaults.standard.set(false, forKey: "hasDemoData")
        
        // Delete all metrics and entries
        do {
            try modelContext.delete(model: Metric.self)
            try modelContext.delete(model: MetricEntry.self)
            try modelContext.save()
        } catch {
            print("Error clearing demo data: \(error)")
        }
    }
    
    static func hasDemoData() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasDemoData")
    }
}
