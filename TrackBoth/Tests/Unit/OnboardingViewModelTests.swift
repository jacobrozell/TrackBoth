import XCTest
@testable import TrackBoth

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    func testNeedsAViceOrTheHabitOnlyPath() {
        let model = OnboardingViewModel()
        model.pageIndex = 1
        XCTAssertEqual(model.page, .chooseVices)
        XCTAssertFalse(model.canAdvance)
        model.chooseHabitsOnly()
        XCTAssertTrue(model.canAdvance)
    }

    func testPastQuitDateIsEndOfThatDay() {
        let model = OnboardingViewModel()
        model.toggleVice("alcohol")
        var detail = model.detail(for: "alcohol", now: date(2026, 10, 28, 15))
        detail.when = .yesterday
        let start = model.startedAt(detail, now: date(2026, 10, 28, 15), calendar: .testNY)
        XCTAssertEqual(start, date(2026, 10, 27, 23, 59).addingTimeInterval(59))
    }

    func testTodayQuitDateIsNowAndHabitStartsNow() {
        let model = OnboardingViewModel()
        model.toggleVice("alcohol")
        model.reasonText = "For my health"
        model.toggleHabit("walk")
        let now = date(2026, 10, 28, 15, 30)
        let drafts = model.drafts(now: now, calendar: .testNY)
        XCTAssertEqual(drafts.map(\.name), ["Alcohol", "Go for a walk"])
        XCTAssertEqual(drafts[0].startedAt, now)
        XCTAssertEqual(drafts[0].firstReason, "For my health")
        XCTAssertEqual(drafts[1].habitType, .positive)
        XCTAssertEqual(drafts[1].startedAt, now)
        XCTAssertNil(drafts[1].firstReason)
    }

    func testHabitOnlySkipsVicePages() {
        let model = OnboardingViewModel()
        model.chooseHabitsOnly()
        XCTAssertFalse(model.pages.contains(.why))
        XCTAssertTrue(model.drafts(now: date(2026, 10, 28), calendar: .testNY).isEmpty)
    }
}
