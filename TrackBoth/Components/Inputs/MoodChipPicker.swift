import SwiftUI

// MARK: - MoodChipPicker
struct MoodChipPicker: View {
    @Binding var selectedMood: String?

    private let options = ["😊", "🙂", "😐", "😔", "😤"]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(options, id: \.self) { mood in
                let isSelected = selectedMood == mood
                Button {
                    selectedMood = isSelected ? nil : mood
                } label: {
                    Text(mood)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.currentPrimary.opacity(0.2) : Color.currentSecondaryBackground)
                        )
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.currentPrimary : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(moodAccessibilityLabel(mood))
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func moodAccessibilityLabel(_ mood: String) -> String {
        switch mood {
        case "😊": return "Great"
        case "🙂": return "Good"
        case "😐": return "Neutral"
        case "😔": return "Low"
        case "😤": return "Struggling"
        default: return "Mood"
        }
    }
}
