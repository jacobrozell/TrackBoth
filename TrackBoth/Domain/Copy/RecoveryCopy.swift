import Foundation

enum RecoveryCopy {
    static func daysFree(_ count: Int) -> String {
        count == 1 ? "1 day free" : "\(count) days free"
    }

    static func clock(days: Int, hours: Int, minutes: Int) -> String {
        if days > 0 { return "\(days)d \(hours)h \(minutes)m" }
        if hours > 0 { return "\(hours)h \(minutes)m" }
        if minutes > 0 { return "\(minutes)m" }
        return "Just started"
    }

    static func clock(_ components: DateComponents) -> String {
        clock(days: components.day ?? 0, hours: components.hour ?? 0, minutes: components.minute ?? 0)
    }

    static func saved(_ amount: Decimal, locale: Locale = .current) -> String {
        let code = locale.currency?.identifier ?? "USD"
        let formatted = amount.formatted(.currency(code: code).locale(locale))
        return "\(formatted) saved"
    }

    static func freeOfLast(free: Int, counted: Int) -> String {
        "\(free) of last \(counted) days free"
    }

    static func habitRun(_ count: Int) -> String {
        count == 1 ? "1-day run" : "\(count)-day run"
    }

    static let dontMissTwice = "Don't miss twice"

    static func nextMilestone(_ threshold: Int, inDays: Int) -> String {
        let unit = inDays == 1 ? "day" : "days"
        return "Next: \(threshold) days (in \(inDays) \(unit))"
    }

    static func checkInBanner(left: Int) -> String {
        "\(left) to go · about 10 seconds"
    }

    static let sosButton = "I'm having an urge"
    static let urgeIntro = "Urges rise, peak, and pass, like a wave. Let's ride this one out."

    static func urgePassed(_ count: Int) -> String {
        let noun = count == 1 ? "urge" : "urges"
        return "You rode it out. That's \(count) \(noun) you've beaten."
    }

    static let slipTitle = "Thanks for being honest."
    static let slipSubtitle = "A slip is information, not failure. Let's learn from it."
    static let slipSummaryTitle = "Your free clock restarts from here."

    static func slipSummaryBody(free: Int, counted: Int, saved: String?) -> String {
        let savings = saved.map { " and \($0) saved" } ?? ""
        return "You still have \(free) of your last \(counted) days free\(savings). That progress is real and it stays."
    }

    static func milestoneVice(_ threshold: Int, name: String) -> String {
        threshold == 1 ? "Your first day free from \(name)." : "\(threshold) days free from \(name)."
    }

    static func milestoneHabit(_ threshold: Int, name: String) -> String {
        "\(threshold)-day run: \(name)."
    }

    static let disclaimer = "TrackBoth is a self-help tool, not medical treatment. Stopping some substances suddenly, like alcohol, benzodiazepines, or opioids, can be dangerous. Talk to a doctor. If you're in crisis, help is in Settings → Get help now."

    static let checkInNotificationTitle = "Daily check-in"
    static let checkInNotificationBody = "How did today go? It takes 10 seconds."
    static let discreetCheckInTitle = "TrackBoth"
    static let discreetCheckInBody = "Time for your check-in."
    static let discreetMilestoneBody = "You reached a new milestone."

    static func milestoneNotificationTitle(_ threshold: Int) -> String {
        "\(threshold) days free"
    }

    static func milestoneNotificationBody(_ threshold: Int, name: String) -> String {
        "You reached \(threshold) days free from \(name). Open TrackBoth to celebrate."
    }
}
