import XCTest
@testable import TrackBoth

final class MetricPresetTests: XCTestCase {
    func testHabitPresetsArePositive() {
        XCTAssertFalse(MetricPreset.habitPresets.isEmpty)
        XCTAssertTrue(MetricPreset.habitPresets.allSatisfy { $0.habitType == .positive })
    }

    func testVicePresetsAreVices() {
        XCTAssertFalse(MetricPreset.vicePresets.isEmpty)
        XCTAssertTrue(MetricPreset.vicePresets.allSatisfy { $0.habitType == .vice })
    }

    func testPresetsForHabitType() {
        XCTAssertEqual(MetricPreset.presets(for: .positive).count, MetricPreset.habitPresets.count)
        XCTAssertEqual(MetricPreset.presets(for: .vice).count, MetricPreset.vicePresets.count)
    }

    func testDefaultMonthlyTargets() {
        XCTAssertEqual(MetricPresetFactory.defaultMonthlyTarget(for: .positive), 20)
        XCTAssertEqual(MetricPresetFactory.defaultMonthlyTarget(for: .vice), 8)
    }
}
