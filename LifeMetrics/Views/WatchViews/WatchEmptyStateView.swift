import SwiftUI

// MARK: - Watch Empty State View
/// Empty state component for Apple Watch when no metrics exist
struct WatchEmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        message: String,
        icon: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .foregroundColor(.secondary)
            
            // Title
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // Message
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            // Action Button (if provided)
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }
}

// MARK: - Watch Empty State Presets
extension WatchEmptyStateView {
    /// Empty state for when no habits exist
    static func noHabits(action: @escaping () -> Void) -> WatchEmptyStateView {
        WatchEmptyStateView(
            title: "No Habits Yet",
            message: "Add your first positive habit to start tracking your progress.",
            icon: "checkmark.circle",
            actionTitle: "Add Habit",
            action: action
        )
    }
    
    /// Empty state for when no vices exist
    static func noVices(action: @escaping () -> Void) -> WatchEmptyStateView {
        WatchEmptyStateView(
            title: "No Vices Yet",
            message: "Add habits you want to avoid to track your progress.",
            icon: "xmark.circle",
            actionTitle: "Add Vice",
            action: action
        )
    }
    
    /// Empty state for when no metrics exist at all
    static func noMetrics(action: @escaping () -> Void) -> WatchEmptyStateView {
        WatchEmptyStateView(
            title: "Welcome to TrackBoth",
            message: "Add your first habit or vice to start tracking your daily progress.",
            icon: "plus.circle",
            actionTitle: "Get Started",
            action: action
        )
    }
    
    /// Empty state for when no data exists for today
    static func noTodayData() -> WatchEmptyStateView {
        WatchEmptyStateView(
            title: "No Data Today",
            message: "Start logging your habits and vices to see your progress.",
            icon: "calendar",
            actionTitle: nil,
            action: nil
        )
    }
    
    /// Empty state for when no weekly data exists
    static func noWeeklyData() -> WatchEmptyStateView {
        WatchEmptyStateView(
            title: "No Weekly Data",
            message: "Log your habits and vices for a few days to see your weekly progress.",
            icon: "chart.bar",
            actionTitle: nil,
            action: nil
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        WatchEmptyStateView.noMetrics(action: {})
        
        WatchEmptyStateView.noHabits(action: {})
        
        WatchEmptyStateView.noVices(action: {})
    }
    .padding()
}
