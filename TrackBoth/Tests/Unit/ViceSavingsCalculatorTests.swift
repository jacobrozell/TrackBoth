import XCTest
@testable import TrackBoth

final class ViceSavingsCalculatorTests: XCTestCase {
    func testEstimatedSavingsRequiresPositiveStreakAndCost() {
        XCTAssertNil(ViceSavingsCalculator.estimatedSavings(streak: 0, costPerUnit: 8))
        XCTAssertNil(ViceSavingsCalculator.estimatedSavings(streak: 5, costPerUnit: nil))
        XCTAssertNil(ViceSavingsCalculator.estimatedSavings(streak: 5, costPerUnit: 0))
    }

    func testEstimatedSavingsMultipliesStreakByCost() {
        XCTAssertEqual(
            ViceSavingsCalculator.estimatedSavings(streak: 7, costPerUnit: 8),
            Decimal(56)
        )
    }

    func testSavingsLabelHiddenWhenNoCost() {
        XCTAssertNil(ViceSavingsCalculator.savingsLabel(streak: 10, costPerUnit: nil))
    }

    func testSavingsLabelFormatsCurrency() {
        let label = ViceSavingsCalculator.savingsLabel(streak: 3, costPerUnit: 5)
        XCTAssertTrue(label?.contains("15") == true)
        XCTAssertTrue(label?.contains("saved") == true)
    }
}
