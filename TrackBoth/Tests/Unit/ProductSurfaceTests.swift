import XCTest
@testable import TrackBoth

final class ProductSurfaceTests: XCTestCase {

    func testShipFeaturesEnabledInRelease() {
        XCTAssertTrue(ProductSurface.showsInsights)
        XCTAssertTrue(ProductSurface.showsGoals)
        XCTAssertTrue(ProductSurface.showsMotivation)
        XCTAssertTrue(ProductSurface.showsQuantityCharts)
        XCTAssertTrue(ProductSurface.showsMilestoneBanners)
        XCTAssertTrue(ProductSurface.showsExtendedRowMetadata)
        XCTAssertTrue(ProductSurface.showsExtendedThemes)
        XCTAssertTrue(ProductSurface.showsAdvancedMetricSetup)
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-lean_ui") {
            XCTAssertFalse(ProductSurface.showsExtendedLogging)
        } else {
            XCTAssertTrue(ProductSurface.showsExtendedLogging)
        }
        #else
        XCTAssertFalse(ProductSurface.showsExtendedLogging)
        #endif

        #if !DEBUG
        XCTAssertFalse(ProductSurface.showsDemoData)
        XCTAssertFalse(ProductSurface.isEnabled(.widget))
        #endif

        XCTAssertFalse(ProductSurface.showsWatch)
        XCTAssertFalse(ProductSurface.showsMotivationGame)
    }

    func testDevelopmentOnlyFeaturesInFullDebugBuild() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-lean_ui") {
            XCTAssertFalse(ProductSurface.showsDemoData)
            XCTAssertFalse(ProductSurface.showsWidget)
        } else {
            XCTAssertTrue(ProductSurface.showsWidget)
            XCTAssertTrue(ProductSurface.showsDemoData)
        }
        #endif
    }

    func testDebugBuildUsesDevelopmentSurfaceKind() {
        #if DEBUG
        XCTAssertEqual(ProductSurface.current, .development)
        #else
        XCTAssertEqual(ProductSurface.current, .lean1_0)
        #endif
    }

    func testChartTypesInRelease() {
        XCTAssertEqual(ChartType.availableInCurrentSurface, ChartType.allCases)
    }

    func testAllThemesAvailableInRelease() {
        XCTAssertEqual(AppTheme.availableThemes.count, 4)
    }
}
