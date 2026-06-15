import XCTest
@testable import TrackBoth

final class StreakCopyTests: XCTestCase {
    func testHabitStreakSingular() {
        XCTAssertEqual(StreakCopy.habitStreak(1), "1 day streak")
    }

    func testHabitStreakPlural() {
        XCTAssertEqual(StreakCopy.habitStreak(5), "5 days streak")
    }

    func testViceCleanSingular() {
        XCTAssertEqual(StreakCopy.viceClean(1), "1 day clean")
    }

    func testViceCleanPlural() {
        XCTAssertEqual(StreakCopy.viceClean(3), "3 days clean")
    }
}
