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
    }

    func testCoreSurfacesEnabled() {
        XCTAssertTrue(ProductSurface.showsCharts)
        XCTAssertTrue(ProductSurface.isEnabled(.charts))
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
        #else
        XCTAssertFalse(ProductSurface.isEnabled(.widget))
        #endif
        XCTAssertFalse(ProductSurface.isEnabled(.watch))
        XCTAssertFalse(ProductSurface.isEnabled(.motivationGame))
    }
}
