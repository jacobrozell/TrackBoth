import SwiftUI
import SwiftData

// MARK: - Restore Sheet
/// Sheet for restoring data from iCloud backup
struct RestoreSheet: View {
    let backupService: iCloudBackupService
    @Binding var isRestoring: Bool
    @Binding var backupError: String?
    let onRestore: (iCloudBackupService.BackupData) throws -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var backupInfo: BackupInfo?
    @State private var isLoading = true
    @State private var showingConfirmAlert = false
    @State private var showingSuccessAlert = false
    @State private var restoreProgress: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "icloud.and.arrow.down")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Restore from iCloud")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Restore your data from the latest iCloud backup. This will replace all current data.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                if isLoading {
                    // Loading State
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Checking for backups...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                } else if let backupInfo = backupInfo {
                    // Backup Info
                    VStack(spacing: 16) {
                        HStack {
                            Text("Available Backup:")
                                .font(.headline)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                Text("Backup Date")
                                Spacer()
                                Text(backupInfo.timestamp, style: .date)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                Text("Backup Time")
                                Spacer()
                                Text(backupInfo.timestamp, style: .time)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("Version")
                                Spacer()
                                Text(backupInfo.version)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                } else {
                    // No Backup Found
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("No Backup Found")
                            .font(.headline)
                        
                        Text("No iCloud backup was found. Please create a backup first.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Progress
                if isRestoring {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text(restoreProgress)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Error Message
                if let error = backupError {
                    Text(error)
                        .font(.body)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    if let _ = backupInfo {
                        Button("Restore from Backup") {
                            showingConfirmAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isRestoring)
                    }
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("Restore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadBackupInfo()
        }
        .alert("Confirm Restore", isPresented: $showingConfirmAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore", role: .destructive) {
                startRestore()
            }
        } message: {
            Text("This will replace all current data with the backup. This action cannot be undone.")
        }
        .alert("Restore Complete", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your data has been successfully restored from iCloud.")
        }
    }
    
    private func loadBackupInfo() {
        Task {
            do {
                let info = try await backupService.getBackupInfo()
                await MainActor.run {
                    self.backupInfo = info
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.backupInfo = nil
                    self.isLoading = false
                    self.backupError = error.localizedDescription
                }
            }
        }
    }
    
    private func startRestore() {
        Task {
            isRestoring = true
            backupError = nil
            restoreProgress = "Downloading backup..."
            
            do {
                // Check iCloud availability
                let isAvailable = await backupService.checkiCloudAvailability()
                guard isAvailable else {
                    backupError = "iCloud is not available. Please check your iCloud settings."
                    isRestoring = false
                    return
                }
                
                restoreProgress = "Downloading backup data..."
                let backupData = try await backupService.downloadLatestBackup()
                
                restoreProgress = "Restoring data..."
                try onRestore(backupData)
                
                restoreProgress = "Restore complete!"
                isRestoring = false
                showingSuccessAlert = true
                
            } catch {
                backupError = error.localizedDescription
                isRestoring = false
            }
        }
    }
}

#Preview {
    RestoreSheet(
        backupService: iCloudBackupService(),
        isRestoring: .constant(false),
        backupError: .constant(nil),
        onRestore: { _ in }
    )
}
