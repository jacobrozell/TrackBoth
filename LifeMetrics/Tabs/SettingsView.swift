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
    @State private var exportData: Data?
    @State private var showingRestoreSheet = false
    @State private var showingBackupSheet = false
    @State private var backupService = iCloudBackupService()
    @State private var backupInfo: BackupInfo?
    @State private var isBackingUp = false
    @State private var isRestoring = false
    @State private var backupError: String?
    @AppStorage("weekStartDay") private var weekStartDay: Int = 1 // 1 = Sunday (default)
    @State private var currentTime = Date()

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
                    
                    if ProductSurface.showsDemoData {
                        if DemoDataGenerator.hasDemoData() {
                            Button("Clear Demo Data") {
                                logger.logUserAction("Clear demo data button tapped")
                                DemoDataGenerator.clearDemoData(modelContext: modelContext)
                            }
                            .foregroundColor(Color.currentWarning)
                            .listRowBackground(Color.currentSecondaryBackground)
                        } else {
                            Button("Try Demo Data") {
                                logger.logUserAction("Generate demo data button tapped")
                                DemoDataGenerator.generateDemoData(modelContext: modelContext)
                            }
                            .foregroundColor(Color.currentPrimary)
                            .listRowBackground(Color.currentSecondaryBackground)
                        }
                    }
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
                SettingsAppearanceSection()
                
                SettingsDataSection(showingDeleteConfirmation: $showingDeleteConfirmation)
                SettingsHelpAndFeedbackSection()
                SettingsAboutSection(onViewOnboarding: showOnboardingAgain)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .environment(\.defaultMinListRowHeight, 44)
            }
            .navigationTitle("Settings")
            .toolbarBackground(Color.currentBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
                        WidgetSyncCoordinator.onDataChanged(context: modelContext)
                    }
                )
                .onAppear {
                    logger.info("Restore sheet presented")
                }
            }
            .alert("Reset All Local Data", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset All", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all habits and entries on this device. This action cannot be undone.")
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
            WidgetSyncCoordinator.onDataChanged(context: modelContext)
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
            
            MetricCostStore.clearAll()
            MetricDisplayPreferences.clearAll()
            modelContext.saveChanges(operation: "delete all data", entity: "Model")
            WidgetSyncCoordinator.onDataChanged(context: modelContext)
        }
    }
    
    private func showOnboardingAgain() {
        // Reset the onboarding completion flag
        UserDefaults.standard.set(false, forKey: ThemePreferences.hasCompletedOnboarding)
        AppEvent.post(.onboardingCompleted)
    }
    
    private func loadBackupInfo() {
        Task {
            guard await backupService.checkiCloudAvailability() else {
                await MainActor.run { self.backupInfo = nil }
                return
            }

            do {
                let info = try await backupService.getBackupInfo()
                await MainActor.run {
                    self.backupInfo = info
                }
            } catch BackupError.noBackupFound {
                await MainActor.run { self.backupInfo = nil }
            } catch {
                logger.debug("Could not load iCloud backup info: \(error.localizedDescription)", category: .network)
                await MainActor.run { self.backupInfo = nil }
            }
        }
    }
}

// MARK: - Export Data Models
// See Domain/Data/TrackBothExport.swift for canonical export types.

// MARK: - Settings Data Section
private struct SettingsDataSection: View {
    @Binding var showingDeleteConfirmation: Bool

    var body: some View {
        Section("Data") {
            Button("Reset All Local Data", role: .destructive) {
                logger.logUserAction("Reset all local data button tapped")
                showingDeleteConfirmation = true
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.settingsResetAllData)
            .listRowBackground(Color.currentSecondaryBackground)
        }
    }
}

// MARK: - Settings Help & Feedback Section
private struct SettingsHelpAndFeedbackSection: View {
    var body: some View {
        Section("Help & Feedback") {
            settingsLink(
                destination: AppLinks.support,
                title: "Support & FAQ",
                systemImage: "questionmark.circle",
                identifier: AccessibilityIdentifiers.settingsSupportFAQ
            )

            settingsLink(
                destination: AppSupport.feedbackMailtoURL,
                title: "Send Feedback",
                systemImage: "envelope",
                identifier: AccessibilityIdentifiers.settingsSendFeedback
            )

            if let appStoreReview = AppLinks.appStoreReview {
                settingsLink(
                    destination: appStoreReview,
                    title: "Rate TrackBoth",
                    systemImage: "star",
                    identifier: AccessibilityIdentifiers.settingsRateApp
                )
            }

            if ProductSurface.showsAccessibilityMarketing {
                settingsLink(
                    destination: AppLinks.accessibility,
                    title: "Accessibility",
                    systemImage: "accessibility",
                    identifier: AccessibilityIdentifiers.settingsAccessibility
                )
            }

            settingsLink(
                destination: AppLinks.privacy,
                title: "Privacy Policy",
                systemImage: "hand.raised",
                identifier: AccessibilityIdentifiers.settingsPrivacyPolicy
            )
        }
    }

    private func settingsLink(
        destination: URL,
        title: String,
        systemImage: String,
        identifier: String
    ) -> some View {
        Link(destination: destination) {
            Label(title, systemImage: systemImage)
        }
        .accessibilityIdentifier(identifier)
        .foregroundColor(Color.currentPrimary)
        .listRowBackground(Color.currentSecondaryBackground)
    }
}

// MARK: - Settings About Section
private struct SettingsAboutSection: View {
    let onViewOnboarding: () -> Void

    var body: some View {
        Section {
            Button(action: onViewOnboarding) {
                Label("View Onboarding", systemImage: "book.pages")
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.settingsViewOnboarding)
            .foregroundColor(Color.currentPrimary)
            .listRowBackground(Color.currentSecondaryBackground)

            Text(AppSupport.versionLabel)
                .foregroundColor(Color.currentSecondaryText)
                .listRowBackground(Color.currentSecondaryBackground)

            if let buyDeveloperCoffeeURL = AppLinks.buyDeveloperCoffee {
                Link(destination: buyDeveloperCoffeeURL) {
                    Label("Buy Developer a Coffee", systemImage: "cup.and.saucer.fill")
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.settingsBuyDeveloperCoffee)
                .foregroundColor(Color.currentPrimary)
                .listRowBackground(Color.currentSecondaryBackground)
            }
        } header: {
            Text("About")
        } footer: {
            if AppLinks.buyDeveloperCoffee != nil {
                Text("Optional tip to support development. Opens in Safari.")
            }
        }
    }
}

// MARK: - Settings Appearance Section
private struct SettingsAppearanceSection: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        Section("Appearance") {
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

            VStack(alignment: .leading, spacing: 8) {
                Text("Preview")
                    .font(.subheadline)
                    .themedSecondaryText()

                themeManager.currentAppTheme.preview()
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.currentSecondaryBackground)

            FontDesignPicker()

            Button("Reset to Default Theme") {
                logger.logUserAction("Reset theme button tapped")
                themeManager.resetToDefaultTheme()
            }
            .foregroundColor(Color.currentWarning)
            .listRowBackground(Color.currentSecondaryBackground)
        }
    }
}

private struct FontDesignPicker: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Font")
                .font(.headline)
                .themedPrimaryText()

            Picker("Font Design", selection: Binding(
                get: { themeManager.selectedFontDesign },
                set: { themeManager.updateFontDesign($0) }
            )) {
                ForEach(FontDesign.allCases, id: \.self) { design in
                    Text(design.displayName).tag(design)
                }
            }
            .pickerStyle(.menu)

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
    }
}

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
