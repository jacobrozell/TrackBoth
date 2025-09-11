import SwiftUI

// MARK: - Theme Manager
/// Manages app theming and provides easy access to themed colors
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: Theme = .system
    
    private init() {
        // Load saved theme from UserDefaults
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = Theme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
    
    func updateTheme(_ theme: Theme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }
}

// MARK: - Theme Colors Extension
extension Color {
    // Background Colors
    static let appBackgroundPrimary = Color("BackgroundPrimary")
    static let appBackgroundSecondary = Color("BackgroundSecondary")
    
    // Text Colors
    static let appTextPrimary = Color("TextPrimary")
    static let appTextSecondary = Color("TextSecondary")
    
    // Accent Colors (using system colors that adapt to theme)
    static let accentBlue = Color.blue
    static let accentGreen = Color.green
    static let accentRed = Color.red
    static let accentOrange = Color.orange
    static let accentPurple = Color.purple
}

// MARK: - View Modifiers for Themed Colors
extension View {
    func themedBackground() -> some View {
        self.background(Color.appBackgroundPrimary)
    }
    
    func themedSecondaryBackground() -> some View {
        self.background(Color.appBackgroundSecondary)
    }
    
    func themedPrimaryText() -> some View {
        self.foregroundColor(Color.appTextPrimary)
    }
    
    func themedSecondaryText() -> some View {
        self.foregroundColor(Color.appTextSecondary)
    }
}
