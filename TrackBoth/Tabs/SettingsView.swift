import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - SettingsView
/// View for app settings, data export, and configuration
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.deviceLayout) private var deviceLayout
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
    @State private var exportFileURL: URL?
    @State private var showingExportError = false
    @State private var isImporting = false
    @AppStorage("weekStartDay") private var weekStartDay: Int = 1 // 1 = Sunday (default)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.currentBackground.ignoresSafeArea()
                List {
                Section {
                    settingsActionButton(
                        "Export Data",
                        systemImage: "square.and.arrow.up"
                    ) {
                        logger.logUserAction("Export data button tapped")
                        if let url = writeExportFile() {
                            exportFileURL = url
                            showingExportSheet = true
                            HapticFeedback.success()
                        } else {
                            showingExportError = true
                        }
                    }
                    .disabled(isImporting)
                    .accessibilityIdentifier(AccessibilityIdentifiers.settingsExportData)

                    settingsActionButton(
                        "Import Data",
                        systemImage: "square.and.arrow.down",
                        isLoading: isImporting
                    ) {
                        logger.logUserAction("Import data button tapped")
                        showingImportPicker = true
                    }
                    .disabled(isImporting)
                    .accessibilityIdentifier(AccessibilityIdentifiers.settingsImportData)

                    if ProductSurface.showsDemoData {
                        if DemoDataGenerator.hasDemoData() {
                            Button("Clear Demo Data") {
                                logger.logUserAction("Clear demo data button tapped")
                                HapticFeedback.warning()
                                DemoDataGenerator.clearDemoData(modelContext: modelContext)
                            }
                            .foregroundColor(Color.currentWarning)
                            .listRowBackground(Color.currentSecondaryBackground)
                        } else {
                            Button("Try Demo Data") {
                                logger.logUserAction("Generate demo data button tapped")
                                HapticFeedback.success()
                                DemoDataGenerator.generateDemoData(modelContext: modelContext)
                            }
                            .foregroundColor(Color.currentPrimary)
                            .listRowBackground(Color.currentSecondaryBackground)
                        }
                    }
                } header: {
                    SettingsSectionHeader("Data Management")
                }

                Section {
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
                    .onChange(of: weekStartDay) { _, _ in
                        HapticFeedback.selection()
                    }
                    .listRowBackground(Color.currentSecondaryBackground)
                } header: {
                    SettingsSectionHeader("Week Settings")
                }

                SettingsAppearanceSection()

                SettingsDataSection(showingDeleteConfirmation: $showingDeleteConfirmation)
                SettingsHelpAndFeedbackSection()
                SettingsAboutSection(onViewOnboarding: showOnboardingAgain)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
                .environment(\.defaultMinListRowHeight, 44)
                .frame(maxWidth: deviceLayout.isPad ? 720 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.currentBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                logger.info("SettingsView appeared")
                logger.debug("Metrics count: \(metrics.count), Entries count: \(entries.count)", category: .data)
            }
            .sheet(isPresented: $showingExportSheet, onDismiss: {
                exportFileURL = nil
            }) {
                if let exportFileURL {
                    ShareSheet(activityItems: [exportFileURL])
                        .onAppear {
                            logger.info("Export data sheet presented")
                        }
                }
            }
            .alert("Reset All Local Data", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset All", role: .destructive) {
                    HapticFeedback.warning()
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all habits, vices, and entries on this device. This action cannot be undone.")
            }
            .alert("Import Data?", isPresented: $showingImportConfirmation) {
                Button("Cancel", role: .cancel) {
                    pendingImportURL = nil
                }
                Button("Replace All Data", role: .destructive) {
                    performImport()
                }
            } message: {
                Text("This will replace all habits, vices, and entries with the selected JSON export file.")
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
            .alert("Export Failed", isPresented: $showingExportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your data could not be exported. Try again, or contact support if the problem continues.")
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
        isImporting = true
        defer { isImporting = false }

        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed { url.stopAccessingSecurityScopedResource() }
            pendingImportURL = nil
        }

        do {
            let data = try Data(contentsOf: url)
            let payload = try TrackBothExport.decode(data)
            let counts = try ExportImportService.importPayload(payload, into: modelContext)
            importedSummary = ProductSurface.showsGoals || counts.goals > 0
                ? "Imported \(counts.metrics) habits, \(counts.entries) entries, and \(counts.goals) goals."
                : "Imported \(counts.metrics) habits or vices and \(counts.entries) log entries."
            showingImportSuccess = true
            HapticFeedback.success()
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

    private func writeExportFile() -> URL? {
        guard let data = generateExportData() else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("TrackBoth-export-\(ISO8601DateFormatter().string(from: Date())).json")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            logger.error("Failed to write export file: \(error.localizedDescription)", category: .data)
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
            HapticFeedback.success()
        }
    }

    private func showOnboardingAgain() {
        HapticFeedback.light()
        UserDefaults.standard.set(false, forKey: ThemePreferences.hasCompletedOnboarding)
        AppEvent.post(.onboardingCompleted)
    }

    private func settingsActionButton(
        _ title: String,
        systemImage: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer(minLength: 0)
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
        .foregroundStyle(Color.currentText)
        .listRowBackground(Color.currentSecondaryBackground)
    }
}

// MARK: - Settings Data Section
private struct SettingsDataSection: View {
    @Binding var showingDeleteConfirmation: Bool

    var body: some View {
        Section {
            Button("Reset All Local Data", role: .destructive) {
                logger.logUserAction("Reset all local data button tapped")
                showingDeleteConfirmation = true
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.settingsResetAllData)
            .listRowBackground(Color.currentSecondaryBackground)
        } header: {
            SettingsSectionHeader("Data")
        }
    }
}

// MARK: - Settings Help & Feedback Section
private struct SettingsHelpAndFeedbackSection: View {
    var body: some View {
        Section {
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
        } header: {
            SettingsSectionHeader("Help & Feedback")
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
        .foregroundStyle(Color.currentPrimary)
        .accessibilityIdentifier(identifier)
        .listRowBackground(Color.currentSecondaryBackground)
    }
}

// MARK: - Settings About Section
private struct SettingsAboutSection: View {
    let onViewOnboarding: () -> Void

    var body: some View {
        Section {
            Button {
                HapticFeedback.light()
                onViewOnboarding()
            } label: {
                Label("View Onboarding", systemImage: "book.pages")
            }
            .foregroundStyle(Color.currentText)
            .accessibilityIdentifier(AccessibilityIdentifiers.settingsViewOnboarding)
            .listRowBackground(Color.currentSecondaryBackground)

            Text(AppSupport.versionLabel)
                .foregroundColor(Color.currentSecondaryText)
                .listRowBackground(Color.currentSecondaryBackground)

        } header: {
            SettingsSectionHeader("About")
        }
    }
}

private struct SettingsSectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .foregroundStyle(Color.currentSecondaryText)
    }
}

