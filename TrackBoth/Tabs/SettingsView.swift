import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - SettingsView
/// View for app settings, data export, and configuration
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var metrics: [Metric]
    @Query private var entries: [MetricEntry]

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
    @AppStorage("weekStartDay") private var weekStartDay: Int = 1 // 1 = Sunday (default)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.currentBackground.ignoresSafeArea()
                List {
                Section {
                    Button {
                        logger.logUserAction("Export data button tapped")
                        exportData = generateExportData()
                        showingExportSheet = true
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.settingsExportData)

                    Button {
                        logger.logUserAction("Import data button tapped")
                        showingImportPicker = true
                    } label: {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.settingsImportData)

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
                } header: {
                    Text("Data Management")
                }

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
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.currentBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                logger.info("SettingsView appeared")
                logger.debug("Metrics count: \(metrics.count), Entries count: \(entries.count)", category: .data)
            }
            .sheet(isPresented: $showingExportSheet) {
                if let exportData = exportData {
                    ShareSheet(activityItems: [exportData])
                        .onAppear {
                            logger.info("Export data sheet presented")
                        }
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
            importedSummary = "Imported \(counts.metrics) habits, \(counts.entries) entries, and \(counts.goals) goals."
            showingImportSuccess = true
            WidgetSyncCoordinator.onDataChanged(context: modelContext)
            logger.info(
                "JSON import succeeded — \(counts.metrics) metrics, \(counts.entries) entries, \(counts.goals) goals",
                category: .data
            )
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
            for entry in entries {
                modelContext.delete(entry)
            }

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
        UserDefaults.standard.set(false, forKey: ThemePreferences.hasCompletedOnboarding)
        AppEvent.post(.onboardingCompleted)
    }
}

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

            settingsLink(
                destination: AppLinks.appStoreReview,
                title: "Rate TrackBoth",
                systemImage: "star",
                identifier: AccessibilityIdentifiers.settingsRateApp
            )

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
            .listRowBackground(Color.currentSecondaryBackground)

            Text(AppSupport.versionLabel)
                .foregroundColor(Color.currentSecondaryText)
                .listRowBackground(Color.currentSecondaryBackground)

        } header: {
            Text("About")
        }
    }
}

// MARK: - Settings Appearance Section
private struct SettingsAppearanceSection: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        Section {
            if ProductSurface.showsExtendedThemes {
                extendedThemePicker
            } else {
                leanThemePicker
            }

            if ProductSurface.showsExtendedThemes {
                FontDesignPicker()
            }
        } header: {
            Text("Appearance")
        } footer: {
            Text("Theme colors apply across Track, History, and Settings.")
                .font(.footnote)
        }
    }

    private var leanThemePicker: some View {
        ForEach(AppTheme.availableThemes, id: \.name) { theme in
            Button {
                themeManager.updateAppTheme(theme)
            } label: {
                HStack {
                    Label(theme.name, systemImage: themeIcon(for: theme))
                    Spacer()
                    if themeManager.currentAppTheme.name == theme.name {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.currentPrimary)
                    }
                }
            }
            .foregroundStyle(Color.currentText)
            .listRowBackground(Color.currentSecondaryBackground)
        }
    }

    private var extendedThemePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AppTheme.availableThemes, id: \.name) { theme in
                        CompactThemeCard(
                            theme: theme,
                            isSelected: themeManager.currentAppTheme.name == theme.name
                        ) {
                            themeManager.updateAppTheme(theme)
                        }
                    }
                }
            }

            Button("Reset to Default Theme") {
                logger.logUserAction("Reset theme button tapped")
                themeManager.resetToDefaultTheme()
            }
            .font(.subheadline)
            .foregroundStyle(Color.currentWarning)
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.currentSecondaryBackground)
    }

    private func themeIcon(for theme: AppTheme) -> String {
        theme.name == "Midnight" ? "moon.fill" : "sun.max.fill"
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
