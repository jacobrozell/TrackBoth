import Foundation

enum TimeOfDay: String, CaseIterable, Equatable {
    case morning, afternoon, evening, night

    var title: String {
        switch self {
        case .morning: "Morning"
        case .afternoon: "Afternoon"
        case .evening: "Evenings"
        case .night: "Night"
        }
    }

    static func bucket(for date: Date, calendar: Calendar) -> TimeOfDay {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }
}

enum PatternInsights {
    /// Count across slips and urges. Sort by count, then `TriggerTag.allCases` order.
    /// `.other` is dropped unless it is the only tag present.
    static func topTriggers(from groups: [[TriggerTag]], limit: Int = 3) -> [(TriggerTag, Int)] {
        var counts: [TriggerTag: Int] = [:]
        for group in groups {
            for tag in group {
                counts[tag, default: 0] += 1
            }
        }
        let order = TriggerTag.allCases
        let ranked = counts.keys.sorted { lhs, rhs in
            let leftCount = counts[lhs, default: 0]
            let rightCount = counts[rhs, default: 0]
            if leftCount != rightCount { return leftCount > rightCount }
            return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
        }
        let withoutOther = ranked.filter { $0 != .other }
        let chosen = withoutOther.isEmpty ? ranked : withoutOther
        return chosen.prefix(limit).map { ($0, counts[$0, default: 0]) }
    }

    /// The busiest bucket among slips and non-resisted urges.
    /// `nil` when there are fewer than 3 timestamps or a tie for first.
    static func hardestTime(from timestamps: [Date], calendar: Calendar = .current) -> TimeOfDay? {
        guard timestamps.count >= 3 else { return nil }
        var counts: [TimeOfDay: Int] = [:]
        for timestamp in timestamps {
            let bucket = TimeOfDay.bucket(for: timestamp, calendar: calendar)
            counts[bucket, default: 0] += 1
        }
        let maxCount = counts.values.max() ?? 0
        let leaders = TimeOfDay.allCases.filter { (counts[$0] ?? 0) == maxCount }
        return leaders.count == 1 ? leaders[0] : nil
    }

    static func urgeSummary(_ outcomes: [UrgeOutcome]) -> (beaten: Int, total: Int) {
        let finished = outcomes.filter { $0 != .inProgress }
        return (finished.filter { $0 == .resisted }.count, finished.count)
    }
}
