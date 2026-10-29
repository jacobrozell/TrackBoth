import XCTest

final class TrackBothUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchShowsThreeTabs() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui_testing", "-skip_onboarding", "-seed_demo"]
        app.launch()

        XCTAssertTrue(tab(named: "Today", identifier: "tab.today", in: app).waitForExistence(timeout: 8))
        XCTAssertTrue(tab(named: "Progress", identifier: "tab.progress", in: app).exists)
        XCTAssertTrue(tab(named: "Settings", identifier: "tab.settings", in: app).exists)
    }

    private func tab(named label: String, identifier: String, in app: XCUIApplication) -> XCUIElement {
        let identified = app.buttons[identifier]
        if identified.exists { return identified }
        let tabButton = app.tabBars.buttons[label]
        if tabButton.exists { return tabButton }
        return app.buttons[label]
    }
}
