import SwiftUI

// MARK: - HistoryEntryCardView Component
/// Card component for displaying individual history entries
struct HistoryEntryCardView: View {
    let entry: MetricEntry
    let metrics: [Metric]
    let entries: [MetricEntry]

    @State private var showingDetails = false
    
    private var metric: Metric? {
        metrics.first { $0.id == entry.metricID }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: entry.date, relativeTo: Date())
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: entry.date)
    }
    
    private var showsStatusBadge: Bool {
        metric != nil && TrackingSemantics.isLoggedForDay(entry: entry)
    }

    private var isSuccess: Bool {
        guard let metric else { return false }
        return TrackingSemantics.isLoggedSuccess(habitType: metric.habitType, entry: entry)
    }
    
    private var savingsSubtitle: String? {
        guard let metric, metric.habitType == .vice, isSuccess else { return nil }
        let cost = MetricCostStore.costPerUnit(for: metric.id)
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: entry.date)
        return ViceSavingsCalculator.savingsLabel(streak: streak, costPerUnit: cost)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    if let metric = metric {
                        HStack(spacing: 8) {
                            Image(systemName: metric.habitType.icon)
                                .foregroundColor(metric.habitType == .positive ? .currentSuccess : .currentError)
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 20)
                            
                            Text(metric.name)
                                .font(.headline)
                                .foregroundColor(.currentText)
                        }
                    }
                    
                    Text("\(dayOfWeek) • \(timeAgo)")
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                        .padding(.leading, 28) // Align with metric name

                    if let savingsSubtitle {
                        Text(savingsSubtitle)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.currentSuccess)
                            .padding(.leading, 28)
                    }
                }
                
                Spacer()

                if showsStatusBadge {
                    Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isSuccess ? Color.currentSuccess : Color.currentError)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            // Details and motivation
            VStack(alignment: .leading, spacing: 8) {
                if let details = entry.details, !details.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Details")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.currentSecondaryText)
                        Text(details)
                            .font(.body)
                            .foregroundColor(.currentText)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                if let motivation = entry.motivation, !motivation.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Motivation")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.currentSecondaryText)
                        Text(motivation)
                            .font(.body)
                            .foregroundColor(.currentText)
                            .multilineTextAlignment(.leading)
                    }
                }

                if let mood = entry.mood, !mood.isEmpty {
                    Text("Mood: \(mood)")
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                }

                if let quantityString = entry.quantityString {
                    HStack {
                        Text("Quantity:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.currentSecondaryText)
                        Text(quantityString)
                            .font(.caption)
                            .foregroundColor(.currentText)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
            // Bottom accent
            Rectangle()
                .fill(
                    showsStatusBadge
                        ? (isSuccess ? Color.currentSuccess.opacity(0.3) : Color.currentError.opacity(0.3))
                        : Color.currentSecondaryText.opacity(0.2)
                )
                .frame(height: 3)
                .cornerRadius(1.5)
        }
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("History entry for \(metric?.name ?? "Unknown")\(showsStatusBadge ? ": \(isSuccess ? "Success" : "Not completed")" : "")")
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            HistoryEntryDetailView(entry: entry, metric: metric)
        }
    }
}

#Preview {
    HistoryEntryCardView(
        entry: MetricEntry(metricID: UUID(), date: Date(), value: true),
        metrics: [Metric(name: "Exercise", habitType: .positive)],
        entries: []
    )
    .padding()
}
