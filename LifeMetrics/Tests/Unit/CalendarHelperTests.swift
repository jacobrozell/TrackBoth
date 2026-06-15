import XCTest
@testable import TrackBoth

final class CalendarHelperTests: XCTestCase {

    private var calendar: Calendar!
    private var savedWeekStartDay: Int?

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
        savedWeekStartDay = UserDefaults.standard.object(forKey: "weekStartDay") as? Int
    }

    override func tearDown() {
        if let savedWeekStartDay {
            UserDefaults.standard.set(savedWeekStartDay, forKey: "weekStartDay")
        } else {
            UserDefaults.standard.removeObject(forKey: "weekStartDay")
        }
        super.tearDown()
    }

    func testStartOfWeekUsesUserPreference() {
        UserDefaults.standard.set(2, forKey: "weekStartDay") // Monday
        let date = calendar.date(from: DateComponents(year: 2026, month: 6, day: 14))! // Sunday
        let weekStart = CalendarHelper.startOfWeek(for: date)
        let weekday = CalendarHelper.calendar.component(.weekday, from: weekStart)
        XCTAssertEqual(weekday, 2)
    }

    func testStartOfPeriodWeeklyMatchesStartOfWeek() {
        let date = Date()
        XCTAssertEqual(
            CalendarHelper.startOfPeriod(.weekly, for: date),
            CalendarHelper.startOfWeek(for: date)
        )
    }

    func testDaysBetweenSameDayIsZero() {
        let date = Date()
        XCTAssertEqual(CalendarHelper.daysBetween(date, date), 0)
    }

    func testIsSameDay() {
        let date = calendar.startOfDay(for: Date())
        XCTAssertTrue(CalendarHelper.isSameDay(date, date))
    }

    func testAddDays() {
        let date = calendar.startOfDay(for: Date())
        let next = CalendarHelper.addDays(1, to: date)
        XCTAssertEqual(CalendarHelper.daysBetween(date, next), 1)
    }
}
