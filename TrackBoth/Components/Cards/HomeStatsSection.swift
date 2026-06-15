import SwiftUI

// MARK: - Home Stats Section
struct HomeStatsSection: View {
    let totalHabits: Int
    let totalVices: Int
    let activeStreaks: Int
    let todayCompleted: Int
    let totalMetrics: Int
    var layout: Layout = .horizontalScroll
    var fixedCardWidth: CGFloat? = nil

    enum Layout {
        case verticalColumn
        case horizontalScroll
        case accessibilityGrid
    }

    var body: some View {
        switch layout {
        case .verticalColumn:
            VStack(spacing: 8) {
                statCards(fixedWidth: nil)
            }
            .frame(maxWidth: .infinity)
        case .accessibilityGrid:
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 10) {
                statCards(fixedWidth: nil)
            }
            .frame(maxWidth: .infinity)
        case .horizontalScroll:
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    statCards(fixedWidth: fixedCardWidth)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func statCards(fixedWidth: CGFloat?) -> some View {
        if totalHabits > 0 {
            statCard(title: "Habits", value: "\(totalHabits)", icon: "checkmark.circle.fill", color: .currentSuccess, width: fixedWidth)
        }
        if totalVices > 0 {
            statCard(title: "Vices", value: "\(totalVices)", icon: "xmark.circle.fill", color: .currentError, width: fixedWidth)
        }
        if activeStreaks > 0 {
            statCard(title: "Streaks", value: "\(activeStreaks)", icon: "flame.fill", color: .currentWarning, width: fixedWidth)
        }
        statCard(title: "Today", value: "\(todayCompleted)/\(totalMetrics)", icon: "calendar", color: .currentPrimary, width: fixedWidth)
    }

    @ViewBuilder
    private func statCard(title: String, value: String, icon: String, color: Color, width: CGFloat?) -> some View {
        let card = StatCard(title: title, value: value, icon: icon, color: color, compact: true)
        if let width {
            card.frame(width: width)
        } else {
            card.frame(maxWidth: .infinity)
        }
    }
}
