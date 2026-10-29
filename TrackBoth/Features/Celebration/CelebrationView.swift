import StoreKit
import SwiftUI

struct CelebrationView: View {
    var request: CelebrationRequest
    var onDone: () -> Void

    @Environment(\.requestReview) private var requestReview
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    var body: some View {
        ReadableColumn {
            VStack(spacing: Spacing.l) {
                Text("\(request.threshold)")
                    .bigNumberStyle()
                    .foregroundStyle(Color.tbTextPrimary)
                Text(request.isVice ? RecoveryCopy.milestoneVice(request.threshold, name: request.name) : RecoveryCopy.milestoneHabit(request.threshold, name: request.name))
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.tbTextPrimary)
                if let reason = request.reason {
                    Text("\(RecoveryCopy.rememberWhy) \(reason)")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.tbTextSecondary)
                }
                PrimaryButton(title: RecoveryCopy.keepGoing, systemImage: nil, accessibilityID: AccessibilityIdentifiers.celebrationContinue) {
                    MilestoneLedger.record(request.threshold, for: request.metricID)
                    if request.isVice, request.threshold == 7, !Preferences.hasRequestedReview {
                        Preferences.hasRequestedReview = true
                        requestReview()
                    }
                    onDone()
                }
            }
            .padding(.vertical, Spacing.xl)
            .trackBothCelebration(isPresented: shown, reduceMotion: reduceMotion)
            .onAppear { shown = true }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.tbBackground)
    }
}
