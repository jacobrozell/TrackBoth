import SwiftUI

struct StatTile: View {
    var value: String
    var label: String
    var systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Image(systemName: systemImage)
                .font(.body)
                .foregroundStyle(Color.tbBrand)
                .accessibilityHidden(true)
            Text(value)
                .bigNumberStyle()
                .foregroundStyle(Color.tbTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(label)
                .font(.footnote)
                .foregroundStyle(Color.tbTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }
}

#Preview("Light") { ComponentPreview { StatTile(value: "12", label: "Days free", systemImage: "sun.max") } }
#Preview("Dark") { ComponentPreview { StatTile(value: "12", label: "Days free", systemImage: "sun.max") }.preferredColorScheme(.dark) }
#Preview("AX3") { ComponentPreview { StatTile(value: "12", label: "Days free", systemImage: "sun.max") }.dynamicTypeSize(.accessibility3) }
#Preview("Landscape", traits: .landscapeLeft) { ComponentPreview { StatTile(value: "12", label: "Days free", systemImage: "sun.max") } }
