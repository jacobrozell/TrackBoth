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

    func testCheckInMarksVicesFree() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui_testing", "-skip_onboarding", "-seed_demo"]
        app.launch()

        let banner = app.buttons["today.checkInBanner"]
        XCTAssertTrue(banner.waitForExistence(timeout: 8))
        banner.tap()

        let freeButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'checkIn.free.'"))
        XCTAssertTrue(freeButtons.firstMatch.waitForExistence(timeout: 4))
        let identifiers = freeButtons.allElementsBoundByIndex.map(\.identifier)
        XCTAssertEqual(identifiers.count, 2)
        for identifier in identifiers {
            app.buttons[identifier].tap()
        }

        let done = app.buttons["checkIn.done"]
        XCTAssertTrue(done.waitForExistence(timeout: 4))
        done.tap()
        done.tap()
        XCTAssertTrue(banner.waitForNonExistence(timeout: 6))
    }

    func testUrgeFlowResisted() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui_testing", "-skip_onboarding", "-seed_demo"]
        app.launch()

        let sos = app.buttons["today.sosButton"]
        XCTAssertTrue(sos.waitForExistence(timeout: 8))
        sos.tap()
        let alcohol = app.buttons["Alcohol"]
        XCTAssertTrue(alcohol.waitForExistence(timeout: 4))
        alcohol.tap()
        app.buttons["urge.intensity.3"].tap()
        app.buttons["urge.passed"].tap()
        app.buttons["urge.done"].tap()
        app.tabBars.buttons["Progress"].tap()
        XCTAssertTrue(app.staticTexts["Urges beaten 5"].waitForExistence(timeout: 4))
    }

    func testSlipFlowShowsCompassionateSummary() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui_testing", "-skip_onboarding", "-seed_demo"]
        app.launch()

        let banner = app.buttons["today.checkInBanner"]
        XCTAssertTrue(banner.waitForExistence(timeout: 8))
        banner.tap()
        let slipped = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'checkIn.slipped.'"))
        XCTAssertTrue(slipped.firstMatch.waitForExistence(timeout: 4))
        slipped.firstMatch.tap()
        app.buttons["slip.save"].tap()
        let summary = app.otherElements["slip.summary"]
        XCTAssertTrue(summary.waitForExistence(timeout: 4))
        XCTAssertTrue(summary.staticTexts.matching(NSPredicate(format: "label CONTAINS 'restarts'")).firstMatch.exists
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'restarts'")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'of your last'")).firstMatch.exists)
    }

    private func tab(named label: String, identifier: String, in app: XCUIApplication) -> XCUIElement {
        let identified = app.buttons[identifier]
        if identified.exists { return identified }
        let tabButton = app.tabBars.buttons[label]
        if tabButton.exists { return tabButton }
        return app.buttons[label]
    }
}
