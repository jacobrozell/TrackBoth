import SwiftUI
import Observation

// MARK: - Theme Manager
/// Manages app theming and provides easy access to themed colors
@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    var currentTheme: Theme = .system
    var currentAppTheme: AppTheme = .ocean
    var selectedFontDesign: FontDesign = .rounded

    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: ThemePreferences.selectedTheme),
           let theme = Theme(rawValue: savedTheme) {
            currentTheme = theme
            logger.info("Theme loaded from UserDefaults - Theme: \(theme.rawValue)")
        } else {
            logger.info("Using default theme - Theme: \(currentTheme.rawValue)")
        }

        if let savedAppTheme = UserDefaults.standard.string(forKey: ThemePreferences.selectedAppTheme),
           let appTheme = AppTheme.allThemes.first(where: { $0.name == savedAppTheme }) {
            currentAppTheme = appTheme
            logger.info("App theme loaded from UserDefaults - Theme: \(appTheme.name)")
        } else {
            setDefaultThemeForSystemAppearance()
            logger.info("Using default app theme - Theme: \(currentAppTheme.name)")
        }

        if let savedFontDesign = UserDefaults.standard.string(forKey: ThemePreferences.selectedFontDesign),
           let fontDesign = FontDesign(rawValue: savedFontDesign) {
            selectedFontDesign = fontDesign
            logger.info("Font design loaded from UserDefaults - Design: \(fontDesign.rawValue)")
        } else {
            logger.info("Using default font design - Design: \(selectedFontDesign.rawValue)")
        }

        updateNavigationBarAppearance()
    }

    func updateTheme(_ theme: Theme) {
        logger.logUserAction("Theme updated", details: "From \(currentTheme.rawValue) to \(theme.rawValue)")
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: ThemePreferences.selectedTheme)
    }

    func updateAppTheme(_ appTheme: AppTheme) {
        logger.logUserAction("App theme updated", details: "From \(currentAppTheme.name) to \(appTheme.name)")
        currentAppTheme = appTheme
        UserDefaults.standard.set(appTheme.name, forKey: ThemePreferences.selectedAppTheme)
        applyChromeRefresh()
    }

    func updateFontDesign(_ fontDesign: FontDesign) {
        logger.logUserAction("Font design updated", details: "From \(selectedFontDesign.rawValue) to \(fontDesign.rawValue)")
        selectedFontDesign = fontDesign
        UserDefaults.standard.set(fontDesign.rawValue, forKey: ThemePreferences.selectedFontDesign)
        applyChromeRefresh()
    }
    
    /// Sets the default theme based on the current system appearance
    private func setDefaultThemeForSystemAppearance() {
        let systemAppearance = UITraitCollection.current.userInterfaceStyle
        
        switch systemAppearance {
        case .dark:
            currentAppTheme = .midnight
            logger.info("System is in dark mode - using Midnight theme as default")
        case .light, .unspecified:
            currentAppTheme = .ocean
            logger.info("System is in light mode - using Ocean theme as default")
        @unknown default:
            currentAppTheme = .ocean
            logger.info("Unknown system appearance - defaulting to Ocean theme")
        }
    }
    
    func resetToDefaultTheme() {
        logger.logUserAction("Reset to default theme", details: "Based on system appearance")
        setDefaultThemeForSystemAppearance()
        UserDefaults.standard.set(currentAppTheme.name, forKey: ThemePreferences.selectedAppTheme)
        applyChromeRefresh()
    }

    private func applyChromeRefresh() {
        DispatchQueue.main.async {
            self.updateNavigationBarAppearance()
            self.forceUIRefresh()
        }
    }
    
    /// Updates the navigation bar appearance to match the current theme
    private func updateNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set background color
        appearance.backgroundColor = UIColor(currentAppTheme.backgroundColor)
        
        // Set title text attributes with selected font design
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(currentAppTheme.textColor),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold).withDesign(selectedFontDesign)
        ]
        
        // Set large title text attributes with selected font design
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(currentAppTheme.textColor),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold).withDesign(selectedFontDesign)
        ]
        
        // Set button appearance
        appearance.buttonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(currentAppTheme.primaryColor)
        ]
        
        // Apply to navigation bar
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // Force refresh of all navigation bars
        refreshAllNavigationBars()
        
        // Update tab bar appearance
        updateTabBarAppearance()
    }
    
    /// Refreshes all navigation bars in the app
    private func refreshAllNavigationBars() {
        DispatchQueue.main.async {
            // Get all windows and update their navigation bars
            for windowScene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
                for window in windowScene.windows {
                    self.updateNavigationBarInView(window.rootViewController?.view)
                }
            }
        }
    }
    
    private func updateNavigationBarInView(_ view: UIView?) {
        guard let view = view else { return }
        
        if let navigationBar = view as? UINavigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(currentAppTheme.backgroundColor)
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor(currentAppTheme.textColor),
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold).withDesign(selectedFontDesign)
            ]
            appearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor(currentAppTheme.textColor),
                .font: UIFont.systemFont(ofSize: 34, weight: .bold).withDesign(selectedFontDesign)
            ]
            appearance.buttonAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(currentAppTheme.primaryColor)
            ]
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
        
        for subview in view.subviews {
            updateNavigationBarInView(subview)
        }
    }
    
    /// Updates the tab bar appearance to match the current theme
    private func updateTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set background color
        appearance.backgroundColor = UIColor(currentAppTheme.backgroundColor)
        
        // Set normal state colors
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(currentAppTheme.secondaryTextColor)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(currentAppTheme.secondaryTextColor)
        ]
        
        // Set selected state colors
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(currentAppTheme.primaryColor)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(currentAppTheme.primaryColor)
        ]
        
        // Apply to tab bar appearance proxy
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        // Force refresh of all tab bars
        refreshAllTabBars()
    }
    
    /// Refreshes all tab bars in the app
    private func refreshAllTabBars() {
        DispatchQueue.main.async {
            // Get all windows and update their tab bars
            for windowScene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
                for window in windowScene.windows {
                    self.updateTabBarInView(window.rootViewController?.view)
                }
            }
        }
    }
    
    private func updateTabBarInView(_ view: UIView?) {
        guard let view = view else { return }
        
        if let tabBar = view as? UITabBar {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(currentAppTheme.backgroundColor)
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(currentAppTheme.secondaryTextColor)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(currentAppTheme.secondaryTextColor)
            ]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(currentAppTheme.primaryColor)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(currentAppTheme.primaryColor)
            ]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
        
        for subview in view.subviews {
            updateTabBarInView(subview)
        }
    }
    
    /// Forces immediate UI refresh across the app
    private func forceUIRefresh() {
        // Force refresh of all windows
        for windowScene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            for window in windowScene.windows {
                // Force the window to refresh its appearance
                window.setNeedsDisplay()
                
                // Update navigation controller appearance if present
                if let navController = window.rootViewController as? UINavigationController {
                    navController.navigationBar.setNeedsLayout()
                    navController.navigationBar.layoutIfNeeded()
                }
                
                // Update tab bar controller appearance if present
                if let tabController = window.rootViewController as? UITabBarController {
                    tabController.tabBar.setNeedsLayout()
                    tabController.tabBar.layoutIfNeeded()
                }
            }
        }
    }
    
    /// Gets the current effective theme colors based on system appearance
    var effectiveTheme: AppTheme {
        currentAppTheme
    }

    /// Color scheme for SwiftUI system chrome (List labels, section headers, pickers).
    var preferredColorScheme: ColorScheme? {
        switch currentTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return currentAppTheme.preferredColorScheme
        }
    }
}

