import SwiftUI

struct DayDots: View {
    var states: [DayVisualState]
    var labels: [String] = []

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Spacing.s) {
                marks
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: Spacing.s)], spacing: Spacing.s) {
                marks
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var marks: some View {
        ForEach(Array(states.enumerated()), id: \.offset) { index, state in
            DayMark(state: state)
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityElement()
                .accessibilityLabel(spoken(index: index, state: state))
        }
    }

    private func spoken(index: Int, state: DayVisualState) -> String {
        if labels.indices.contains(index), !labels[index].isEmpty {
            return "\(labels[index]), \(state.accessibilityName)"
        }
        return state.accessibilityName
    }
}

private let previewWeek: [DayVisualState] = [
    .confirmedFree, .confirmedFree, .presumedFree, .slipped, .habitDone, .missed, .todayPending
]
private let previewWeekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

#Preview("Light") { ComponentPreview { DayDots(states: previewWeek, labels: previewWeekdays) } }
#Preview("Dark") { ComponentPreview { DayDots(states: previewWeek, labels: previewWeekdays) }.preferredColorScheme(.dark) }
#Preview("AX3") { ComponentPreview { DayDots(states: previewWeek, labels: previewWeekdays) }.dynamicTypeSize(.accessibility3) }
#Preview("Landscape", traits: .landscapeLeft) { ComponentPreview { DayDots(states: previewWeek, labels: previewWeekdays) } }
