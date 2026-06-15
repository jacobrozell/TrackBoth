import SwiftUI

struct PrimaryMotivationCardView: View {
    let metric: Metric

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: metric.habitType.icon)
                            .foregroundColor(metric.habitType == .positive ? .currentSuccess : .currentError)
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 20)

                        Text(metric.name)
                            .font(.headline)
                            .foregroundColor(.currentText)

                        Image(systemName: "star.fill")
                            .foregroundColor(.currentWarning)
                            .font(.system(size: 14))
                    }

                    Text("Primary Motivation")
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                        .padding(.leading, 28)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            Text(metric.primaryMotivation ?? "")
                .font(.body)
                .foregroundColor(.currentText)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)

            Rectangle()
                .fill(Color.currentWarning.opacity(0.3))
                .frame(height: 3)
                .cornerRadius(1.5)
        }
        .metricCardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Primary motivation for \(metric.name): \(metric.primaryMotivation ?? "")")
    }
}
