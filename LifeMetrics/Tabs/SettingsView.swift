import SwiftUI
import SwiftData
import UniformTypeIdentifiers

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
    @State private var showingImportPicker = false
    @State private var showingImportConfirmation = false
    @State private var showingImportSuccess = false
    @State private var showingImportError = false
    @State private var pendingImportURL: URL?
    @State private var importErrorMessage: String?
    @State private var importedSummary: String?
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
        let totalHabits = metrics.filter { $0.habitType == .positive }.count
        let totalVices = metrics.filter { $0.habitType == .vice }.count
        logger.debug("Share app content calculated - Habits: \(totalHabits), Vices: \(totalVices)", category: .business)
        let totalEntries = entries.count
        
        return """
        📱 Check out TrackBoth - my habit tracking app!
        
        I've been using it to track \(totalHabits) positive habits and \(totalVices) vices, with \(totalEntries) total entries logged.
        
        ✨ Features:
        • Track both positive habits and vices
        • Visual progress charts and streaks
        • Goal setting and tracking
        • Motivation system
        • Quantity tracking
        • Beautiful themes
        
        Perfect for building better habits and breaking bad ones! 🎯
        
        #HabitTracking #PersonalDevelopment #TrackBoth
        """
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.currentBackground.ignoresSafeArea()
                List {
                // Data Management Section
                Section("Data Management") {
                    Button("Export Data") {
                        logger.logUserAction("Export data button tapped")
                        exportData = generateExportData()
                        showingExportSheet = true
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.settingsExportData)
                    .foregroundColor(Color.currentPrimary)
                    .listRowBackground(Color.currentSecondaryBackground)

                    Button("Import Data") {
                        logger.logUserAction("Import data button tapped")
                        showingImportPicker = true
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.settingsImportData)
                    .foregroundColor(Color.currentPrimary)
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    if ProductSurface.showsDemoData && !metrics.isEmpty && DemoDataGenerator.hasDemoData() {
                        Button("Clear Demo Data") {
                            logger.logUserAction("Clear demo data button tapped")
                            DemoDataGenerator.clearDemoData(modelContext: modelContext)
                        }
                        .foregroundColor(Color.currentWarning)
                        .listRowBackground(Color.currentSecondaryBackground)
                    }
                    
                    Button("Delete All Data") {
                        logger.logUserAction("Delete all data button tapped")
                        showingDeleteConfirmation = true
                    }
                    .foregroundColor(Color.currentError)
                    .listRowBackground(Color.currentSecondaryBackground)
                }
                
                // iCloud Backup Section
                Section("iCloud Backup") {
                    Button("Backup to iCloud") {
                        logger.logUserAction("Backup to iCloud button tapped")
                        showingBackupSheet = true
                    }
                    .foregroundColor(Color.currentPrimary)
                    .disabled(isBackingUp)
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    Button("Restore from iCloud") {
                        logger.logUserAction("Restore from iCloud button tapped")
                        showingRestoreSheet = true
                    }
                    .foregroundColor(Color.currentSuccess)
                    .disabled(isRestoring)
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    if let backupInfo = backupInfo {
                        HStack {
                            Text("Last Backup")
                            Spacer()
                            Text(backupInfo.timestamp, style: .relative)
                                .foregroundColor(Color.currentSecondaryText)
                        }
                        .listRowBackground(Color.currentSecondaryBackground)
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
                    .listRowBackground(Color.currentSecondaryBackground)
                }
                
                // Theme Settings Section
                Section("Appearance") {
                    // App Theme Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("App Theme")
                            .font(.headline)
                            .themedPrimaryText()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(AppTheme.allThemes, id: \.name) { theme in
                                    CompactThemeCard(
                                        theme: theme,
                                        isSelected: themeManager.currentAppTheme.name == theme.name
                                    ) {
                                        themeManager.updateAppTheme(theme)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    // Theme Preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview")
                            .font(.subheadline)
                            .themedSecondaryText()
                        
                        themeManager.currentAppTheme.preview()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    // Font Design Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Font")
                            .font(.headline)
                            .themedPrimaryText()
                        
                        Picker("Font Design", selection: Binding(
                            get: { themeManager.selectedFontDesign },
                            set: { themeManager.updateFontDesign($0) }
                        )) {
                            ForEach(FontDesign.allCases, id: \.self) { design in
                                HStack {
                                    Text(design.displayName)
                                    if design == themeManager.selectedFontDesign {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color.currentPrimary)
                                    }
                                }
                                .tag(design)
                            }
                        }
                        .pickerStyle(.menu)
                        .listRowBackground(Color.currentSecondaryBackground)
                        
                        // Font Preview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sample Text")
                                .font(AppTypography.h3)
                            Text("This is how the font looks in the app")
                                .font(AppTypography.body)
                            Text("Smaller text example")
                                .font(AppTypography.caption)
                        }
                        .padding()
                        .background(Color.currentSecondaryBackground)
                        .cornerRadius(8)
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    // Theme Reset Option
                    Button("Reset to Default Theme") {
                        logger.logUserAction("Reset theme button tapped")
                        themeManager.resetToDefaultTheme()
                    }
                    .foregroundColor(Color.currentWarning)
                    .listRowBackground(Color.currentSecondaryBackground)
                }
                
                // Help & Support Section
                Section("Help & Support") {
                    Button("Share App") {
                        showingShareSheet = true
                    }
                    .foregroundColor(Color.currentPrimary)
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    Button("View Onboarding Again") {
                        showOnboardingAgain()
                    }
                    .foregroundColor(Color.currentPrimary)
                    .listRowBackground(Color.currentSecondaryBackground)
                }
                
                // App Information Section
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(Color.currentSecondaryText)
                    }
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    HStack {
                        Text("Total Metrics")
                        Spacer()
                        Text("\(metrics.count)")
                            .foregroundColor(Color.currentSecondaryText)
                    }
                    .listRowBackground(Color.currentSecondaryBackground)

                    HStack {
                        Text("Total Habits")
                        Spacer()
                        Text("\(metrics.filter { $0.habitType == .positive }.count)")
                            .foregroundColor(Color.currentSecondaryText)
                    }
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    HStack {
                        Text("Total Vices")
                        Spacer()
                        Text("\(metrics.filter { $0.habitType == .vice }.count)")
                            .foregroundColor(Color.currentSecondaryText)
                    }
                    .listRowBackground(Color.currentSecondaryBackground)

                    HStack {
                        Text("Total Entries")
                        Spacer()
                        Text("\(entries.count)")
                            .foregroundColor(Color.currentSecondaryText)
                    }
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    HStack {
                        Text("Date Joined")
                        Spacer()
                        Text(dateJoinedText)
                            .foregroundColor(Color.currentSecondaryText)
                    }
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    // Goals are tracked per Metric; no separate count
                }
                
                // Future Features Section
                Section("Coming Soon") {
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundColor(Color.currentSecondaryText)
                        Text("Custom App Icons")
                        Spacer()
                        Text("Soon")
                            .foregroundColor(Color.currentSecondaryText)
                            .font(.caption)
                    }
                    .listRowBackground(Color.currentSecondaryBackground)
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color.currentSecondaryText)
                        Text("Donate")
                        Spacer()
                        Text("Soon")
                            .foregroundColor(Color.currentSecondaryText)
                            .font(.caption)
                    }
                    .listRowBackground(Color.currentSecondaryBackground)
                }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .environment(\.defaultMinListRowHeight, 44)
            }
            .navigationTitle("Settings")
            .toolbarBackground(Color.currentBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                // Force update when theme changes
                themeManager.objectWillChange.send()
                logger.info("SettingsView appeared")
                logger.debug("Metrics count: \(metrics.count), Entries count: \(entries.count)", category: .data)
                // Update time every second
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    currentTime = Date()
                }
                
                // Load backup info
                loadBackupInfo()
            }
            .onChange(of: themeManager.currentAppTheme) { _, _ in
                // Force refresh when theme changes
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
            .alert("Import Data?", isPresented: $showingImportConfirmation) {
                Button("Cancel", role: .cancel) {
                    pendingImportURL = nil
                }
                Button("Replace All Data", role: .destructive) {
                    performImport()
                }
            } message: {
                Text("This will replace all habits and entries with the selected JSON export file.")
            }
            .alert("Import Complete", isPresented: $showingImportSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importedSummary ?? "Your data was imported.")
            }
            .alert("Import Failed", isPresented: $showingImportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importErrorMessage ?? "The file could not be imported.")
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImportSelection(result)
            }
        }
    }

    private func handleImportSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            pendingImportURL = url
            showingImportConfirmation = true
        case .failure(let error):
            importErrorMessage = error.localizedDescription
            showingImportError = true
        }
    }

    private func performImport() {
        guard let url = pendingImportURL else { return }
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed { url.stopAccessingSecurityScopedResource() }
            pendingImportURL = nil
        }

        do {
            let data = try Data(contentsOf: url)
            let payload = try TrackBothExport.decode(data)
            let counts = try ExportImportService.importPayload(payload, into: modelContext)
            importedSummary = "Imported \(counts.metrics) habits and \(counts.entries) entries."
            showingImportSuccess = true
            logger.info("JSON import succeeded — \(counts.metrics) metrics, \(counts.entries) entries", category: .data)
        } catch {
            importErrorMessage = error.localizedDescription
            showingImportError = true
            logger.error("JSON import failed: \(error.localizedDescription)", category: .data)
        }
    }
    
    private func generateExportData() -> Data? {
        do {
            return try TrackBothExport.encode(metrics: metrics, entries: entries)
        } catch {
            logger.error("Failed to encode export data: \(error.localizedDescription)", category: .data)
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
// See Domain/Data/TrackBothExport.swift for canonical export types.

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
