import SwiftUI
import SwiftData

struct TodayScreen: View {
    @Query(filter: #Predicate<Metric> { !$0.isArchived }, sort: \Metric.sortOrder)
    private var metrics: [Metric]

    var body: some View {
        NavigationStack {
            List {
                if metrics.isEmpty {
                    Text("Start with one thing")
                        .foregroundStyle(Color.tbTextSecondary)
                } else {
                    ForEach(metrics) { metric in
                        Label(metric.name, systemImage: metric.iconName)
                            .accessibilityIdentifier(
                                metric.habitType == .vice
                                    ? AccessibilityIdentifiers.viceCard(metric.id)
                                    : AccessibilityIdentifiers.habitToggle(metric.id)
                            )
                    }
                }
            }
            .navigationTitle("Today")
            .scrollContentBackground(.hidden)
            .background(Color.tbBackground)
        }
    }
}
