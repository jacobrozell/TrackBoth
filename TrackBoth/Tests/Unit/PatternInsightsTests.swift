import XCTest
@testable import TrackBoth

final class PatternInsightsTests: XCTestCase {
    private let calendar = Calendar.testNY

    func testTopTriggersOrderAndTieBreak() {
        let groups: [[TriggerTag]] = [
            [.stressed, .tired],
            [.stressed, .other],
            [.tired]
        ]
        let top = PatternInsights.topTriggers(from: groups, limit: 3)
        XCTAssertEqual(top.map(\.0), [.tired, .stressed])
        XCTAssertEqual(top.map(\.1), [2, 2])
    }

    func testOtherIsKeptOnlyWhenItIsTheOnlyTag() {
        XCTAssertEqual(PatternInsights.topTriggers(from: [[.other, .other]], limit: 3).map(\.0), [.other])
        let mixed = PatternInsights.topTriggers(from: [[.other, .other, .bored]], limit: 3)
        XCTAssertEqual(mixed.map(\.0), [.bored])
    }

    func testHardestTimeBucketsAndEdges() {
        let evening = date(2026, 10, 10, 18, 0)
        let nightEdge = date(2026, 10, 10, 4, 59)
        let morningEdge = date(2026, 10, 11, 5, 0)
        XCTAssertEqual(TimeOfDay.bucket(for: nightEdge, calendar: calendar), .night)
        XCTAssertEqual(TimeOfDay.bucket(for: morningEdge, calendar: calendar), .morning)
        XCTAssertEqual(TimeOfDay.bucket(for: date(2026, 10, 10, 12, 0), calendar: calendar), .afternoon)
        XCTAssertEqual(TimeOfDay.bucket(for: date(2026, 10, 10, 16, 59), calendar: calendar), .afternoon)
        XCTAssertEqual(TimeOfDay.bucket(for: date(2026, 10, 10, 17, 0), calendar: calendar), .evening)
        XCTAssertEqual(TimeOfDay.bucket(for: date(2026, 10, 10, 22, 0), calendar: calendar), .night)

        let hardest = PatternInsights.hardestTime(from: [evening, evening, evening, nightEdge], calendar: calendar)
        XCTAssertEqual(hardest, .evening)
    }

    func testHardestTimeNeedsThreePointsAndNoTie() {
        XCTAssertNil(PatternInsights.hardestTime(from: [date(2026, 10, 1, 18), date(2026, 10, 2, 18)], calendar: calendar))
        let tie = [
            date(2026, 10, 1, 8),
            date(2026, 10, 2, 8),
            date(2026, 10, 3, 18),
            date(2026, 10, 4, 18)
        ]
        XCTAssertNil(PatternInsights.hardestTime(from: tie, calendar: calendar))
    }

    func testLabelsLimitsAndUnevenCounts() {
        for time in TimeOfDay.allCases {
            XCTAssertFalse(time.title.isEmpty)
        }
        XCTAssertEqual(TimeOfDay.bucket(for: date(2026, 10, 10, 0, 0), calendar: calendar), .night)
        XCTAssertEqual(TimeOfDay.bucket(for: date(2026, 10, 10, 11, 0), calendar: calendar), .morning)
        XCTAssertEqual(TimeOfDay.bucket(for: date(2026, 10, 10, 21, 30), calendar: calendar), .evening)
        XCTAssertTrue(PatternInsights.topTriggers(from: []).isEmpty)
        let ranked = PatternInsights.topTriggers(from: [[.hungry, .hungry, .hungry], [.tired]], limit: 1)
        XCTAssertEqual(ranked.map(\.0), [.hungry])
        XCTAssertEqual(ranked.map(\.1), [3])
    }

    func testUrgeSummaryExcludesInProgress() {
        let summary = PatternInsights.urgeSummary([.resisted, .resisted, .slipped, .inProgress, .unknown])
        XCTAssertEqual(summary.beaten, 2)
        XCTAssertEqual(summary.total, 4)
    }
}
