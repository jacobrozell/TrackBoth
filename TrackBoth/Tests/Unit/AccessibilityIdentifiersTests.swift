import XCTest
@testable import TrackBoth

final class AccessibilityIdentifiersTests: XCTestCase {

    func testCoreIdentifiersAreNonEmpty() {
        XCTAssertFalse(AccessibilityIdentifiers.tabTrack.isEmpty)
        XCTAssertFalse(AccessibilityIdentifiers.tabSettings.isEmpty)
        XCTAssertFalse(AccessibilityIdentifiers.fabAddMetric.isEmpty)
        XCTAssertFalse(AccessibilityIdentifiers.settingsButton.isEmpty)
        XCTAssertFalse(AccessibilityIdentifiers.loggingSaveButton.isEmpty)
        XCTAssertFalse(AccessibilityIdentifiers.onboardingGetStarted.isEmpty)
    }

    func testMetricIdentifiersIncludeUUID() {
        let id = UUID()
        XCTAssertTrue(AccessibilityIdentifiers.metricRow(id).contains(id.uuidString))
        XCTAssertTrue(AccessibilityIdentifiers.metricToggle(id).contains(id.uuidString))
    }
}
