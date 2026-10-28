import UIKit
import XCTest
@testable import TrackBoth

final class RecoveryPresetsTests: XCTestCase {
    func testPresetCatalog() {
        XCTAssertEqual(RecoveryPresets.vices.count, 11)
        XCTAssertEqual(RecoveryPresets.habits.count, 10)
        XCTAssertEqual(RecoveryPresets.extraIconNames.count, 12)
        let ids = (RecoveryPresets.vices + RecoveryPresets.habits).map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertEqual(RecoveryPresets.vices.first { $0.id == "alcohol" }?.iconName, "wineglass")
        XCTAssertEqual(RecoveryPresets.iconName(matching: " alcohol "), "wineglass")
        XCTAssertEqual(RecoveryPresets.iconName(matching: "Night scrolling"), RecoveryPresets.fallbackIcon)
        XCTAssertEqual(RecoveryPresets.customVerb, "do it")
    }

    func testSymbolsExistOnThisOS() {
        let missing = RecoveryPresets.symbolNames.filter { UIImage(systemName: $0) == nil }
        XCTAssertEqual(missing, [], "Missing SF Symbols: \(missing.joined(separator: ", "))")
    }
}
