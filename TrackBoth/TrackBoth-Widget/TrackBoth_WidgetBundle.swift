import WidgetKit
import SwiftUI

@main
struct TrackBoth_WidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayProgressWidget()
        TrackBothLogWidget()
        StreakSpotlightWidget()
        ViceRecoveryWidget()
        MoneySavedWidget()
        GoalProgressWidget()
        WeekGlanceWidget()
        DailyMotivationWidget()
        TrackBoth_WidgetControl()
    }
}
