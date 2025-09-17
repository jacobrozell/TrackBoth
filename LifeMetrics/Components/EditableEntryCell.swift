import SwiftUI
import SwiftData

struct EditableEntryCell: View {
    @Environment(\.modelContext) private var modelContext
    let entry: MetricEntry
    let metrics: [Metric]
    
    @State private var isEditing = false
    @State private var editingDetails = ""
    @State private var editingMotivation = ""
    @State private var editingValue = false
    @State private var editingQuantity = 1
    @State private var editingUnit = ""
    
    private var metric: Metric? {
        metrics.first { $0.id == entry.metricID }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var isVice: Bool {
        metric?.habitType == .vice
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Date and status
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateFormatter.string(from: entry.date))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.currentText)
                    
                    HStack(spacing: 4) {
                        // Focus on boolean status - show traditional status
                        Image(systemName: entry.value ? (isVice ? "xmark.circle.fill" : "checkmark.circle.fill") : (isVice ? "checkmark.circle.fill" : "xmark.circle.fill"))
                            .foregroundColor(entry.value ? (isVice ? .currentError : .currentSuccess) : (isVice ? .currentSuccess : .currentError))
                            .font(.caption)
                        
                        Text(entry.value ? (isVice ? "Did it" : "Done") : (isVice ? "Avoided" : "Skipped"))
                            .font(.caption)
                            .foregroundColor(.currentSecondaryText)
                    }
                    
                    // Metric name and quantity - small and unobtrusive
                    if let metric = metric {
                        HStack(spacing: 4) {
                            Text(metric.name)
                                .font(.caption2)
                                .foregroundColor(.currentSecondaryText)
                                .opacity(0.7)
                            
                            if let quantityString = entry.quantityString {
                                Text(quantityString)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.currentSecondaryText)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.currentSecondaryBackground)
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Edit button
                Button {
                    editingDetails = entry.details ?? ""
                    editingMotivation = entry.motivation ?? ""
                    editingValue = entry.value
                    editingQuantity = entry.quantity ?? 1
                    editingUnit = entry.unit ?? ""
                    isEditing = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.currentAccent)
                }
            }
            
            // Details
            if let details = entry.details, !details.isEmpty {
                Text(details)
                    .font(.body)
                    .foregroundColor(.currentText)
                    .padding(.vertical, 4)
            }
            
            // Motivation (for vices)
            if let motivation = entry.motivation, !motivation.isEmpty {
                Text(motivation)
                    .font(.caption)
                    .foregroundColor(.currentSecondaryText)
                    .italic()
                    .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color.currentBackground)
        .cornerRadius(12)
        .sheet(isPresented: $isEditing) {
            EditEntryView(
                entry: entry,
                metric: metric,
                editingDetails: $editingDetails,
                editingMotivation: $editingMotivation,
                editingValue: $editingValue,
                isPresented: $isEditing,
                editingQuantity: $editingQuantity,
                editingUnit: $editingUnit
            )
        }
    }
}
