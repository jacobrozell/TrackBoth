import SwiftUI

/// Vector brand mark for launch, splash, and onboarding hero moments.
struct BrandMarkView: View {
    var size: CGFloat = 96

    private var cornerRadius: CGFloat { size * 0.22 }
    private var symbolSize: CGFloat { size * 0.42 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.currentPrimary, Color.currentAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color.currentPrimary.opacity(0.28), radius: size * 0.12, y: size * 0.06)

            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: symbolSize, weight: .semibold))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Brand Mark") {
    BrandMarkView()
        .padding()
}
