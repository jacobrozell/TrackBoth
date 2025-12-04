import SwiftUI

// MARK: - HistoryEntryDetailView Component
/// Detail view component for displaying comprehensive history entry information
struct HistoryEntryDetailView: View {
    let entry: MetricEntry
    let metric: Metric?
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: entry.date)
    }
    
    private var isSuccess: Bool {
        guard let metric = metric else { return false }
        return metric.habitType == .positive ? entry.value : !entry.value
    }
    
    private var statusText: String {
        guard let metric = metric else { return "Unknown" }
        if metric.habitType == .positive {
            return entry.value ? "Completed" : "Not Completed"
        } else {
            return entry.value ? "Not Avoided" : "Avoided"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        if let metric = metric {
                            HStack(spacing: 12) {
                                Image(systemName: metric.habitType.icon)
                                    .foregroundColor(metric.habitType == .positive ? .currentSuccess : .currentError)
                                    .font(.system(size: 24, weight: .medium))
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(metric.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.currentText)
                                    
                                    Text(dayOfWeek)
                                        .font(.subheadline)
                                        .foregroundColor(.currentSecondaryText)
                                }
                                
                                Spacer()
                                
                                // Status indicator
                                VStack(alignment: .trailing, spacing: 4) {
                                    Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isSuccess ? Color.currentSuccess : Color.currentError)
                                        .font(.system(size: 24))
                                    
                                    Text(statusText)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(isSuccess ? Color.currentSuccess : Color.currentError)
                                }
                            }
                        }
                        
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(.currentSecondaryText)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Status Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.currentText)
                        
                        HStack {
                            Text(statusText)
                                .font(.body)
                                .foregroundColor(.currentText)
                            
                            Spacer()
                            
                            Text(entry.value ? "Yes" : "No")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.currentSecondaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.currentSecondaryBackground)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Quantity Section
                    if let quantityString = entry.quantityString {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quantity")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.currentText)
                            
                            HStack {
                                Text(quantityString)
                                    .font(.body)
                                    .foregroundColor(.currentText)
                                
                                Spacer()
                                
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.currentAccent)
                                    .font(.system(size: 16))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.currentSecondaryBackground)
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Details Section
                    if let details = entry.details, !details.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Details")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.currentText)
                            
                            Text(details)
                                .font(.body)
                                .foregroundColor(.currentText)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.currentSecondaryBackground)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Motivation Section
                    if let motivation = entry.motivation, !motivation.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily Motivation")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.currentText)
                            
                            Text(motivation)
                                .font(.body)
                                .foregroundColor(.currentText)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.currentSecondaryBackground)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color.currentBackground)
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.currentPrimary)
                }
            }
        }
    }
}

#Preview {
    HistoryEntryDetailView(
        entry: MetricEntry(metricID: UUID(), date: Date(), value: true),
        metric: Metric(name: "Exercise", habitType: .positive)
    )
    .padding()
}
