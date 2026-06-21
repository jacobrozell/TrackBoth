import SwiftUI

// MARK: - Track Section Header
struct TrackSectionHeader: View {
    let title: String
    let completedCount: Int
    let totalCount: Int

    var body: some View {
        ScreenSectionHeader(
            title: title,
            trailing: totalCount > 0 ? "\(completedCount)/\(totalCount)" : nil
        )
    }
}
