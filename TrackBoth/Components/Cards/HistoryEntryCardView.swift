import SwiftUI

// MARK: - History Entry Card View
/// Compact history row — tap for full entry detail.
struct HistoryEntryCardView: View {
    let entry: MetricEntry
    let metrics: [Metric]
    let entries: [MetricEntry]

    @State private var showingDetails = false

    private var metric: Metric? {
        metrics.first { $0.id == entry.metricID }
    }

    private var subtitleText: String {
        "\(dayLabel) · \(statusText)"
    }

    private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: entry.date)
    }

    private var showsStatus: Bool {
        metric != nil && TrackingSemantics.isLoggedForDay(entry: entry)
    }

    private var isSuccess: Bool {
        guard let metric else { return false }
        return TrackingSemantics.isLoggedSuccess(habitType: metric.habitType, entry: entry)
    }

    private var statusText: String {
        guard let metric else { return "Not logged" }
        return TrackingSemantics.statusLabel(habitType: metric.habitType, entry: entry).text
    }

    var body: some View {
        Button {
            showingDetails = true
        } label: {
            HStack(alignment: .center, spacing: 14) {
                statusIcon

                VStack(alignment: .leading, spacing: 3) {
                    Text(metric?.name ?? "Unknown")
                        .bodyMedium()
                        .foregroundStyle(Color.currentText)
                        .multilineTextAlignment(.leading)

                    Text(subtitleText)
                        .bodySmall()
                        .foregroundStyle(Color.currentSecondaryText)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.currentSecondaryText.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(CardPressButtonStyle())
        .accessibilityLabel("\(metric?.name ?? "Unknown"), \(statusText), \(dayLabel)")
        .sheet(isPresented: $showingDetails) {
            HistoryEntryDetailView(entry: entry, metric: metric)
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        if showsStatus {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3)
                .foregroundStyle(isSuccess ? Color.currentSuccess : Color.currentError)
        } else {
            Image(systemName: "circle")
                .font(.title3)
                .foregroundStyle(Color.currentSecondaryText)
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