private struct SettingsSectionFooter: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .foregroundStyle(Color.currentSecondaryText)
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
            SettingsSectionHeader("Appearance")
        } footer: {
            SettingsSectionFooter("Theme colors apply across Track, Insights, Goals, Motivation, and Settings.")
                .font(.footnote)
        }
    }

    private var leanThemePicker: some View {
        ForEach(AppTheme.availableThemes, id: \.name) { theme in
            Button {
                guard themeManager.currentAppTheme.name != theme.name else { return }
                HapticFeedback.selection()
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
                            guard themeManager.currentAppTheme.name != theme.name else { return }
                            HapticFeedback.selection()
                            themeManager.updateAppTheme(theme)
                        }
                    }
                }
            }

            Button("Reset to Default Theme") {
                logger.logUserAction("Reset theme button tapped")
                HapticFeedback.light()
                themeManager.resetToDefaultTheme()
            }
            .font(.subheadline)
            .foregroundStyle(Color.currentWarning)
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.currentSecondaryBackground)
    }

    private func themeIcon(for theme: AppTheme) -> String {
        theme.name == "Midnight" ? "moon.stars.fill" : "water.waves"
    }
}

private struct FontDesignPicker: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Font")
                .font(.headline)
                .foregroundStyle(Color.currentText)

            Picker("Font Design", selection: Binding(
                get: { themeManager.selectedFontDesign },
                set: { newValue in
                    guard themeManager.selectedFontDesign != newValue else { return }
                    HapticFeedback.selection()
                    themeManager.updateFontDesign(newValue)
                }
            )) {
                ForEach(FontDesign.allCases, id: \.self) { design in
                    Text(design.displayName).tag(design)
                }
            }
            .pickerStyle(.menu)

            VStack(alignment: .leading, spacing: 8) {
                Text("Sample Text")
                    .font(AppTypography.h3)
                    .foregroundStyle(Color.currentText)
                Text("This is how the font looks in the app")
                    .font(AppTypography.body)
                    .foregroundStyle(Color.currentText)
                Text("Smaller text example")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.currentSecondaryText)
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
