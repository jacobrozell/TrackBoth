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

    private var selectedDateEntry: MetricEntry? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        return entries.first { $0.metricID == metric.id && calendar.isDate($0.date, inSameDayAs: startOfDay) }
    }

    private func isMetricCompleted() -> Bool {
        // Only count as completed if metric has entries
        guard entries.contains(where: { $0.metricID == metric.id }) else { return false }

        let isVice = metric.habitType == .vice
        if isVice {
            // For vices, completed when explicitly logged as avoided (value == true)
            return selectedDateEntry?.value == true
        } else {
            // For habits, completed when explicitly logged as done (value == true)
            return selectedDateEntry?.value == true
        }
    }

    private var statusInfo: (text: String, color: Color) {
        let isCompleted = isMetricCompleted()

        if metric.habitType == .positive {
            return (
                text: isCompleted ? "Completed" : "Incomplete",
                color: isCompleted ? Color.currentSuccess : Color.currentSecondaryText
            )
        } else {
            return (
                text: isCompleted ? "Avoided" : "Not Avoided",
                color: isCompleted ? Color.currentSuccess : Color.currentError
            )
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Left side - tappable for logging
                HStack(spacing: 12) {
                    // Toggle for completion status
                    Button(action: {
                        logger.debug("Toggle button tapped for metric: \(metric.name)", category: .ui)
                        onToggle()
                        // Small delay to allow SwiftData to process the change
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            refreshTrigger = UUID()
                        }
                    }) {
                        let isCompleted = isMetricCompleted()
                        if metric.habitType == .vice && isCompleted {
                            // For vices, show X icon when avoided (completed)
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(Color.currentError)
                        } else {
                            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundColor(isCompleted ? Color.currentSuccess : Color.currentSecondaryText)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .id(refreshTrigger) // Force UI refresh when trigger changes

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(metric.name)
                                .h4()
                                .foregroundColor(Color.currentText)
                            
                            Spacer()
                            
                            // Status label moved to top right
                            Text(statusInfo.text)
                                .caption()
                                .foregroundColor(statusInfo.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(statusInfo.color.opacity(0.15))
                                )
                        }

                        HStack(spacing: 10) {
                            let streak = StreakUtils.calculateCurrentStreak(for: metric, entries: entries, selectedDate: selectedDate)
                            if streak > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill").foregroundColor(Color.currentWarning).font(.caption)
                                    Text(metric.habitType == .positive ? "\(streak) day streak" : "\(streak) days clean")
                                        .caption()
                                        .foregroundColor(Color.currentSecondaryText)
                                }
                            }

                            if let goal = metric.booleanGoals.first {
                                let progress = GoalUtils.calculateGoalProgress(for: goal, metric: metric, entries: entries, selectedDate: selectedDate)
                                HStack(spacing: 4) {
                                    Image(systemName: "target").foregroundColor(Color.currentPrimary).font(.caption)
                                    Text("\(Int(progress.current))/\(Int(progress.target))")
                                        .caption()
                                        .foregroundColor(Color.currentSecondaryText)
                                }
                            }
                            
                            Spacer()
                            
                            // Quantity label in bottom right
                            if let quantityString = selectedDateEntry?.quantityString {
                                Text(quantityString)
                                    .captionSmall()
                                    .foregroundColor(Color.currentSecondaryText)
                            }
                        }
                    }
                    .onTapGesture {
                        onLog()
                    }

                    Spacer()
                }
                .contentShape(Rectangle())
            }

            if showOptions {
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
        .padding(12)
        .background(Color.currentSecondaryBackground)
        .cornerRadius(12)
        .contextMenu {
            Button(action: onLog) { Label("Log", systemImage: "square.and.pencil") }
            Button(action: onEdit) { Label("Edit Habit", systemImage: "pencil") }
            Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
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
