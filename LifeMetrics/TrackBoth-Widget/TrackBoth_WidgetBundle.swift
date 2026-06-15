import WidgetKit
import SwiftUI

@main
struct TrackBoth_WidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayProgressWidget()
        QuickLogWidget()
        StreakSpotlightWidget()
        ViceRecoveryWidget()
        MoneySavedWidget()
        GoalProgressWidget()
        WeekGlanceWidget()
        DailyMotivationWidget()
        TrackBoth_WidgetControl()
    }
}
