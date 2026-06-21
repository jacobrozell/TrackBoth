import SwiftUI

struct CompactThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Circle().fill(theme.primaryColor).frame(width: 14, height: 14)
                    Circle().fill(theme.accentColor).frame(width: 14, height: 14)
                    Circle().fill(theme.successColor).frame(width: 14, height: 14)
                }

                Text(theme.name)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.textColor)
            }
            .frame(width: 88, height: 72)
            .background(theme.backgroundColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(theme.primaryColor)
                        .padding(6)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
