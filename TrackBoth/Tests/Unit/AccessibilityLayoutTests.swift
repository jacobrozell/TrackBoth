import SwiftUI
import XCTest
@testable import TrackBoth

final class AccessibilityLayoutTests: XCTestCase {

    func testRelaxedListLayoutIncludesXXXL() {
        XCTAssertTrue(DynamicTypeSize.xxxLarge.usesRelaxedListLayout)
        XCTAssertFalse(DynamicTypeSize.xxLarge.usesRelaxedListLayout)
    }

    func testRelaxedListLayoutIncludesAccessibilitySizes() {
        XCTAssertTrue(DynamicTypeSize.accessibility1.usesRelaxedListLayout)
    }

    func testExpandedChromeStartsAtXLarge() {
        XCTAssertTrue(DynamicTypeSize.xLarge.usesExpandedChrome)
        XCTAssertFalse(DynamicTypeSize.large.usesExpandedChrome)
    }
}
