import XCTest
@testable import TrackBoth

final class WCAGContrastTests: XCTestCase {

    func testAllCuratedThemesPassBodyTextContrast() {
        for theme in AppTheme.allThemes {
            let ratio = WCAGContrast.bodyTextRatio(for: theme)
            XCTAssertGreaterThanOrEqual(
                ratio,
                WCAGContrast.minimumBodyRatio,
                "Theme \(theme.name) text/background contrast \(ratio) below AA"
            )
        }
    }

    func testSecondaryTextContrastOnBackground() {
        for theme in AppTheme.allThemes {
            let ratio = WCAGContrast.secondaryTextRatio(for: theme)
            XCTAssertGreaterThanOrEqual(ratio, 3.0, "Theme \(theme.name) secondary text below large-text AA")
        }
    }
}
