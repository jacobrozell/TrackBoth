import XCTest

final class TrackBothUITests: TrackBothUITestCase {
    func testLaunchShowsThreeTabs() {
        launchApp()
        XCTAssertTrue(tab(named: "Today", identifier: "tab.today").waitForExistence(timeout: 8))
        XCTAssertTrue(tab(named: "Progress", identifier: "tab.progress").exists)
        XCTAssertTrue(tab(named: "Settings", identifier: "tab.settings").exists)
    }

    func testCheckInMarksVicesFree() {
        launchApp()
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
        launchApp()
        let sos = app.buttons["today.sosButton"]
        XCTAssertTrue(sos.waitForExistence(timeout: 8))
        sos.tap()
        let alcohol = app.buttons["Alcohol"]
        XCTAssertTrue(alcohol.waitForExistence(timeout: 4))
        alcohol.tap()
        app.buttons["urge.intensity.3"].tap()
        app.buttons["urge.passed"].tap()
        app.buttons["urge.done"].tap()
        tab(named: "Progress", identifier: "tab.progress").tap()
        assertStaticTextExists("Urges beaten", timeout: 8)
    }

    func testSlipFlowShowsCompassionateSummary() {
        launchApp()
        let banner = app.buttons["today.checkInBanner"]
        XCTAssertTrue(banner.waitForExistence(timeout: 8))
        banner.tap()
        let slipped = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'checkIn.slipped.'"))
        XCTAssertTrue(slipped.firstMatch.waitForExistence(timeout: 4))
        slipped.firstMatch.tap()
        XCTAssertTrue(app.buttons["slip.save"].waitForExistence(timeout: 6))
        app.buttons["slip.save"].tap()
        let summary = app.otherElements["slip.summary"]
        XCTAssertTrue(summary.waitForExistence(timeout: 6))
        XCTAssertTrue(summary.staticTexts.matching(NSPredicate(format: "label CONTAINS 'restarts'")).firstMatch.exists
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'restarts'")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'of your last'")).firstMatch.exists)
    }

    func testEditPastDayToSlipUpdatesStats() {
        launchApp()
        openProgressMetric(named: "Alcohol")

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        tapCalendarDay(yesterday)

        XCTAssertTrue(app.buttons["dayEditor.slipped"].waitForExistence(timeout: 4))
        app.buttons["dayEditor.slipped"].tap()

        let save = app.buttons["slip.save"]
        XCTAssertTrue(save.waitForExistence(timeout: 8))
        save.tap()

        assertStaticTextExists("0 days free", timeout: 12)
    }
}
