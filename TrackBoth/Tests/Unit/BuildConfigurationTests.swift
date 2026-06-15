import XCTest

final class BuildConfigurationTests: XCTestCase {
    func testUnitTestBundleLoads() {
        let bundle = Bundle(for: BuildConfigurationTests.self)
        XCTAssertFalse(bundle.bundlePath.isEmpty)
        XCTAssertTrue(bundle.bundlePath.contains("TrackBothTests"))
    }
}
