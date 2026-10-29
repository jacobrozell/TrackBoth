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

    static let checkInTitle = "Daily check-in"
    static let freeToday = "Free today"
    static let iSlipped = "I slipped"
    static let quitting = "Quitting"
    static let building = "Building"
    static let startWithOneThing = "Start with one thing"
    static let startWithOneThingMessage = "Add a vice or a habit and today gets simpler."
    static let addSomething = "Add something"
    static let yesterdayYes = "Yes"
    static let dismiss = "Dismiss"
    static let slipLoggedThanks = "Slip logged · thanks for being honest"
    static let havingAnUrge = "Having an urge right now?"
    static let done = "Done"
    static let backToToday = "Back to Today"
    static let close = "Close"
    static let urgeFlowStub = "Urge flow — Phase 6"
    static let slipFlowStub = "Slip flow — Phase 6"
    static let detailStub = "Detail comes in the next update."
    static let addStub = "Adding a metric comes in the next update."

    static func yesterdayPrompt(_ name: String) -> String {
        "Yesterday: were you free from \(name)?"
    }

    static func checkInSummary(days: Int, saved: String?) -> String {
        if let saved { return "\(daysFree(days)) · \(saved)" }
        return daysFree(days)
    }

    static let whichOne = "Which one?"
    static let howStrong = "How strong is it?"
    static let mild = "Mild"
    static let intense = "Intense"
    static let skip = "Skip"
    static let theUrgePassed = "The urge passed"
    static let notSure = "Not sure"
    static let howDidItGo = "How did it go?"
    static let addFiveMinutes = "+5 min"
    static let stillWithIt = "Still with it? You can add 5 minutes, or check in with yourself."
    static let yourWhy = "Your why"
    static let yourPlanPrefix = "When I feel the urge, I will:"
    static let tryOneInstead = "Try one instead"
    static let whatSetItOff = "What set it off?"
    static let whenQuestion = "When?"
    static let justNow = "Just now"
    static let earlierToday = "Earlier today"
    static let yesterday = "Yesterday"
    static let pickADay = "Pick a day…"
    static let whatWasGoingOn = "What was going on?"
    static let anythingElse = "Anything else?"
    static let nextTimePlan = "Next time I feel the urge, I will…"
    static let save = "Save"
    static let rememberWhy = "Remember why:"
    static let keepGoing = "Keep going"
    static let needSupport = "Need more support?"
    static let getHelpNow = "Get help now"
    static let noViceForUrge = "Add something you're quitting first."
    static let slipBeforeStart = "That day is before this quit date."
    static let urgesBeaten = "Urges beaten"
    static func intensityLabel(_ level: Int) -> String {
        switch level {
        case 1: "1 \(mild)"
        case 5: "5 \(intense)"
        default: "\(level)"
        }
    }

    static func urgesBeatenCount(_ count: Int) -> String { "\(urgesBeaten) \(count)" }

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
