import XCTest
@testable import TrackBoth

final class ProductSurfaceTests: XCTestCase {

    func testLeanFeaturesDisabledInCurrentBuild() {
        XCTAssertFalse(ProductSurface.showsWidget)
        XCTAssertFalse(ProductSurface.showsWatch)
        XCTAssertFalse(ProductSurface.showsMotivationGame)
        XCTAssertFalse(ProductSurface.showsAchievements)
        XCTAssertFalse(ProductSurface.showsNotifications)
        XCTAssertFalse(ProductSurface.showsShortcuts)
    }

    func testCoreSurfacesEnabled() {
        XCTAssertTrue(ProductSurface.showsCharts)
        XCTAssertTrue(ProductSurface.isEnabled(.charts))
    }

    func testDebugBuildUsesDevelopmentSurface() {
        #if DEBUG
        XCTAssertEqual(ProductSurface.current, .development)
        XCTAssertTrue(ProductSurface.showsDemoData)
        XCTAssertTrue(ProductSurface.showsDebugLogging)
        XCTAssertTrue(ProductSurface.isEnabled(.demoData))
        #else
        XCTAssertEqual(ProductSurface.current, .lean1_0)
        XCTAssertFalse(ProductSurface.showsDemoData)
        XCTAssertFalse(ProductSurface.showsDebugLogging)
        #endif
    }

    func testPostOnePointZeroFeaturesDisabledViaIsEnabled() {
        XCTAssertFalse(ProductSurface.isEnabled(.widget))
        XCTAssertFalse(ProductSurface.isEnabled(.watch))
        XCTAssertFalse(ProductSurface.isEnabled(.motivationGame))
    }
}
