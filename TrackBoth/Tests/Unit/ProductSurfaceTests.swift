import XCTest
@testable import TrackBoth

final class ProductSurfaceTests: XCTestCase {

    func testLeanFeaturesDisabledInCurrentBuild() {
        #if DEBUG
        XCTAssertTrue(ProductSurface.showsWidget)
        #else
        XCTAssertFalse(ProductSurface.showsWidget)
        #endif
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
        #if DEBUG
        XCTAssertTrue(ProductSurface.isEnabled(.widget))
        #else
        XCTAssertFalse(ProductSurface.isEnabled(.widget))
        #endif
        XCTAssertFalse(ProductSurface.isEnabled(.watch))
        XCTAssertFalse(ProductSurface.isEnabled(.motivationGame))
    }
}
