import SwiftUI

// MARK: - AdaptiveSectionHeader
/// Section header that reflows for accessibility text sizes.
struct AdaptiveSectionHeader: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.usesAccessibilityLayout {
                accessibilityLayout
            } else {
                compactLayout
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityHeading(.h2)
    }

    private var compactLayout: some View {
        HStack(spacing: 12) {
            sectionIcon

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.currentText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color.currentSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(background)
    }

    private var accessibilityLayout: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                sectionIcon
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.currentText)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(Color.currentSecondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(background)
    }

    private var sectionIcon: some View {
        ZStack {
            Circle()
                .fill(iconColor.opacity(0.15))
                .frame(width: 32, height: 32)

            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.body)
        }
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.currentSecondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(iconColor.opacity(0.2), lineWidth: 1)
            )
    }
}
