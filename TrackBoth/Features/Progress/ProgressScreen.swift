import SwiftUI

struct ProgressScreen: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Progress", systemImage: "chart.line.uptrend.xyaxis", description: Text("Your history will show up here."))
                .navigationTitle("Progress")
        }
    }
}
