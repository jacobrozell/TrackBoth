import Foundation
import SwiftData

// MARK: - Bootstrap Store Recovery
enum StoreRecoveryMode: Equatable {
    case normal
    case inMemoryFallback
}

struct BootstrapStoreRecovery {
    private(set) static var mode: StoreRecoveryMode = .normal

    static func makeContainer() -> ModelContainer {
        mode = .normal
        let schema = Schema(versionedSchema: TrackBothSchemaV1.self)

        do {
            let config = ModelConfiguration("TrackBoth", schema: schema)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            logger.error("SwiftData persistent store failed: \(error.localizedDescription)", category: .data)
            logger.warn("Falling back to in-memory store", category: .data)
            return makeInMemoryContainer(schema: schema)
        }
    }

    static func resetModeForTesting() {
        mode = .normal
    }

    private static func makeInMemoryContainer(schema: Schema) -> ModelContainer {
        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [config])
            mode = .inMemoryFallback
            return container
        } catch {
            logger.fatal("In-memory store failed: \(error.localizedDescription)", category: .data)
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
