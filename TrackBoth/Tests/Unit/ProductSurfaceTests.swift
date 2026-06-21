import XCTest
@testable import TrackBoth

final class ProductSurfaceTests: XCTestCase {

    func testShipFeaturesEnabledInLeanRelease() {
        #if DEBUG
        XCTAssertTrue(ProductSurface.showsMotivation)
        XCTAssertTrue(ProductSurface.showsCharts)
        XCTAssertTrue(ProductSurface.showsMilestoneBanners)
        XCTAssertTrue(ProductSurface.showsExtendedRowMetadata)
        #else
        XCTAssertTrue(ProductSurface.showsMotivation)
        XCTAssertTrue(ProductSurface.showsCharts)
        XCTAssertTrue(ProductSurface.showsMilestoneBanners)
        XCTAssertTrue(ProductSurface.showsExtendedRowMetadata)
        XCTAssertFalse(ProductSurface.showsGoals)
        XCTAssertFalse(ProductSurface.showsQuantityCharts)
        XCTAssertFalse(ProductSurface.showsDemoData)
        XCTAssertFalse(ProductSurface.isEnabled(.widget))
        #endif
        XCTAssertFalse(ProductSurface.showsWatch)
        XCTAssertFalse(ProductSurface.showsMotivationGame)
    }

    func testDevelopmentOnlyFeaturesInFullDebugBuild() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-lean_ui") {
            XCTAssertFalse(ProductSurface.showsGoals)
            XCTAssertFalse(ProductSurface.showsQuantityCharts)
            XCTAssertFalse(ProductSurface.showsExtendedThemes)
        } else {
            XCTAssertTrue(ProductSurface.showsGoals)
            XCTAssertTrue(ProductSurface.showsQuantityCharts)
            XCTAssertTrue(ProductSurface.showsExtendedThemes)
            XCTAssertTrue(ProductSurface.showsWidget)
            XCTAssertTrue(ProductSurface.showsDemoData)
        }
        #endif
    }

    func testDebugBuildUsesDevelopmentSurface() {
        #if DEBUG
        XCTAssertEqual(ProductSurface.current, .development)
        #else
        XCTAssertEqual(ProductSurface.current, .lean1_0)
        #endif
    }

    func testChartTypesInLeanRelease() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-lean_ui") {
            XCTAssertEqual(ChartType.availableInCurrentSurface, [.line, .bar, .heatmap])
        } else {
            XCTAssertEqual(ChartType.availableInCurrentSurface, ChartType.allCases)
        }
        #else
        XCTAssertEqual(ChartType.availableInCurrentSurface, [.line, .bar, .heatmap])
        #endif
    }

    func testShipThemesSubset() {
        XCTAssertEqual(AppTheme.availableThemes.count, ProductSurface.showsExtendedThemes ? 4 : 2)
    }
}
