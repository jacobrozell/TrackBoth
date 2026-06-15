import SwiftUI

// MARK: - ChartHeaderRow
/// Chart title row that stacks at accessibility text sizes.
struct ChartHeaderRow<Trailing: View>: View {
    let title: String
    @ViewBuilder let trailing: () -> Trailing

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(title: String, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        Group {
            if dynamicTypeSize.usesAccessibilityLayout {
                VStack(alignment: .leading, spacing: 8) {
                    Text(displayTitle)
                        .font(.headline)
                        .foregroundColor(.currentText)
                        .fixedSize(horizontal: false, vertical: true)
                    trailing()
                }
            } else {
                HStack {
                    Text(displayTitle)
                        .font(.headline)
                        .foregroundColor(.currentText)
                    Spacer()
                    trailing()
                }
            }
        }
    }

    private var displayTitle: String {
        AccessibilityCopy.shortChartTitle(title, accessibility: dynamicTypeSize.usesAccessibilityLayout)
    }
}
