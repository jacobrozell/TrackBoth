import SwiftData
import XCTest
@testable import TrackBoth

@MainActor
final class TestHarness {
    let container: ModelContainer
    let store: RecoveryStore

    init(calendar: Calendar = .testNY) throws {
        let schema = Schema(versionedSchema: TrackBothSchemaV2.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        store = RecoveryStore(context: container.mainContext, calendar: calendar)
    }
}
