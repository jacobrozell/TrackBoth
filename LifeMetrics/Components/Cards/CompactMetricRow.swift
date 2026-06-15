import SwiftUI
import SwiftData

// MARK: - CompactMetricRow Component
/// Compact metric row component for displaying metrics in a condensed format
struct CompactMetricRow: View {
    let metric: Metric
    let selectedDate: Date
    let showOptions: Bool
    let onToggle: () -> Void
    let onLog: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @Query private var entries: [MetricEntry]
    @State private var refreshTrigger = UUID()
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var selectedDateEntry: MetricEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        return entries.first { $0.metricID == metric.id && calendar.isDate($0.date, inSameDayAs: startOfDay) }
    }

    private func isMetricCompleted() -> Bool {
        TrackingSemantics.isCompleted(habitType: metric.habitType, entry: selectedDateEntry)
    }

    private var statusInfo: (text: String, color: Color) {
        let status = TrackingSemantics.statusLabel(habitType: metric.habitType, entry: selectedDateEntry)
        let color: Color
        if status.isSuccess {
            color = Color.currentSuccess
        } else if metric.habitType == .vice && TrackingSemantics.isLoggedForDay(entry: selectedDateEntry) {
            color = Color.currentError
        } else {
            color = Color.currentSecondaryText
        }
        return (text: status.text, color: color)
    }

    var body: some View {
        VStack(spacing: 8) {
            if dynamicTypeSize.usesAccessibilityLayout {
                accessibilityRow
            } else {
                compactRow
            }

            if showOptions {
                optionsRow
            }
        }
        .padding(12)
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .accessibilityElement(children: .contain)
        .contextMenu {
            Button(action: onLog) { Label("Log", systemImage: "square.and.pencil") }
            Button(action: onEdit) { Label("Edit Habit", systemImage: "pencil") }
            Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
        }
    }

    private var compactRow: some View {
        HStack(spacing: 12) {
            toggleButton
            metricDetails
            streakBadge
        }
        .contentShape(Rectangle())
    }

    private var accessibilityRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                toggleButton
                Text(metric.name)
                    .font(.headline)
                    .foregroundColor(Color.currentText)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(statusInfo.text)
                .font(.caption)
                .foregroundColor(statusInfo.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(statusInfo.color.opacity(0.15))
                )

            metadataRow

            if let badge = streakBadgeModel {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color.currentWarning)
                    Text(badge.label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.currentText)
                }
            }

            if let recovery = recoveryBadgeLabel {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.heart.fill")
                        .foregroundColor(Color.currentSuccess)
                    Text(recovery)
                        .font(.caption)
                        .foregroundColor(Color.currentSuccess)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onLog() }
    }

    private struct StreakBadgeModel {
        let count: Int
        let label: String
    }

    private var streakBadgeModel: StreakBadgeModel? {
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: selectedDate)
        guard metric.hasBeenLogged, streak > 0 else { return nil }
        let label = metric.habitType == .positive
            ? StreakCopy.habitStreak(streak)
            : StreakCopy.viceClean(streak)
        return StreakBadgeModel(count: streak, label: label)
    }

    @ViewBuilder
    private var streakBadge: some View {
        if let badge = streakBadgeModel {
            VStack(spacing: 2) {
                Text("\(badge.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundColor(Color.currentWarning)
                Text(metric.habitType == .positive ? "streak" : "clean")
                    .font(.caption2)
                    .foregroundColor(Color.currentSecondaryText)
                    .textCase(.uppercase)

                if let recovery = recoveryBadgeLabel {
                    Text(recovery)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(Color.currentSuccess)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(minWidth: 52)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(streakBadgeAccessibilityLabel(badge: badge))
        }
    }

    private var recoveryBadgeLabel: String? {
        guard metric.habitType == .vice,
              MetricDisplayPreferences.showTimeSinceSlip(for: metric.id) else { return nil }
        return ViceSlipTimer.compactRecoveryLabel(
            metricID: metric.id,
            entries: entries,
            asOf: selectedDate
        )
    }

    private func streakBadgeAccessibilityLabel(badge: StreakBadgeModel) -> String {
        if let recovery = recoveryBadgeLabel {
            return "\(badge.label). \(recovery)"
        }
        return badge.label
    }

    private var toggleButton: some View {
        Button(action: {
            logger.debug("Toggle button tapped for metric: \(metric.name)", category: .ui)
            onToggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                refreshTrigger = UUID()
            }
        }) {
            toggleIcon
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier(AccessibilityIdentifiers.metricToggle(metric.id))
        .accessibilityLabel("\(metric.name), \(statusInfo.text)")
        .accessibilityHint(metric.habitType == .positive ? "Toggle completion" : "Toggle avoided status")
        .id(refreshTrigger)
    }

    @ViewBuilder
    private var toggleIcon: some View {
        let isCompleted = isMetricCompleted()
        let isLogged = TrackingSemantics.isLoggedForDay(entry: selectedDateEntry)

        if metric.habitType == .vice {
            if isCompleted {
                Image(systemName: "checkmark.shield.fill")
                    .font(.title3)
                    .foregroundColor(Color.currentSuccess)
            } else if isLogged {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(Color.currentError)
            } else {
                Image(systemName: "circle")
                    .font(.title3)
                    .foregroundColor(Color.currentSecondaryText)
            }
        } else {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isCompleted ? Color.currentSuccess : Color.currentSecondaryText)
        }
    }

    private var metricDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(metric.name)
                    .font(.headline)
                    .foregroundColor(Color.currentText)

                Spacer()

                Text(statusInfo.text)
                    .font(.caption)
                    .foregroundColor(statusInfo.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(statusInfo.color.opacity(0.15))
                    )
            }

            metadataRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture { onLog() }
        .accessibilityIdentifier(AccessibilityIdentifiers.metricRow(metric.id))
    }

    private var metadataRow: some View {
        HStack(spacing: 10) {
            if let goal = metric.booleanGoals.first {
                let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .foregroundColor(Color.currentPrimary)
                        .font(.caption)
                    Text("\(Int(progress.current))/\(Int(progress.target))")
                        .font(.caption)
                        .foregroundColor(Color.currentSecondaryText)
                }
            }

            if metric.habitType == .vice,
               let savings = viceSavingsLabel {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(Color.currentSuccess)
                        .font(.caption)
                    Text(savings)
                        .font(.caption)
                        .foregroundColor(Color.currentSuccess)
                }
            }

            Spacer()

            if let quantityString = selectedDateEntry?.quantityString {
                Text(quantityString)
                    .font(.caption2)
                    .foregroundColor(Color.currentSecondaryText)
            }
        }
    }

    private var viceSavingsLabel: String? {
        let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: selectedDate)
        let cost = MetricCostStore.costPerUnit(for: metric.id)
        return ViceSavingsCalculator.savingsLabel(streak: streak, costPerUnit: cost)
    }

    private var optionsRow: some View {
        HStack(spacing: 12) {
            Button(action: onLog) { Label("Log", systemImage: "square.and.pencil") }
                .buttonStyle(.bordered)
            Button(action: onEdit) { Label("Edit Habit", systemImage: "pencil") }
                .buttonStyle(.bordered)
            Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
                .buttonStyle(.bordered)
            Spacer()
        }
    }
}

#Preview {
    CompactMetricRow(
        metric: Metric(name: "Exercise", habitType: .positive),
        selectedDate: Date(),
        showOptions: false,
        onToggle: {},
        onLog: {},
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
