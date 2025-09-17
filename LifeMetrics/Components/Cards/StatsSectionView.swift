import SwiftUI

// MARK: - StatsSectionView Component
struct StatsSectionView: View {
    let totalHabits: Int
    let totalVices: Int
    let activeStreaks: Int
    let todayCompleted: Int
    let totalMetrics: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // Quick Stats
            HStack(spacing: 20) {
                StatCard(
                    title: "Habits",
                    value: "\(totalHabits)",
                    icon: "checkmark.circle.fill",
                    color: .currentSuccess
                )
                
                StatCard(
                    title: "Vices",
                    value: "\(totalVices)",
                    icon: "xmark.circle.fill",
                    color: .currentError
                )
                
                StatCard(
                    title: "Streaks",
                    value: "\(activeStreaks)",
                    icon: "flame.fill",
                    color: .currentWarning
                )
                
                StatCard(
                    title: "Today",
                    value: "\(todayCompleted)/\(totalMetrics)",
                    icon: "calendar",
                    color: .currentPrimary
                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
        .background(Color.currentBackground)
        .onAppear {
            logger.debug("StatsSectionView displayed - Habits: \(totalHabits), Vices: \(totalVices), Streaks: \(activeStreaks), Today: \(todayCompleted)/\(totalMetrics)", category: .ui)
        }
    }
}

#Preview {
    StatsSectionView(
        totalHabits: 5,
        totalVices: 2,
        activeStreaks: 3,
        todayCompleted: 4,
        totalMetrics: 7
    )
}
