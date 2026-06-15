import SwiftUI
import SwiftData

// MARK: - DemoDataToolbarButton
/// Consistent demo-data controls for toolbar placement across tabs.
struct DemoDataToolbarButton: View {
    @Environment(\.modelContext) private var modelContext
    let metricsEmpty: Bool

    private var hasDemoData: Bool {
        DemoDataGenerator.hasDemoData()
    }

    var body: some View {
        if ProductSurface.showsDemoData && (metricsEmpty || hasDemoData) {
            Button {
                if hasDemoData {
                    logger.logUserAction("Clear demo data")
                    DemoDataGenerator.clearDemoData(modelContext: modelContext)
                } else {
                    logger.logUserAction("Generate demo data")
                    DemoDataGenerator.generateDemoData(modelContext: modelContext)
                }
            } label: {
                Text(hasDemoData ? "Clear Demo" : "Try Demo")
                    .font(.caption)
            }
            .foregroundColor(hasDemoData ? Color.currentWarning : Color.currentPrimary)
        }
    }
}
