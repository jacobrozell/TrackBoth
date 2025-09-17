import SwiftUI

// MARK: - Preset Button Components
struct PresetButton: View {
    let preset: GoalPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.currentText)
                
                Text(preset.description)
                    .font(.caption)
                    .foregroundColor(.currentSecondaryText)
                
                Text("\(preset.target) days")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.currentPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? Color.currentPrimary.opacity(0.1) : Color.currentSecondaryBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.currentPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuantityPresetButton: View {
    let preset: QuantityPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.currentText)
                
                Text(preset.description)
                    .font(.caption)
                    .foregroundColor(.currentSecondaryText)
                
                Text("\(preset.target) \(preset.unit)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.currentPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? Color.currentPrimary.opacity(0.1) : Color.currentSecondaryBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.currentPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
