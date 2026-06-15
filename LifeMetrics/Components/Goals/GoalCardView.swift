import SwiftUI
import SwiftData

// MARK: - GoalCardView
struct GoalCardView: View {
    let metric: Metric
    let selectedDate: Date
    let entries: [MetricEntry]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var booleanGoals: [Goal] {
        metric.booleanGoals
    }

    private var quantityGoals: [Goal] {
        metric.quantityGoals
    }

    private var goalProgressResult: (current: Double, target: Double, percentage: Double) {
        if let goal = booleanGoals.first ?? quantityGoals.first {
            let result = GoalUtils.calculateGoalProgress(
                for: goal,
                metric: metric,
                entries: entries,
                selectedDate: selectedDate
            )
            return (result.current, result.target, result.percentage)
        }
        return (0, 0, 0)
    }

    private var progress: Double {
        goalProgressResult.percentage / 100.0
    }

    private var isCompleted: Bool {
        progress >= 1.0
    }

    private var progressText: String {
        let data = goalProgressResult
        if !booleanGoals.isEmpty || !quantityGoals.isEmpty {
            return "\(Int(data.current))/\(Int(data.target))"
        }
        return "0/0"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if dynamicTypeSize.usesAccessibilityLayout {
                accessibilityHeader
            } else {
                compactHeader
            }

            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.currentSecondaryText)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.currentSecondaryText)
                }

                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: isCompleted ? .currentSuccess : .currentPrimary))
                    .scaleEffect(x: 1, y: 1.5)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)

            if !booleanGoals.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(booleanGoals, id: \.id) { goal in
                        goalDetails("\(goal.target) times per \(goal.period.displayName)")
                    }
                }
            } else if !quantityGoals.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(quantityGoals, id: \.id) { goal in
                        goalDetails("\(goal.target) \(goal.safeDefaultUnit) per \(goal.period.displayName)")
                    }
                }
            }

            Rectangle()
                .fill(isCompleted ? Color.currentSuccess.opacity(0.3) : Color.currentPrimary.opacity(0.3))
                .frame(height: 3)
                .cornerRadius(1.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .metricCardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Goal for \(metric.name): \(progressText) progress")
    }

    private func goalDetails(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.caption)
                .foregroundColor(.currentSecondaryText)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }

    private var compactHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            goalTypeIcon

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(metric.name)
                        .font(.headline)
                        .foregroundColor(.currentText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)
                    goalKindIcon
                }

                Text(goalKindLabel)
                    .font(.caption)
                    .foregroundColor(.currentSecondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            progressSummary(alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var accessibilityHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            goalTypeIcon

            Text(metric.name)
                .font(.headline)
                .foregroundColor(.currentText)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                goalKindIcon
                Text(goalKindLabel)
                    .font(.caption)
                    .foregroundColor(.currentSecondaryText)
            }

            progressSummary(alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var goalTypeIcon: some View {
        Image(systemName: metric.habitType.icon)
            .foregroundColor(metric.habitType == .positive ? .currentSuccess : .currentError)
            .font(.body)
            .frame(width: 24, height: 24)
    }

    @ViewBuilder
    private var goalKindIcon: some View {
        if !booleanGoals.isEmpty {
            Image(systemName: "target")
                .foregroundColor(.currentPrimary)
                .font(.caption)
        } else if !quantityGoals.isEmpty {
            Image(systemName: "chart.bar.fill")
                .foregroundColor(.currentAccent)
                .font(.caption)
        }
    }

    private var goalKindLabel: String {
        booleanGoals.isEmpty ? "Quantity Goal" : "Completion Goal"
    }

    private func progressSummary(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(progressText)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isCompleted ? .currentSuccess : .currentText)

            Text(isCompleted ? "Completed" : "In Progress")
                .font(.caption)
                .foregroundColor(isCompleted ? .currentSuccess : .currentSecondaryText)
        }
    }
}
