import SwiftUI

struct ReadableColumn<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.l)
    }
}

#Preview("Light") { ComponentPreview { ReadableColumn { Text("Readable column").foregroundStyle(Color.tbTextPrimary) } } }
#Preview("Dark") { ComponentPreview { ReadableColumn { Text("Readable column").foregroundStyle(Color.tbTextPrimary) } }.preferredColorScheme(.dark) }
#Preview("AX3") { ComponentPreview { ReadableColumn { Text("Readable column").foregroundStyle(Color.tbTextPrimary) } }.dynamicTypeSize(.accessibility3) }
#Preview("Landscape", traits: .landscapeLeft) { ComponentPreview { ReadableColumn { Text("A longer line stays inside the readable column.").foregroundStyle(Color.tbTextPrimary) } } }
