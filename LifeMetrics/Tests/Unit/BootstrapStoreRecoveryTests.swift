import XCTest
import SwiftData
@testable import TrackBoth

final class BootstrapStoreRecoveryTests: XCTestCase {

    override func tearDown() {
        BootstrapStoreRecovery.resetModeForTesting()
        super.tearDown()
    }

    func testMakeContainerReturnsUsableStore() {
        let container = BootstrapStoreRecovery.makeContainer()
        let context = ModelContext(container)
        context.insert(Metric(name: "Test", habitType: .positive))
        XCTAssertNoThrow(try context.save())
    }

    func testInitialModeIsNormalOrFallback() {
        _ = BootstrapStoreRecovery.makeContainer()
        XCTAssertTrue(
            BootstrapStoreRecovery.mode == .normal || BootstrapStoreRecovery.mode == .inMemoryFallback
        )
    }
}
