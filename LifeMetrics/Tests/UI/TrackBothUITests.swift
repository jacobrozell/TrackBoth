import XCTest

final class TrackBothUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    private func launch(skipOnboarding: Bool = true) {
        app.launchArguments = skipOnboarding ? ["-skip_onboarding"] : []
        app.launchEnvironment = [
            "UI_TEST_RESET": "1",
            "RESET_ONBOARDING": skipOnboarding ? "0" : "1"
        ]
        app.launch()
    }

    func testLaunchShowsMainTabs() throws {
        launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Goals"].exists)
        XCTAssertTrue(app.tabBars.buttons["History"].exists)
        XCTAssertTrue(app.tabBars.buttons["Charts"].exists)
    }

    func testHistoryTabNavigation() throws {
        launch()
        XCTAssertTrue(app.tabBars.buttons["History"].waitForExistence(timeout: 10))
        app.tabBars.buttons["History"].tap()
        let onHistory = app.navigationBars["History"].waitForExistence(timeout: 10)
            || app.staticTexts["No Habits Yet"].waitForExistence(timeout: 5)
        XCTAssertTrue(onHistory)
    }

    func testSettingsButtonExistsOnHome() throws {
        launch()
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 10))
        let hasSettings = app.buttons["settings_button"].waitForExistence(timeout: 10)
            || app.buttons["Settings"].waitForExistence(timeout: 5)
        XCTAssertTrue(hasSettings)
    }
}

// Onboarding and demo-data flows: see manual QA in docs/release/QA-Signoff-RC1.md
