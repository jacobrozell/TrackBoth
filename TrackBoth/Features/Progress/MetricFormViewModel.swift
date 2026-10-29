import Foundation
import Observation

@MainActor
@Observable
final class MetricFormViewModel {
    var name: String
    var habitType: HabitType
    var iconName: String
    var startedAt: Date
    var costText: String
    var isArchived: Bool
    let isNew: Bool

    init(metric: Metric?) {
        if let metric {
            name = metric.name
            habitType = metric.habitType
            iconName = metric.iconName
            startedAt = metric.startedAt
            costText = metric.costPerDay.map { NSDecimalNumber(decimal: $0).stringValue } ?? ""
            isArchived = metric.isArchived
            isNew = false
        } else {
            name = ""
            habitType = .vice
            iconName = Presets.vices.first?.iconName ?? Presets.fallbackIcon
            startedAt = Date()
            costText = ""
            isArchived = false
            isNew = true
        }
    }

    var showsTypePicker: Bool { isNew }
    var showsQuitDate: Bool { habitType == .vice }
    var showsCost: Bool { habitType == .vice }
    var nameError: String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return RecoveryCopy.nameRequired }
        if trimmed.count > 40 { return RecoveryCopy.nameTooLong }
        return nil
    }
    var canSave: Bool { nameError == nil }

    var cost: Decimal? {
        let trimmed = costText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let value = Decimal(string: trimmed), value > 0 else { return nil }
        return value
    }

    var icons: [String] {
        var seen = Set<String>()
        return (Presets.vices.map(\.iconName) + Presets.habits.map(\.iconName) + Presets.extraIconNames).filter { seen.insert($0).inserted }
    }

    func save(metric: Metric?, store: RecoveryStore, now: Date) throws -> Metric {
        guard canSave else { throw MetricFormError.invalid }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let metric {
            try store.update(metric, name: trimmed, iconName: iconName, startedAt: habitType == .vice ? startedAt : metric.startedAt, costPerDay: habitType == .vice ? cost : nil)
            if metric.isArchived != isArchived {
                try store.setArchived(metric, isArchived)
            }
            return metric
        }
        let start = habitType == .vice ? startedAt : now
        return try store.addMetric(name: trimmed, habitType: habitType, iconName: iconName, startedAt: start, costPerDay: habitType == .vice ? cost : nil, firstReason: nil)
    }

    func delete(_ metric: Metric, store: RecoveryStore) throws {
        try store.delete(metric)
    }
}

enum MetricFormError: Error {
    case invalid
}
