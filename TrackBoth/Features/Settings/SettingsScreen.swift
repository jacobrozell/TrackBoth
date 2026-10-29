import SwiftUI
import SwiftData

struct SettingsScreen: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                if ProductSurface.showsDebugTools {
                    Button("Seed demo data") {
                        try? DemoData.seedIfEmpty(context: modelContext)
                    }
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .background(Color.tbBackground)
        }
    }
}
