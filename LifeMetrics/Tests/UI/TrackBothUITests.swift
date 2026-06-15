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

    private var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
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

    /// iPhone uses a bottom tab bar; iPad uses a floating top tab strip with nested cells.
    private func tab(named name: String) -> XCUIElement {
        if let identifier = tabIdentifier(for: name) {
            let tabBarButton = app.tabBars.buttons[identifier]
            if tabBarButton.exists { return tabBarButton }
            let button = app.buttons[identifier]
            if button.exists { return button }
        }

        for label in tabLabels(for: name) {
            let tabBar = app.tabBars.buttons[label]
            if tabBar.exists { return tabBar }
            let tab = app.tabs[label]
            if tab.exists { return tab }
            let button = app.buttons.matching(NSPredicate(format: "label == %@", label)).firstMatch
            if button.exists { return button }
        }

        return app.buttons.matching(NSPredicate(format: "label == %@", name)).firstMatch
    }

    private func tabIdentifier(for name: String) -> String? {
        switch name {
        case "Home": return "tab_home"
        case "Goals": return "tab_goals"
        case "Motivation": return "tab_motivation"
        case "History": return "tab_history"
        case "Charts": return "tab_charts"
        default: return nil
        }
    }

    private func tabLabels(for name: String) -> [String] {
        switch name {
        case "Motivation": return ["Motiv", "Motivation"]
        case "History": return ["Past", "History"]
        case "Charts": return ["Stats", "Charts"]
        default: return [name]
        }
    }

    private func tapTab(named name: String) {
        let element = tab(named: name)
        XCTAssertTrue(element.waitForExistence(timeout: 10), "Missing tab: \(name)")
        element.tap()
    }

    private func assertTabExists(named name: String) {
        XCTAssertTrue(tab(named: name).waitForExistence(timeout: 10), "Missing tab: \(name)")
    }

    func testLaunchShowsMainTabs() throws {
        launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        for name in ["Home", "Goals", "Motivation", "History", "Charts"] {
            assertTabExists(named: name)
        }
    }

    private func assertOnTab(named name: String) {
        switch name {
        case "Home":
            XCTAssertTrue(
                app.navigationBars["TrackBoth"].waitForExistence(timeout: 10)
                    || app.staticTexts["HABITS"].waitForExistence(timeout: 5)
            )
        case "Goals":
            XCTAssertTrue(
                app.navigationBars["Goals"].waitForExistence(timeout: 10)
                    || app.staticTexts["No Goals Set"].waitForExistence(timeout: 5)
                    || app.staticTexts["No Habits Yet"].waitForExistence(timeout: 5)
                    || app.staticTexts["Morning Exercise"].waitForExistence(timeout: 5)
            )
        case "Motivation":
            XCTAssertTrue(
                app.navigationBars["Motivation"].waitForExistence(timeout: 10)
                    || app.staticTexts["No Habits Yet"].waitForExistence(timeout: 5)
                    || app.staticTexts["No Motivations Yet"].waitForExistence(timeout: 5)
                    || app.staticTexts["Primary Motivations"].waitForExistence(timeout: 5)
            )
        case "History":
            XCTAssertTrue(
                app.navigationBars["History"].waitForExistence(timeout: 10)
                    || app.staticTexts["No Habits Yet"].waitForExistence(timeout: 5)
            )
        case "Charts":
            XCTAssertTrue(
                app.navigationBars["Charts"].waitForExistence(timeout: 10)
                    || app.staticTexts["Your Journey Starts Here"].waitForExistence(timeout: 5)
            )
        default:
            XCTFail("Unknown tab: \(name)")
        }
    }

    func testAllPrimaryTabsAreReachable() throws {
        launch()
        for name in ["Goals", "Motivation", "History", "Charts", "Home"] {
            tapTab(named: name)
            assertOnTab(named: name)
        }
    }

    func testHistoryTabNavigation() throws {
        launch()
        tapTab(named: "History")
        let onHistory = app.navigationBars["History"].waitForExistence(timeout: 10)
            || app.staticTexts["No Habits Yet"].waitForExistence(timeout: 5)
        XCTAssertTrue(onHistory)
    }

    func testChartsTabShowsTitleOrEmptyState() throws {
        launch()
        tapTab(named: "Charts")
        let onCharts = app.navigationBars["Charts"].waitForExistence(timeout: 10)
            || app.staticTexts["Your Journey Starts Here"].waitForExistence(timeout: 5)
        XCTAssertTrue(onCharts)
    }

    func testSettingsButtonExistsOnHome() throws {
        launch()
        tapTab(named: "Home")
        let hasSettings = app.buttons["settings_button"].waitForExistence(timeout: 10)
            || app.buttons["Settings"].waitForExistence(timeout: 5)
        XCTAssertTrue(hasSettings)
    }

    func testSettingsButtonExistsOnGoals() throws {
        launch()
        tapTab(named: "Goals")
        XCTAssertTrue(app.buttons["settings_button"].waitForExistence(timeout: 10))
    }

    func testPortraitFABHasCorrectIdentifier() throws {
        try XCTSkipIf(isPad, "Portrait FAB is iPhone-only")

        launchWithDemoData()
        tapTab(named: "Home")
        let addButton = app.buttons["fab_add_metric"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 10))
        if !addButton.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(addButton.isHittable)
    }

    func testOnboardingFlowCompletesToMainTabs() throws {
        launch(skipOnboarding: false)
        XCTAssertTrue(app.staticTexts["Welcome to TrackBoth"].waitForExistence(timeout: 10))

        for _ in 0..<5 {
            let next = app.buttons["Next"]
            XCTAssertTrue(next.waitForExistence(timeout: 5))
            next.tap()
        }

        let getStarted = app.buttons["onboarding_get_started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 5))
        getStarted.tap()

        assertTabExists(named: "Home")
        assertOnTab(named: "Home")
    }

    func testGoalsTabShowsDemoGoals() throws {
        launchWithDemoData()
        tapTab(named: "Goals")
        XCTAssertFalse(app.staticTexts["No Goals Set"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Completion Goals"].waitForExistence(timeout: 10))
    }

    func testHomeShowsTrackBothTitle() throws {
        launch()
        XCTAssertTrue(app.navigationBars["TrackBoth"].waitForExistence(timeout: 10)
            || app.staticTexts["TrackBoth"].waitForExistence(timeout: 5))
    }

    func testCompactLandscapeShowsToolbarAddOnHome() throws {
        try XCTSkipIf(isPad, "Compact landscape is iPhone-only")

        launchWithDemoData()
        tapTab(named: "Home")

        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock {
            XCUIDevice.shared.orientation = .portrait
        }

        let addButton = app.buttons["fab_add_metric"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 10))
        XCTAssertTrue(addButton.isHittable)
    }

    func testCompactLandscapeGoalsTabReachable() throws {
        try XCTSkipIf(isPad, "Compact landscape is iPhone-only")

        launchWithDemoData()
        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock {
            XCUIDevice.shared.orientation = .portrait
        }

        tapTab(named: "Goals")

        XCTAssertTrue(
            app.navigationBars["Goals"].waitForExistence(timeout: 10)
                || app.buttons["fab_add_metric"].waitForExistence(timeout: 5)
        )
    }

    func testCompactLandscapeChartsTabReachable() throws {
        try XCTSkipIf(isPad, "Compact landscape is iPhone-only")

        launchWithDemoData()
        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock {
            XCUIDevice.shared.orientation = .portrait
        }

        tapTab(named: "Charts")

        XCTAssertTrue(
            app.navigationBars["Charts"].waitForExistence(timeout: 10)
                || app.staticTexts["Your Journey Starts Here"].waitForExistence(timeout: 5)
        )
    }

    func testIPadLandscapeHomeUsesSidebarLayout() throws {
        try XCTSkipIf(isPhone, "Requires iPad simulator")

        launchWithDemoData()
        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock {
            XCUIDevice.shared.orientation = .portrait
        }

        let habitsStat = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "HABITS")
        ).firstMatch
        XCTAssertTrue(habitsStat.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Habits"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["fab_add_metric"].waitForExistence(timeout: 5))
    }
}
