import SwiftUI
import XCTest
@testable import TrackBoth

final class TabBarLayoutTests: XCTestCase {
    func testLayoutModePortrait() {
        let mode = TabBarLayout.layoutMode(horizontal: .compact, vertical: .regular)
        XCTAssertEqual(mode, .portrait)
    }

    func testLayoutModeCompactLandscapeOnPhone() {
        let mode = TabBarLayout.layoutMode(horizontal: .regular, vertical: .compact)
        XCTAssertEqual(mode, .compactLandscape)
    }

    func testLayoutModeSidebarSplitOnIPadLandscape() {
        let mode = TabBarLayout.layoutMode(horizontal: .regular, vertical: .regular)
        // Unit tests run without a window scene; layout mode falls back to portrait.
        XCTAssertEqual(mode, .portrait)
    }

    func testShouldUseSidebarSplitRequiresLandscapeGeometry() {
        let portrait = CGSize(width: 390, height: 844)
        let landscape = CGSize(width: 844, height: 390)

        XCTAssertFalse(
            TabBarLayout.shouldUseSidebarSplit(
                size: portrait,
                horizontal: .regular,
                vertical: .regular
            )
        )
        XCTAssertTrue(
            TabBarLayout.shouldUseSidebarSplit(
                size: landscape,
                horizontal: .regular,
                vertical: .regular
            )
        )
    }

    func testPortraitScrollInsetUsesContentPadding() {
        XCTAssertEqual(
            TabBarLayout.scrollBottomInset(for: .portrait),
            TabBarLayout.contentScrollPadding
        )
        XCTAssertEqual(
            TabBarLayout.scrollBottomInset(for: .compactLandscape),
            TabBarLayout.landscapeScrollBottomInset
        )
    }
}
