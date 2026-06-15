import XCTest
@testable import TrackBoth

final class ViceSlipTimerTests: XCTestCase {
    func testFormattedRecoveryTimeRequiresLoggedSlip() {
        let metricID = UUID()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        XCTAssertNil(ViceSlipTimer.formattedRecoveryTime(metricID: metricID, entries: [], asOf: today))

        let avoided = MetricEntry(metricID: metricID, date: today, value: false, hasBeenLogged: true)
        XCTAssertNil(ViceSlipTimer.formattedRecoveryTime(metricID: metricID, entries: [avoided], asOf: today))
    }

    func testFormattedRecoveryTimeUsesMostRecentSlip() throws {
        let metricID = UUID()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today),
              let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: today) else {
            XCTFail("Could not build dates")
            return
        }

        let entries = [
            MetricEntry(metricID: metricID, date: fiveDaysAgo, value: true, hasBeenLogged: true),
            MetricEntry(metricID: metricID, date: threeDaysAgo, value: true, hasBeenLogged: true)
        ]

        XCTAssertEqual(
            ViceSlipTimer.formattedRecoveryTime(metricID: metricID, entries: entries, asOf: today),
            "3d recovering"
        )
        XCTAssertEqual(
            ViceSlipTimer.compactRecoveryLabel(metricID: metricID, entries: entries, asOf: today),
            "3d recovering"
        )
    }
}
