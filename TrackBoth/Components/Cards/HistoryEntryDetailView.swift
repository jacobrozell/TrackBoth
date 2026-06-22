import SwiftUI
import SwiftData

// MARK: - HistoryEntryDetailView Component
/// Detail view component for displaying comprehensive history entry information
struct HistoryEntryDetailView: View {
    let entry: MetricEntry
    let metric: Metric?

    @Query private var entries: [MetricEntry]
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    init(entry: MetricEntry, metric: Metric?) {
        self.entry = entry
        self.metric = metric
        _entries = QueryDescriptors.entriesForStreakLookback(endingOn: entry.date)
    }

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
        return TrackingSemantics.isLoggedSuccess(habitType: metric.habitType, entry: entry)
    }

    private var statusText: String {
        guard let metric = metric else { return "Unknown" }
        if metric.habitType == .positive {
            return entry.value ? "Completed" : "Not Completed"
        } else {
            return entry.value ? "Not Avoided" : "Avoided"
        }
    }

    private var streakAtEntryDate: Int {
        guard let metric else { return 0 }
        return StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: entry.date)
    }

    private var savingsLabel: String? {
        guard let metric, metric.habitType == .vice, isSuccess else { return nil }
        let cost = metric.costPerUnitDecimal
        return ViceSavingsCalculator.savingsLabel(streak: streakAtEntryDate, costPerUnit: cost)
    }

    private var recoveryLabel: String? {
        guard let metric,
              metric.habitType == .vice,
              isSuccess,
              MetricDisplayPreferences.showTimeSinceSlip(for: metric.id) else { return nil }
        return ViceSlipTimer.formattedRecoveryTime(
            metricID: metric.id,
            entries: entries,
            asOf: entry.date
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    statusSection

                    if let savingsLabel {
                        savingsSection(label: savingsLabel)
                    }

                    if let recoveryLabel {
                        recoverySection(label: recoveryLabel)
                    }

                    if let quantityString = entry.quantityString {
                        quantitySection(quantityString)
                    }

                    if let details = entry.details, !details.isEmpty {
                        textSection(title: "Details", body: details)
                    }

                    if let motivation = entry.motivation, !motivation.isEmpty {
                        textSection(title: "Note", body: motivation)
                    } else if let primary = metric?.primaryMotivation, !primary.isEmpty, metric?.habitType == .vice {
                        textSection(title: "Why You're Avoiding This", body: primary)
                    }

                    if let mood = entry.mood, !mood.isEmpty {
                        moodSection(mood)
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(Color.currentBackground)
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.currentPrimary)
                }
            }
        }
    }

    private var headerSection: some View {
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
    }

    private var statusSection: some View {
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

                if metric?.habitType == .vice, isSuccess, streakAtEntryDate > 0 {
                    Text("\(streakAtEntryDate) days clean")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.currentWarning)
                }

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
    }

    private func savingsSection(label: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Money Saved")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.currentText)

            HStack {
                Text(label)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.currentSuccess)

                Spacer()

                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(Color.currentSuccess)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.currentSuccess.opacity(0.12))
            )
        }
        .padding(.horizontal, 20)
    }

    private func recoverySection(label: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recovery")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.currentText)

            HStack {
                Text(label)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.currentWarning)

                Spacer()

                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .foregroundColor(Color.currentWarning)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.currentWarning.opacity(0.12))
            )
        }
        .padding(.horizontal, 20)
    }

    private func quantitySection(_ quantityString: String) -> some View {
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

    private func moodSection(_ mood: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.currentText)

            Text(mood)
                .font(.largeTitle)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.currentSecondaryBackground)
                )
        }
        .padding(.horizontal, 20)
    }

    private func textSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.currentText)

            Text(body)
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
}

#Preview {
    HistoryEntryDetailView(
        entry: MetricEntry(metricID: UUID(), date: Date(), value: false),
        metric: Metric(name: "Smoking", habitType: .vice)
    )
    .padding()
}
