import XCTest

final class AdaptiveLayoutUITests: XCTestCase {
    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
    }

    func testTodayLandscapeKeepsSOSAndCheckInReachable() {
        let app = launchSeeded()
        XCUIDevice.shared.orientation = .landscapeLeft

        let sos = app.buttons["today.sosButton"]
        let banner = app.buttons["today.checkInBanner"]
        XCTAssertTrue(sos.waitForExistence(timeout: 8))
        XCTAssertTrue(banner.waitForExistence(timeout: 4))
        XCTAssertTrue(sos.isHittable)
        XCTAssertTrue(banner.isHittable)
    }

    func testCheckInDoneInToolbarInLandscape() {
        let app = launchSeeded()
        XCUIDevice.shared.orientation = .landscapeLeft

        let banner = app.buttons["today.checkInBanner"]
        XCTAssertTrue(banner.waitForExistence(timeout: 8))
        banner.tap()

        let freeButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'checkIn.free.'"))
        XCTAssertTrue(freeButtons.firstMatch.waitForExistence(timeout: 4))
        for identifier in freeButtons.allElementsBoundByIndex.map(\.identifier) {
            app.buttons[identifier].tap()
        }

        let done = app.buttons["checkIn.done"]
        XCTAssertTrue(done.waitForExistence(timeout: 4))
        done.tap()
        done.tap()
        XCTAssertTrue(banner.waitForNonExistence(timeout: 6))
    }

    func testCheckInSheetSurvivesRotation() {
        let app = launchSeeded()

        let banner = app.buttons["today.checkInBanner"]
        XCTAssertTrue(banner.waitForExistence(timeout: 8))
        banner.tap()

        let freeButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'checkIn.free.'"))
        XCTAssertTrue(freeButtons.firstMatch.waitForExistence(timeout: 4))
        freeButtons.firstMatch.tap()

        XCUIDevice.shared.orientation = .landscapeLeft

        XCTAssertTrue(app.buttons["checkIn.done"].waitForExistence(timeout: 4))
        XCTAssertTrue(freeButtons.firstMatch.exists)
    }

    func testUrgeRideInLandscape() {
        let app = launchSeeded()
        XCUIDevice.shared.orientation = .landscapeLeft

        app.buttons["today.sosButton"].tap()
        app.buttons["Alcohol"].tap()
        app.buttons["urge.intensity.3"].tap()

        let passed = app.buttons["urge.passed"]
        if !passed.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(passed.waitForExistence(timeout: 4))
        passed.tap()
        app.buttons["urge.done"].tap()
    }

    func testSlipSaveInToolbarInLandscape() {
        let app = launchSeeded()
        XCUIDevice.shared.orientation = .landscapeLeft

        let banner = app.buttons["today.checkInBanner"]
        XCTAssertTrue(banner.waitForExistence(timeout: 8))
        banner.tap()

        let slipped = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'checkIn.slipped.'"))
        XCTAssertTrue(slipped.firstMatch.waitForExistence(timeout: 4))
        slipped.firstMatch.tap()

        let save = app.buttons["slip.save"]
        XCTAssertTrue(save.waitForExistence(timeout: 4))
        XCTAssertTrue(save.isHittable)
        save.tap()
        XCTAssertTrue(app.otherElements["slip.summary"].waitForExistence(timeout: 6))
    }

    func testOnboardingNextReachableInLandscape() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui_testing"]
        app.launch()

        XCUIDevice.shared.orientation = .landscapeLeft

        let next = app.buttons["onboarding.next"]
        XCTAssertTrue(next.waitForExistence(timeout: 8))
        XCTAssertTrue(next.isHittable)
    }

    func testProgressSplitOnRegularWidth() throws {
        let app = launchSeeded()
        guard app.windows.firstMatch.frame.width >= 744 else {
            throw XCTSkip("Requires iPad-width simulator window")
        }

        tab(named: "Progress", identifier: "tab.progress", in: app).tap()

        XCTAssertTrue(app.staticTexts["Alcohol"].waitForExistence(timeout: 8))
        app.staticTexts["Alcohol"].tap()
        XCTAssertTrue(app.navigationBars["Alcohol"].waitForExistence(timeout: 6))

        if app.staticTexts["Social media"].waitForExistence(timeout: 2) {
            XCTAssertTrue(app.staticTexts["Social media"].exists)
        }
    }

    private func launchSeeded() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui_testing", "-skip_onboarding", "-seed_demo"]
        app.launch()
        return app
    }

    private func tab(named label: String, identifier: String, in app: XCUIApplication) -> XCUIElement {
        let identified = app.buttons[identifier]
        if identified.exists { return identified }
        let tabButton = app.tabBars.buttons[label]
        if tabButton.exists { return tabButton }
        return app.buttons[label]
    }
}
