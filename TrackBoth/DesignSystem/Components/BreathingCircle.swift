import SwiftUI

struct BreathingCircle: View {
    var inhale: Double = 4
    var exhale: Double = 6
    var maxDiameter: CGFloat = 280

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var expanded = false
    @State private var cue = "Breathe in"

    var body: some View {
        Group {
            if reduceMotion {
                Text("Breathe in for \(whole(inhale)) seconds. Breathe out for \(whole(exhale)).")
                    .font(.title2)
                    .foregroundStyle(Color.tbOnCalm)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ZStack {
                    Circle()
                        .fill(Color.tbCalm)
                        .scaleEffect(expanded ? 1 : 0.72)
                    Text(cue)
                        .font(.title2)
                        .foregroundStyle(Color.tbOnCalm)
                        .padding(Spacing.l)
                        .multilineTextAlignment(.center)
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: maxDiameter, maxHeight: maxDiameter)
                .trackBothAnimation(TrackBothMotion.celebrationSpring, value: expanded, reduceMotion: reduceMotion)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Breathing guide. Breathe in for \(whole(inhale)) seconds, then out for \(whole(exhale)).")
        .task(id: reduceMotion) {
            guard !reduceMotion else { return }
            while !Task.isCancelled {
                cue = "Breathe in"
                expanded = true
                try? await Task.sleep(for: .seconds(inhale))
                if Task.isCancelled { break }
                cue = "Breathe out"
                expanded = false
                try? await Task.sleep(for: .seconds(exhale))
            }
        }
    }

    private func whole(_ value: Double) -> Int {
        Int(value.rounded())
    }
}

#Preview("Light") { BreathingCircle().padding().background(Color.tbCalm) }
#Preview("Dark") { BreathingCircle().padding().background(Color.tbCalm).preferredColorScheme(.dark) }
#Preview("AX3") { BreathingCircle().padding().background(Color.tbCalm).dynamicTypeSize(.accessibility3) }
#Preview("Landscape", traits: .landscapeLeft) { BreathingCircle().padding().background(Color.tbCalm) }
