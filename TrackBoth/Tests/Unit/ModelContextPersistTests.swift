import XCTest
import SwiftData
@testable import TrackBoth

final class ModelContextPersistTests: XCTestCase {

    func testSaveChangesReturnsTrueOnSuccess() throws {
        let container = try ModelContainer(
            for: Metric.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        context.insert(Metric(name: "Test", habitType: .positive))

        XCTAssertTrue(context.saveChanges(operation: "unit test insert", entity: "Metric"))
    }
}
