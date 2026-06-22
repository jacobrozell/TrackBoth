import XCTest
@testable import TrackBoth

final class AppThemeTests: XCTestCase {
    private var savedTheme: Theme!
    private var savedAppThemeName: String!

    override func setUp() {
        super.setUp()
        let manager = ThemeManager.shared
        savedTheme = manager.currentTheme
        savedAppThemeName = manager.currentAppTheme.name
    }

    override func tearDown() {
        let manager = ThemeManager.shared
        manager.updateTheme(savedTheme)
        if let restored = AppTheme.allThemes.first(where: { $0.name == savedAppThemeName }) {
            manager.updateAppTheme(restored)
        }
        super.tearDown()
    }

    func testPreferredColorSchemeMatchesThemeBrightness() {
        XCTAssertEqual(AppTheme.ocean.preferredColorScheme, .light)
        XCTAssertEqual(AppTheme.forest.preferredColorScheme, .light)
        XCTAssertEqual(AppTheme.sunset.preferredColorScheme, .light)
        XCTAssertEqual(AppTheme.midnight.preferredColorScheme, .dark)
    }

    func testThemeManagerPreferredColorSchemeFollowsAppThemeWhenSystem() {
        let manager = ThemeManager.shared
        manager.updateTheme(.system)

        manager.updateAppTheme(.ocean)
        XCTAssertEqual(manager.preferredColorScheme, .light)

        manager.updateAppTheme(.midnight)
        XCTAssertEqual(manager.preferredColorScheme, .dark)
    }

    func testThemeManagerHonorsExplicitLightDarkOverride() {
        let manager = ThemeManager.shared

        manager.updateAppTheme(.midnight)
        manager.updateTheme(.light)
        XCTAssertEqual(manager.preferredColorScheme, .light)

        manager.updateAppTheme(.ocean)
        manager.updateTheme(.dark)
        XCTAssertEqual(manager.preferredColorScheme, .dark)
    }
}
