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
        let landscape = CGSize(width: 1024, height: 768)
        let mode = TabBarLayout.layoutMode(
            horizontal: .regular,
            vertical: .regular,
            size: landscape
        )
        XCTAssertEqual(mode, .sidebarSplit)
    }

    func testLayoutModePortraitOnIPadPortrait() {
        let portrait = CGSize(width: 768, height: 1024)
        let mode = TabBarLayout.layoutMode(
            horizontal: .regular,
            vertical: .regular,
            size: portrait
        )
        XCTAssertEqual(mode, .portrait)
    }

    func testLayoutModeCompactLandscapeUsesGeometryWhenTraitsLag() {
        let landscape = CGSize(width: 844, height: 390)
        let mode = TabBarLayout.layoutMode(
            horizontal: .compact,
            vertical: .regular,
            size: landscape
        )
        XCTAssertEqual(mode, .compactLandscape)
    }

    func testShouldUseSidebarSplitUsesInterfaceOrientationOnIPad() throws {
        // Simulates iPad landscape where tab chrome leaves portrait-shaped content geometry.
        try XCTSkipUnless(InterfaceLayout.isLandscape, "Requires landscape window scene")
        let portraitShapedContent = CGSize(width: 768, height: 1024)
        XCTAssertTrue(
            TabBarLayout.shouldUseSidebarSplit(
                size: portraitShapedContent,
                horizontal: .regular,
                vertical: .regular
            )
        )
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

    func testPortraitScrollInsetIncludesTabBarClearance() {
        XCTAssertEqual(
            TabBarLayout.scrollBottomInset(for: .portrait),
            TabBarLayout.scrollBottomInset
        )
        XCTAssertEqual(
            TabBarLayout.scrollBottomInset(for: .compactLandscape),
            TabBarLayout.landscapeScrollBottomInset
        )
    }
}
