import SwiftUI
import SwiftData

// MARK: - Backup Sheet
/// Sheet for backing up data to iCloud
struct BackupSheet: View {
    let backupService: iCloudBackupService
    let metrics: [Metric]
    let entries: [MetricEntry]
    @Binding var isBackingUp: Bool
    @Binding var backupError: String?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var backupProgress: String = ""
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 50))
                        .foregroundColor(Color.currentPrimary)
                    
                    Text("Backup to iCloud")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.currentText)
                    
                    Text("Your data will be securely backed up to iCloud and can be restored on any device.")
                        .font(.body)
                        .foregroundColor(Color.currentSecondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Data Summary
                VStack(spacing: 16) {
                    HStack {
                        Text("Data to Backup:")
                            .font(.headline)
                            .foregroundColor(Color.currentText)
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        DataSummaryRow(
                            icon: "list.bullet",
                            title: "Habits & Vices",
                            count: metrics.count,
                            color: .currentPrimary
                        )
                        
                        DataSummaryRow(
                            icon: "calendar",
                            title: "Entries",
                            count: entries.count,
                            color: .currentSuccess
                        )
                        
                        DataSummaryRow(
                            icon: "star.fill",
                            title: "Starred Entries",
                            count: entries.filter { $0.safeStarred }.count,
                            color: .currentWarning
                        )
                        
                        DataSummaryRow(
                            icon: "number",
                            title: "Quantity Entries",
                            count: entries.filter { $0.hasQuantity }.count,
                            color: .currentAccent
                        )
                    }
                }
                .padding()
                .background(Color.currentBackground)
                .cornerRadius(12)
                
                // Progress
                if isBackingUp {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text(backupProgress)
                            .font(.body)
                            .foregroundColor(Color.currentSecondaryText)
                    }
                }
                
                // Error Message
                if let error = backupError {
                    Text(error)
                        .font(.body)
                        .foregroundColor(Color.currentError)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.currentError.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Start Backup") {
                        logger.logUserAction("Start iCloud backup", details: "Metrics: \(metrics.count), Entries: \(entries.count)")
                        startBackup()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isBackingUp || metrics.isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color.currentBackground)
            .navigationTitle("Backup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Backup Complete", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your data has been successfully backed up to iCloud.")
        }
    }
    
    private func startBackup() {
        logger.info("Starting iCloud backup process", category: .network)
        Task {
            isBackingUp = true
            backupError = nil
            backupProgress = "Preparing backup..."
            
            do {
                // Check iCloud availability
                let isAvailable = await backupService.checkiCloudAvailability()
                guard isAvailable else {
                    backupError = "iCloud is not available. Please check your iCloud settings."
                    isBackingUp = false
                    return
                }
                
                backupProgress = "Creating backup data..."
                let backupData = try await backupService.createBackup(metrics: metrics, entries: entries)
                
                backupProgress = "Uploading to iCloud..."
                try await backupService.uploadBackup(backupData)
                
                backupProgress = "Backup complete!"
                isBackingUp = false
                showingSuccessAlert = true
                logger.info("iCloud backup completed successfully", category: .network)
                
            } catch {
                backupError = error.localizedDescription
                isBackingUp = false
                logger.logError(error, context: "iCloud backup failed")
            }
        }
    }
}

// MARK: - Data Summary Row
struct DataSummaryRow: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
                .foregroundColor(.currentText)
            
            Spacer()
            
            Text("\(count)")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.currentSecondaryText)
        }
    }
}

#Preview {
    BackupSheet(
        backupService: iCloudBackupService(),
        metrics: [],
        entries: [],
        isBackingUp: .constant(false),
        backupError: .constant(nil)
    )
}
