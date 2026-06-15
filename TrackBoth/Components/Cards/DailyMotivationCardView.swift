import SwiftUI

struct DailyMotivationCardView: View {
    let entry: MetricEntry
    let metrics: [Metric]

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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    if let metric {
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
                        .padding(.leading, 28)
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

            Text(entry.motivation ?? "")
                .font(.body)
                .foregroundColor(.currentText)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)

            Rectangle()
                .fill(
                    showsStatusBadge
                        ? (isSuccess ? Color.currentSuccess.opacity(0.3) : Color.currentError.opacity(0.3))
                        : Color.currentSecondaryText.opacity(0.2)
                )
                .frame(height: 3)
                .cornerRadius(1.5)
        }
        .metricCardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Daily motivation for \(metric?.name ?? "Unknown"): \(entry.motivation ?? "")")
    }
}
