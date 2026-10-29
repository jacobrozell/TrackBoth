import SwiftData
import SwiftUI

struct ProgressScreen: View {
    @Query private var urges: [UrgeEvent]

    var body: some View {
        let beaten = PatternInsights.urgeSummary(urges.map(\.outcome)).beaten
        NavigationStack {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text(RecoveryCopy.urgesBeatenCount(beaten))
                    .font(.title2)
                    .foregroundStyle(Color.tbTextPrimary)
                Text("Your history will show up here.")
                    .font(.body)
                    .foregroundStyle(Color.tbTextSecondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(Spacing.l)
            .background(Color.tbBackground)
            .navigationTitle("Progress")
        }
    }
}