// MARK: - Color Extensions
extension Color {
    // Background Colors
    static let appBackgroundPrimary = Color("BackgroundPrimary")
    static let appBackgroundSecondary = Color("BackgroundSecondary")
    
    // Text Colors
    static let appTextPrimary = Color("TextPrimary")
    static let appTextSecondary = Color("TextSecondary")
    
    // Main Theme Colors (semantic colors that adapt to theme)
    static let assetThemePrimary = Color("ThemePrimary") // Deep blue - main brand color
    static let assetThemeSecondary = Color("ThemeSecondary") // Teal - secondary actions
    static let assetThemeSuccess = Color("ThemeSuccess") // Green - success states
    static let assetThemeWarning = Color("ThemeWarning") // Orange - warnings
    static let assetThemeError = Color("ThemeError") // Red - errors/danger
    static let assetThemeInfo = Color("ThemeInfo") // Cyan - informational
    static let assetThemeAccent = Color("ThemeAccent") // Purple - accent/highlight
    
    // Legacy Accent Colors (keeping for backward compatibility)
    static let assetAccentBlue = Color.blue
    static let assetAccentGreen = Color.green
    static let assetAccentRed = Color.red
    static let assetAccentOrange = Color("AccentOrange") // Custom orange from colorset
    static let assetAccentPurple = Color("AccentPurple") // Custom purple from colorset
    static let assetAccentTeal = Color("AccentTeal") // Custom teal from colorset
    static let assetAccentPink = Color("AccentPink") // Custom pink from colorset
    static let assetAccentCyan = Color("AccentCyan") // Custom cyan from colorset
    static let assetAccentIndigo = Color("AccentIndigo") // Custom indigo from colorset
    
