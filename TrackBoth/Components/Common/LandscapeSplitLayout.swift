import SwiftUI

// MARK: - LandscapeSplitLayout
/// Reusable iPad-style sidebar + content split. Caller supplies sidebar and main panels.
struct LandscapeSplitLayout<Sidebar: View, Content: View, FAB: View>: View {
    let totalWidth: CGFloat
    let totalHeight: CGFloat
  @ViewBuilder let sidebar: () -> Sidebar
  @ViewBuilder let content: () -> Content
  @ViewBuilder let floatingAction: () -> FAB

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(spacing: 0) {
                sidebar()
                    .landscapeSidebarWidth(totalWidth)
                    .background(Color.currentSecondaryBackground)

                Divider()

                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.currentBackground)
            }
            .frame(width: totalWidth, height: totalHeight, alignment: .top)

            floatingAction()
        }
    }
}

extension LandscapeSplitLayout where FAB == EmptyView {
    init(
        totalWidth: CGFloat,
        totalHeight: CGFloat,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.totalWidth = totalWidth
        self.totalHeight = totalHeight
        self.sidebar = sidebar
        self.content = content
        self.floatingAction = { EmptyView() }
    }
}
