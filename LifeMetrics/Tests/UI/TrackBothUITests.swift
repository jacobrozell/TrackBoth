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

    private func launch(skipOnboarding: Bool = true, seedDemo: Bool = false) {
        var args: [String] = []
        if skipOnboarding { args.append("-skip_onboarding") }
        if seedDemo { args.append("-force_seed_demo") }
        app.launchArguments = args
        app.launchEnvironment = [
            "UI_TEST_RESET": "1",
            "RESET_ONBOARDING": skipOnboarding ? "0" : "1"
        ]
        app.launch()
    }

    private func launchWithDemoData() {
        launch(seedDemo: true)
    }

    func testLaunchShowsMainTabs() throws {
        launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Goals"].exists)
        XCTAssertTrue(app.tabBars.buttons["Motivation"].exists)
        XCTAssertTrue(app.tabBars.buttons["History"].exists)
        XCTAssertTrue(app.tabBars.buttons["Charts"].exists)
    }

    func testAllPrimaryTabsAreReachable() throws {
        launch()
        let tabs = ["Goals", "Motivation", "History", "Charts", "Home"]
        for tab in tabs {
            let button = app.tabBars.buttons[tab]
            XCTAssertTrue(button.waitForExistence(timeout: 10), "Missing tab: \(tab)")
            button.tap()
            XCTAssertTrue(button.isSelected || app.navigationBars[tab].waitForExistence(timeout: 5) || tab == "Home")
        }
    }

    func testHistoryTabNavigation() throws {
        launch()
        XCTAssertTrue(app.tabBars.buttons["History"].waitForExistence(timeout: 10))
        app.tabBars.buttons["History"].tap()
        let onHistory = app.navigationBars["History"].waitForExistence(timeout: 10)
            || app.staticTexts["No Habits Yet"].waitForExistence(timeout: 5)
        XCTAssertTrue(onHistory)
    }

    func testChartsTabShowsTitleOrEmptyState() throws {
        launch()
        app.tabBars.buttons["Charts"].tap()
        let onCharts = app.navigationBars["Charts"].waitForExistence(timeout: 10)
            || app.staticTexts["Your Journey Starts Here"].waitForExistence(timeout: 5)
        XCTAssertTrue(onCharts)
    }

    func testSettingsButtonExistsOnHome() throws {
        launch()
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 10))
        let hasSettings = app.buttons["settings_button"].waitForExistence(timeout: 10)
            || app.buttons["Settings"].waitForExistence(timeout: 5)
        XCTAssertTrue(hasSettings)
    }

    func testHomeShowsTrackBothTitle() throws {
        launch()
        XCTAssertTrue(app.navigationBars["TrackBoth"].waitForExistence(timeout: 10)
            || app.staticTexts["TrackBoth"].waitForExistence(timeout: 5))
    }

    func testCompactLandscapeShowsToolbarAddOnHome() throws {
        launchWithDemoData()
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 10))

        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock {
            XCUIDevice.shared.orientation = .portrait
        }

        let addButton = app.buttons["fab_add_metric"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 10))
        XCTAssertTrue(addButton.isHittable)
    }

    func testCompactLandscapeGoalsTabReachable() throws {
        launchWithDemoData()
        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock {
            XCUIDevice.shared.orientation = .portrait
        }

        let goalsTab = app.tabBars.buttons["Goals"]
        XCTAssertTrue(goalsTab.waitForExistence(timeout: 10))
        goalsTab.tap()

        XCTAssertTrue(
            app.navigationBars["Goals"].waitForExistence(timeout: 10)
                || app.buttons["fab_add_metric"].waitForExistence(timeout: 5)
        )
    }

    func testCompactLandscapeChartsTabReachable() throws {
        launchWithDemoData()
        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock {
            XCUIDevice.shared.orientation = .portrait
        }

        let chartsTab = app.tabBars.buttons["Charts"]
        XCTAssertTrue(chartsTab.waitForExistence(timeout: 10))
        chartsTab.tap()

        XCTAssertTrue(
            app.navigationBars["Charts"].waitForExistence(timeout: 10)
                || app.staticTexts["Your Journey Starts Here"].waitForExistence(timeout: 5)
        )
    }
}
