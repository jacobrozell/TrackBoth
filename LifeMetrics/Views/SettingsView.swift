import SwiftUI
import SwiftData

// MARK: - SettingsView
/// View for app settings, data export, and configuration
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    // Goals are embedded in Metric now
    
    @State private var showingExportSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var exportData: Data?
    @AppStorage("weekStartDay") private var weekStartDay: Int = 1 // 1 = Sunday (default)
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.system.rawValue
    @State private var currentTime = Date()
    @StateObject private var themeManager = ThemeManager.shared
    
    private var dateJoinedText: String {
        guard let earliestMetric = metrics.min(by: { $0.createdAt < $1.createdAt }) else {
            return "Unknown"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: earliestMetric.createdAt)
    }
    
    var body: some View {
        NavigationView {
            List {
                // Data Management Section
                Section("Data Management") {
                    Button("Export Data") {
                        exportData = generateExportData()
                        showingExportSheet = true
                    }
                    .foregroundColor(.blue)
                    
                    if !metrics.isEmpty {
                        Button("Clear Demo Data") {
                            DemoDataGenerator.clearDemoData(modelContext: modelContext)
                        }
                        .foregroundColor(.orange)
                    }
                    
                    Button("Delete All Data") {
                        showingDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                }
                
                // Week Settings Section
                Section("Week Settings") {
                    Picker("Week Starts On", selection: $weekStartDay) {
                        Text("Sunday").tag(1)
                        Text("Monday").tag(2)
                        Text("Tuesday").tag(3)
                        Text("Wednesday").tag(4)
                        Text("Thursday").tag(5)
                        Text("Friday").tag(6)
                        Text("Saturday").tag(7)
                    }
                    .pickerStyle(.menu)
                }
                
                // Theme Settings Section
                Section("Appearance") {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(Theme.allCases, id: \.rawValue) { theme in
                            HStack {
                                Image(systemName: theme.icon)
                                Text(theme.displayName)
                            }
                            .tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedTheme) { _, newValue in
                        if let theme = Theme(rawValue: newValue) {
                            themeManager.updateTheme(theme)
                        }
                    }
                }
                
                // Help & Support Section
                Section("Help & Support") {
                    Button("View Onboarding Again") {
                        showOnboardingAgain()
                    }
                    .foregroundColor(.blue)
                }
                
                // App Information Section
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Metrics")
                        Spacer()
                        Text("\(metrics.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Habits")
                        Spacer()
                        Text("\(metrics.filter { $0.safeHabitType == .positive }.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Vices")
                        Spacer()
                        Text("\(metrics.filter { $0.safeHabitType == .vice }.count)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Entries")
                        Spacer()
                        Text("\(entries.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Date Joined")
                        Spacer()
                        Text(dateJoinedText)
                            .foregroundColor(.secondary)
                    }
                    
                    // Goals are tracked per Metric; no separate count
                }
                
                // Future Features Section
                Section("Coming Soon") {
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundColor(.gray)
                        Text("Custom App Icons")
                        Spacer()
                        Text("Soon")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.gray)
                        Text("Donate")
                        Spacer()
                        Text("Soon")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .foregroundColor(.gray)
                        Text("Export Graphs")
                        Spacer()
                        Text("Soon")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gray)
                        Text("Share App")
                        Spacer()
                        Text("Soon")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                // Current Time Section
                Section("Current Time") {
                    HStack {
                        Text("Local Time")
                        Spacer()
                        Text(currentTime, style: .time)
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                    
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(currentTime, style: .date)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                // Update time every second
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    currentTime = Date()
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                if let exportData = exportData {
                    ShareSheet(activityItems: [exportData])
                }
            }
            .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete All", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all habits and entries. This action cannot be undone.")
            }
        }
    }
    
    private func generateExportData() -> Data? {
        let exportData = ExportData(
            metrics: metrics.map { metric in
                ExportMetric(
                    id: metric.id.uuidString,
                    name: metric.name,
                    createdAt: metric.createdAt,
                    habitType: metric.safeHabitType.rawValue
                )
            },
            entries: entries.map { entry in
                ExportEntry(
                    id: entry.id.uuidString,
                    metricID: entry.metricID.uuidString,
                    date: entry.date,
                    value: entry.value,
                    details: entry.details,
                    motivation: entry.motivation,
                    starred: entry.starred
                )
            },
            exportDate: Date()
        )
        
        do {
            return try JSONEncoder().encode(exportData)
        } catch {
            print("Failed to encode export data: \(error)")
            return nil
        }
    }
    
    private func deleteAllData() {
        withAnimation {
            // Delete all entries
            for entry in entries {
                modelContext.delete(entry)
            }
            
            // No separate goals to delete
            
            // Delete all metrics
            for metric in metrics {
                modelContext.delete(metric)
            }
            
            try? modelContext.save()
        }
    }
    
    private func showOnboardingAgain() {
        // Reset the onboarding completion flag
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        // Post notification to trigger onboarding
        NotificationCenter.default.post(name: NSNotification.Name("OnboardingCompleted"), object: nil)
    }
}

// MARK: - Export Data Models
struct ExportData: Codable {
    let metrics: [ExportMetric]
    let entries: [ExportEntry]
    let exportDate: Date
}

struct ExportMetric: Codable {
    let id: String
    let name: String
    let createdAt: Date
    let habitType: String
}

struct ExportEntry: Codable {
    let id: String
    let metricID: String
    let date: Date
    let value: Bool
    let details: String?
    let motivation: String?
    let starred: Bool?
}

// Removed ExportGoal; goals are included in Metric now

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .modelContainer(for: [Metric.self, MetricEntry.self], inMemory: true)
}
