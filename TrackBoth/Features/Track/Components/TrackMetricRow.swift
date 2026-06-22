import SwiftUI
import SwiftData
import UIKit

// MARK: - TrackMetricRow
/// Metric row for Track — toggle, name, status, hero streak, and extended metadata.
struct TrackMetricRow: View {
    let metric: Metric
    let selectedDate: Date
    let showOptions: Bool
    let onToggle: () -> Void
    let onLog: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @Query private var entries: [MetricEntry]
    @State private var refreshTrigger = UUID()
    @State private var toggleEffectTrigger = 0
    @State private var showsToggleHighlight = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        metric: Metric,
        selectedDate: Date,
        showOptions: Bool,
        onToggle: @escaping () -> Void,
        onLog: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.metric = metric
        self.selectedDate = selectedDate
        self.showOptions = showOptions
        self.onToggle = onToggle
        self.onLog = onLog
        self.onEdit = onEdit
        self.onDelete = onDelete
        _entries = QueryDescriptors.entriesForStreakLookback()
    }

    private var selectedDateEntry: MetricEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        return MetricEntry.find(for: metric.id, date: startOfDay, in: entries)
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

    private var streakCount: Int {
        StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: selectedDate)
    }

    private var showsHeroStreak: Bool {
        metric.hasBeenLogged && streakCount > 0
    }

    private var heroStreakLabel: String {
        metric.habitType == .positive ? "streak" : "clean"
    }

    private var streakCaption: String? {
        guard showsHeroStreak else { return nil }
        return metric.habitType == .positive
            ? StreakCopy.habitStreak(streakCount)
            : StreakCopy.viceClean(streakCount)
    }

    private var rowLogAccessibilityLabel: String {
        if let streakCaption {
            return "\(metric.name), \(statusInfo.text), \(streakCaption)"
        }
        return "\(metric.name), \(statusInfo.text)"
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
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.currentSecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(toggleHighlightColor.opacity(showsToggleHighlight ? 0.55 : 0), lineWidth: 2)
        }
        .trackBothAnimation(TrackBothMotion.highlightFade, value: showsToggleHighlight, reduceMotion: reduceMotion)
        .accessibilityElement(children: .contain)
        .contextMenu {
            Button(action: onLog) { Label("Log", systemImage: "square.and.pencil") }
            Button(action: onEdit) { Label("Edit", systemImage: "pencil") }
            Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
        }
    }

    private var compactRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 14) {
                toggleButton

                Button(action: onLog) {
                    HStack(alignment: .center, spacing: 14) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(metric.name)
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color.currentText)

                            Text(statusInfo.text)
                                .font(.subheadline)
                                .foregroundStyle(statusInfo.color)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if showsHeroStreak {
                            VStack(spacing: 0) {
                                Text("\(streakCount)")
                                    .font(.title2.weight(.bold).monospacedDigit())
                                    .foregroundStyle(Color.currentText)
                                    .contentTransition(reduceMotion ? .identity : .numericText())
                                    .trackBothAnimation(TrackBothMotion.spring, value: streakCount, reduceMotion: reduceMotion)
                                Text(heroStreakLabel)
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(Color.currentSecondaryText)
                            }
                            .accessibilityHidden(true)
                        }

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.currentSecondaryText.opacity(0.6))
                            .accessibilityHidden(true)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(AccessibilityIdentifiers.metricRow(metric.id))
                .accessibilityLabel(rowLogAccessibilityLabel)
                .accessibilityHint("Opens logging details for this day")
            }

            if ProductSurface.showsExtendedRowMetadata {
                extendedMetadataRow
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
                .font(.subheadline)
                .foregroundColor(statusInfo.color)

            if showsHeroStreak, let streakCaption {
                Text(streakCaption)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color.currentText)
            } else if let streakCaption {
                Text(streakCaption)
                    .font(.caption)
                    .foregroundColor(Color.currentSecondaryText)
            }

            if ProductSurface.showsExtendedRowMetadata {
                extendedMetadataRow
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onLog() }
    }

    @ViewBuilder
    private var extendedMetadataRow: some View {
        HStack(spacing: 10) {
            if let goal = metric.booleanGoals.first {
                let progress = GoalUtils.calculateGoalProgress(
                    for: goal,
                    metric: metric,
                    entries: entries,
                    selectedDate: selectedDate
                )
                Label("\(Int(progress.current))/\(Int(progress.target))", systemImage: "target")
                    .font(.caption)
                    .foregroundColor(Color.currentSecondaryText)
            }

            if metric.habitType == .vice,
               let savings = viceSavingsLabel {
                Label(savings, systemImage: "dollarsign.circle.fill")
                    .font(.caption)
                    .foregroundColor(Color.currentSuccess)
            }

            if metric.habitType == .vice,
               MetricDisplayPreferences.showTimeSinceSlip(for: metric.id),
               let recovery = ViceSlipTimer.compactRecoveryLabel(
                   metricID: metric.id,
                   entries: entries,
                   asOf: selectedDate
               ) {
                Label(recovery, systemImage: "arrow.up.heart.fill")
                    .font(.caption)
                    .foregroundColor(Color.currentSuccess)
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
        return ViceSavingsCalculator.savingsLabel(streak: streak, costPerUnit: metric.costPerUnitDecimal)
    }

    private var toggleHighlightColor: Color {
        if isMetricCompleted() {
            return Color.currentSuccess
        }
        if metric.habitType == .vice && TrackingSemantics.isLoggedForDay(entry: selectedDateEntry) {
            return Color.currentError
        }
        return Color.currentPrimary
    }

    private var toggleButton: some View {
        Button(action: performToggle) {
            toggleIcon
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(AccessibilityIdentifiers.metricToggle(metric.id))
        .accessibilityLabel("\(metric.name), \(statusInfo.text)")
        .accessibilityHint(metric.habitType == .positive ? "Toggle completion" : "Toggle avoided status")
        .id(refreshTrigger)
    }

    private func performToggle() {
        let wasCompleted = isMetricCompleted()
        onToggle()
        toggleEffectTrigger += 1
        provideToggleHaptic(wasCompleted: wasCompleted)
        flashToggleHighlight()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            refreshTrigger = UUID()
        }
    }

    private func provideToggleHaptic(wasCompleted: Bool) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = wasCompleted ? .soft : .light
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    private func flashToggleHighlight() {
        guard !reduceMotion else { return }
        withAnimation(TrackBothMotion.quick) {
            showsToggleHighlight = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(TrackBothMotion.highlightFade) {
                showsToggleHighlight = false
            }
        }
    }

    @ViewBuilder
    private var toggleIcon: some View {
        let isCompleted = isMetricCompleted()
        let isLogged = TrackingSemantics.isLoggedForDay(entry: selectedDateEntry)

        Group {
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
        .modifier(ToggleIconMotionModifier(
            reduceMotion: reduceMotion,
            effectTrigger: toggleEffectTrigger
        ))
    }

    private var optionsRow: some View {
        HStack(spacing: 12) {
            Button(action: onLog) { Label("Log", systemImage: "square.and.pencil") }
                .buttonStyle(.bordered)
            Button(action: onEdit) { Label("Edit", systemImage: "pencil") }
                .buttonStyle(.bordered)
            Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
                .buttonStyle(.bordered)
            Spacer()
        }
    }
}
