import SwiftUI

// MARK: - TrackDateActions
struct TrackDateActions: View {
    let weekHeaderTitle: String
    let showingRowOptions: Bool
    let isToday: Bool
    let usesAccessibilityLayout: Bool
    let onToggleEdit: () -> Void
    let onGoToToday: () -> Void

    var body: some View {
        Group {
            if usesAccessibilityLayout {
                VStack(alignment: .leading, spacing: 6) {
                    Text(weekHeaderTitle)
                        .font(.subheadline)
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

            if usesAccessibilityLayout {
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
