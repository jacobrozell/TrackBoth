import SwiftUI

// MARK: - TrackDateActions
struct TrackDateActions: View {
    let weekHeaderTitle: String
    let showingRowOptions: Bool
    let isToday: Bool
    let usesAccessibilityLayout: Bool

    private var usesRelaxedLayout: Bool { usesAccessibilityLayout }

    let onToggleEdit: () -> Void
    let onGoToToday: () -> Void

    var body: some View {
        Group {
            if usesRelaxedLayout {
                VStack(alignment: .leading, spacing: 6) {
                    Text(weekHeaderTitle)
                        .bodySmall()
                        .foregroundColor(Color.currentSecondaryText)
                    actionButtons
                }
            } else {
                HStack {
                    actionButtons
                    Spacer()
                    Text(weekHeaderTitle)
                        .caption()
                        .foregroundColor(Color.currentSecondaryText)
                    if !isToday {
                        todayButton
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack {
            Button(showingRowOptions ? "Done" : "Edit") {
                onToggleEdit()
            }
            .caption()
            .foregroundColor(Color.currentPrimary)

            if usesRelaxedLayout {
                Spacer()
                if !isToday {
                    todayButton
                }
            }
        }
    }

    private var todayButton: some View {
        Button("Today") { onGoToToday() }
            .caption()
            .foregroundColor(Color.currentPrimary)
    }
}
