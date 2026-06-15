import SwiftUI

struct CompactThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(theme.primaryColor)
                        .frame(width: 16, height: 16)

                    Circle()
                        .fill(theme.secondaryColor)
                        .frame(width: 16, height: 16)

                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 16, height: 16)
                }

                Text(theme.name)
                    .font(.caption)
                    .foregroundColor(theme.textColor)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(theme.primaryColor)
                }
            }
            .padding(8)
            .background(theme.backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? theme.primaryColor : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 80)
    }
}
