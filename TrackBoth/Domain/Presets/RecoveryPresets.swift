import Foundation

struct RecoveryPreset: Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    var iconName: String
    /// Verb phrase for "When did you last …?" Vices only.
    var lastUseVerb: String
}

enum RecoveryPresets {
    static let customVerb = "do it"
    static let fallbackIcon = "circle.dashed"

    static let vices: [RecoveryPreset] = [
        RecoveryPreset(id: "alcohol", name: "Alcohol", iconName: "wineglass", lastUseVerb: "drink"),
        RecoveryPreset(id: "smoking", name: "Smoking", iconName: "smoke", lastUseVerb: "smoke"),
        RecoveryPreset(id: "vaping", name: "Vaping", iconName: "cloud", lastUseVerb: "vape"),
        RecoveryPreset(id: "cannabis", name: "Cannabis", iconName: "leaf", lastUseVerb: "use cannabis"),
        RecoveryPreset(id: "gambling", name: "Gambling", iconName: "dice", lastUseVerb: "gamble"),
        RecoveryPreset(id: "porn", name: "Porn", iconName: "eye.slash", lastUseVerb: "watch porn"),
        RecoveryPreset(id: "social-media", name: "Social media", iconName: "iphone", lastUseVerb: "scroll social media"),
        RecoveryPreset(id: "gaming", name: "Gaming", iconName: "gamecontroller", lastUseVerb: "game"),
        RecoveryPreset(id: "junk-food", name: "Junk food", iconName: "takeoutbag.and.cup.and.straw", lastUseVerb: "eat junk food"),
        RecoveryPreset(id: "shopping", name: "Impulse shopping", iconName: "bag", lastUseVerb: "impulse shop"),
        RecoveryPreset(id: "caffeine", name: "Caffeine", iconName: "cup.and.saucer", lastUseVerb: "have caffeine")
    ]

    static let habits: [RecoveryPreset] = [
        RecoveryPreset(id: "walk", name: "Go for a walk", iconName: "figure.walk", lastUseVerb: ""),
        RecoveryPreset(id: "exercise", name: "Exercise", iconName: "figure.run", lastUseVerb: ""),
        RecoveryPreset(id: "water", name: "Drink water", iconName: "drop", lastUseVerb: ""),
        RecoveryPreset(id: "reach-out", name: "Call or text a friend", iconName: "phone", lastUseVerb: ""),
        RecoveryPreset(id: "breathe", name: "Breathe / meditate", iconName: "wind", lastUseVerb: ""),
        RecoveryPreset(id: "journal", name: "Journal", iconName: "book.closed", lastUseVerb: ""),
        RecoveryPreset(id: "outside", name: "Time outside", iconName: "sun.max", lastUseVerb: ""),
        RecoveryPreset(id: "meal", name: "Eat a real meal", iconName: "fork.knife", lastUseVerb: ""),
        RecoveryPreset(id: "sleep", name: "In bed by 11", iconName: "bed.double", lastUseVerb: ""),
        RecoveryPreset(id: "meeting", name: "Support group / meeting", iconName: "person.3", lastUseVerb: "")
    ]

    /// Icons offered in addition to the preset symbols.
    static let extraIconNames: [String] = [
        "heart", "star", "moon.stars", "book", "figure.mind.and.body", "lungs",
        "pills", "creditcard", "tv", "car", "house", "brain"
    ]

    static var symbolNames: [String] {
        let presetIcons = (vices + habits).map(\.iconName)
        let triggerIcons = TriggerTag.allCases.map(\.systemImage)
        return Array(Set(presetIcons + extraIconNames + triggerIcons + [fallbackIcon])).sorted()
    }

    static func iconName(matching name: String) -> String {
        let key = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return (vices + habits).first { $0.name.lowercased() == key }?.iconName ?? fallbackIcon
    }
}
