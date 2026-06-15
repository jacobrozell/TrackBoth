import Foundation

// MARK: - ViceSavingsCalculator
enum ViceSavingsCalculator {
    /// Estimated savings for a clean streak, assuming one unit avoided per day.
    static func estimatedSavings(streak: Int, costPerUnit: Decimal?) -> Decimal? {
        guard streak > 0, let costPerUnit, costPerUnit > 0 else { return nil }
        return costPerUnit * Decimal(streak)
    }

    static func formattedSavings(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = amount.isWholeNumber ? 0 : 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "$\(amount)"
    }

    static func savingsLabel(streak: Int, costPerUnit: Decimal?) -> String? {
        guard let amount = estimatedSavings(streak: streak, costPerUnit: costPerUnit) else { return nil }
        return "\(formattedSavings(amount)) saved"
    }
}

private extension Decimal {
    var isWholeNumber: Bool {
        var rounded = Decimal()
        var value = self
        NSDecimalRound(&rounded, &value, 0, .plain)
        return self == rounded
    }
}