    // MARK: - Dynamic Theme Colors
    /// Gets colors from the current app theme
    static var currentTheme: AppTheme {
        ThemeManager.shared.effectiveTheme
    }
    
    static var currentPrimary: Color {
        ThemeManager.shared.effectiveTheme.primaryColor
    }
    
    static var currentSecondary: Color {
        ThemeManager.shared.effectiveTheme.secondaryColor
    }
    
    static var currentBackground: Color {
        ThemeManager.shared.effectiveTheme.backgroundColor
    }
    
    static var currentSecondaryBackground: Color {
        ThemeManager.shared.effectiveTheme.secondaryBackgroundColor
    }
    
    static var currentText: Color {
        ThemeManager.shared.effectiveTheme.textColor
    }
    
    static var currentSecondaryText: Color {
        ThemeManager.shared.effectiveTheme.secondaryTextColor
    }
    
    static var currentAccent: Color {
        ThemeManager.shared.effectiveTheme.accentColor
    }
    
    static var currentSuccess: Color {
        ThemeManager.shared.effectiveTheme.successColor
    }
    
    static var currentWarning: Color {
        ThemeManager.shared.effectiveTheme.warningColor
    }
    
    static var currentError: Color {
        ThemeManager.shared.effectiveTheme.errorColor
    }
    
    static var currentInfo: Color {
        ThemeManager.shared.effectiveTheme.infoColor
    }
}

// MARK: - View Modifiers for Themed Colors
extension View {
    func themedBackground() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                Color.currentBackground
                    .ignoresSafeArea()
            }
    }
    
    func themedSecondaryBackground() -> some View {
        self.background(Color.currentSecondaryBackground)
    }
    
    func themedPrimaryText() -> some View {
        self.foregroundColor(Color.currentText)
    }
    
    func themedSecondaryText() -> some View {
        self.foregroundColor(Color.currentSecondaryText)
    }
    
    func themedPrimary() -> some View {
        self.foregroundColor(Color.currentPrimary)
    }
    
    func themedSecondary() -> some View {
        self.foregroundColor(Color.currentSecondary)
    }
    
    func themedAccent() -> some View {
        self.foregroundColor(Color.currentAccent)
    }
    
    func themedSuccess() -> some View {
        self.foregroundColor(Color.currentSuccess)
    }
    
    func themedWarning() -> some View {
        self.foregroundColor(Color.currentWarning)
    }
    
    func themedError() -> some View {
        self.foregroundColor(Color.currentError)
    }
    
    func themedInfo() -> some View {
        self.foregroundColor(Color.currentInfo)
    }
}
