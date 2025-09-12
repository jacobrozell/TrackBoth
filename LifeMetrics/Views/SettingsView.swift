import SwiftUI
import SwiftData

// Import the backup service and components
// These should be accessible if all files are in the same target

// MARK: - SettingsView
/// View for app settings, data export, and configuration
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]
    // Goals are embedded in Metric now
    
    @State private var showingExportSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingShareSheet = false
    @State private var showingBackupSheet = false
    @State private var showingRestoreSheet = false
    @State private var exportData: Data?
    @State private var backupService = iCloudBackupService()
    @State private var backupInfo: BackupInfo?
    @State private var isBackingUp = false
    @State private var isRestoring = false
    @State private var backupError: String?
    @AppStorage("weekStartDay") private var weekStartDay: Int = 1 // 1 = Sunday (default)
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.system.rawValue
    @State private var currentTime = Date()
    @StateObject private var themeManager = ThemeManager.shared
    
    private var dateJoinedText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        // If user has metrics, use the earliest one's creation date
        if let earliestMetric = metrics.min(by: { $0.createdAt < $1.createdAt }) {
            return formatter.string(from: earliestMetric.createdAt)
        }
        
        // For new users who just finished onboarding, show today's date
        return formatter.string(from: Date())
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var shareAppContent: String {
        let totalHabits = metrics.filter { $0.safeHabitType == .positive }.count
        let totalVices = metrics.filter { $0.safeHabitType == .vice }.count
        logger.debug("Share app content calculated - Habits: \(totalHabits), Vices: \(totalVices)", category: .business)
        let totalEntries = entries.count
        
        return """
        📱 Check out QuickLog - my habit tracking app!
        
        I've been using it to track \(totalHabits) positive habits and \(totalVices) vices, with \(totalEntries) total entries logged.
        
        ✨ Features:
        • Track both positive habits and vices
        • Visual progress charts and streaks
        • Goal setting and tracking
        • Motivation system
        • Quantity tracking
        • Beautiful themes
        
        Perfect for building better habits and breaking bad ones! 🎯
        
        #HabitTracking #PersonalDevelopment #QuickLog
        """
    }
    
    var body: some View {
        NavigationView {
            List {
                // Data Management Section
                Section("Data Management") {
                    Button("Export Data") {
                        logger.logUserAction("Export data button tapped")
                        exportData = generateExportData()
                        showingExportSheet = true
                    }
                    .foregroundColor(.blue)
                    
                    if !metrics.isEmpty {
                        Button("Clear Demo Data") {
                            logger.logUserAction("Clear demo data button tapped")
                            DemoDataGenerator.clearDemoData(modelContext: modelContext)
                        }
                        .foregroundColor(.orange)
                    }
                    
                    Button("Delete All Data") {
                        logger.logUserAction("Delete all data button tapped")
                        showingDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                }
                
                // iCloud Backup Section
                Section("iCloud Backup") {
                    Button("Backup to iCloud") {
                        logger.logUserAction("Backup to iCloud button tapped")
                        showingBackupSheet = true
                    }
                    .foregroundColor(.blue)
                    .disabled(isBackingUp)
                    
                    Button("Restore from iCloud") {
                        logger.logUserAction("Restore from iCloud button tapped")
                        showingRestoreSheet = true
                    }
                    .foregroundColor(.green)
                    .disabled(isRestoring)
                    
                    if let backupInfo = backupInfo {
                        HStack {
                            Text("Last Backup")
                            Spacer()
                            Text(backupInfo.timestamp, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
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
                    Button("Share App") {
                        showingShareSheet = true
                    }
                    .foregroundColor(.blue)
                    
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
                        Text(appVersion)
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
                        Image(systemName: "app.badge")
                            .foregroundColor(.gray)
                        Text("Custom App Icons")
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
                logger.info("SettingsView appeared")
                logger.debug("Metrics count: \(metrics.count), Entries count: \(entries.count)", category: .data)
                // Update time every second
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    currentTime = Date()
                }
                
                // Load backup info
                loadBackupInfo()
            }
            .sheet(isPresented: $showingExportSheet) {
                if let exportData = exportData {
                    ShareSheet(activityItems: [exportData])
                        .onAppear {
                            logger.info("Export data sheet presented")
                        }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [shareAppContent])
                    .onAppear {
                        logger.info("Share app sheet presented")
                    }
            }
            .sheet(isPresented: $showingBackupSheet) {
                BackupSheet(
                    backupService: backupService,
                    metrics: metrics,
                    entries: entries,
                    isBackingUp: $isBackingUp,
                    backupError: $backupError
                )
                .onAppear {
                    logger.info("Backup sheet presented")
                }
            }
            .sheet(isPresented: $showingRestoreSheet) {
                RestoreSheet(
                    backupService: backupService,
                    isRestoring: $isRestoring,
                    backupError: $backupError,
                    onRestore: { backupData in
                        try backupService.restoreFromBackup(backupData, context: modelContext)
                    }
                )
                .onAppear {
                    logger.info("Restore sheet presented")
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
    
    private func loadBackupInfo() {
        Task {
            do {
                let info = try await backupService.getBackupInfo()
                await MainActor.run {
                    self.backupInfo = info
                }
            } catch {
                // Silently fail - backup info is optional
                await MainActor.run {
                    self.backupInfo = nil
                }
            }
        }
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
