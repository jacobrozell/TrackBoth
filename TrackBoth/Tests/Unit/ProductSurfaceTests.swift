import XCTest
@testable import TrackBoth

final class ProductSurfaceTests: XCTestCase {

    func testLeanFeaturesDisabledInCurrentBuild() {
        #if DEBUG
        XCTAssertTrue(ProductSurface.showsWidget)
        XCTAssertTrue(ProductSurface.showsGoals)
        XCTAssertTrue(ProductSurface.showsMotivation)
        XCTAssertTrue(ProductSurface.showsCharts)
        #else
        XCTAssertFalse(ProductSurface.showsWidget)
        XCTAssertFalse(ProductSurface.showsGoals)
        XCTAssertFalse(ProductSurface.showsMotivation)
        XCTAssertFalse(ProductSurface.showsCharts)
        #endif
        XCTAssertFalse(ProductSurface.showsWatch)
        XCTAssertFalse(ProductSurface.showsMotivationGame)
    }

    func testConfidenceOnePointZeroSurfaces() {
        #if DEBUG
        XCTAssertTrue(ProductSurface.showsMilestoneBanners)
        XCTAssertTrue(ProductSurface.showsExtendedRowMetadata)
        XCTAssertTrue(ProductSurface.showsExtendedThemes)
        #else
        XCTAssertFalse(ProductSurface.showsMilestoneBanners)
        XCTAssertFalse(ProductSurface.showsExtendedRowMetadata)
        XCTAssertFalse(ProductSurface.showsExtendedThemes)
        #endif
    }

    func testDebugBuildUsesDevelopmentSurface() {
        #if DEBUG
        XCTAssertEqual(ProductSurface.current, .development)
        XCTAssertTrue(ProductSurface.showsDemoData)
        XCTAssertTrue(ProductSurface.isEnabled(.demoData))
        #else
        XCTAssertEqual(ProductSurface.current, .lean1_0)
        XCTAssertFalse(ProductSurface.showsDemoData)
        #endif
    }

    func testPostOnePointZeroFeaturesDisabledViaIsEnabled() {
        #if DEBUG
        XCTAssertTrue(ProductSurface.isEnabled(.widget))
        XCTAssertTrue(ProductSurface.isEnabled(.charts))
        #else
        XCTAssertFalse(ProductSurface.isEnabled(.widget))
        XCTAssertFalse(ProductSurface.isEnabled(.charts))
        #endif
        XCTAssertFalse(ProductSurface.isEnabled(.watch))
        XCTAssertFalse(ProductSurface.isEnabled(.motivationGame))
    }

    func testShipThemesSubset() {
        XCTAssertEqual(AppTheme.availableThemes.count, ProductSurface.showsExtendedThemes ? 4 : 2)
    }
}
