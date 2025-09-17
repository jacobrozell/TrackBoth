import SwiftUI

// MARK: - App Theme Configuration
/// Defines the default color scheme and visual appearance for the app
struct AppTheme {
    let name: String
    let primaryColor: Color
    let secondaryColor: Color
    let backgroundColor: Color
    let secondaryBackgroundColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let accentColor: Color
    let successColor: Color
    let warningColor: Color
    let errorColor: Color
    let infoColor: Color
    
    // MARK: - Default Themes
    static let `default` = AppTheme(
        name: "Default",
        primaryColor: Color("ThemePrimary"),
        secondaryColor: Color("ThemeSecondary"),
        backgroundColor: Color("BackgroundPrimary"),
        secondaryBackgroundColor: Color("BackgroundSecondary"),
        textColor: Color("TextPrimary"),
        secondaryTextColor: Color("TextSecondary"),
        accentColor: Color("ThemeAccent"),
        successColor: Color("ThemeSuccess"),
        warningColor: Color("ThemeWarning"),
        errorColor: Color("ThemeError"),
        infoColor: Color("ThemeInfo")
    )
    
    static let ocean = AppTheme(
        name: "Ocean",
        primaryColor: Color(red: 0.0, green: 0.4, blue: 0.8),
        secondaryColor: Color(red: 0.0, green: 0.6, blue: 0.9),
        backgroundColor: Color(red: 0.95, green: 0.98, blue: 1.0),
        secondaryBackgroundColor: Color(red: 0.9, green: 0.95, blue: 1.0),
        textColor: Color(red: 0.1, green: 0.2, blue: 0.3),
        secondaryTextColor: Color(red: 0.3, green: 0.4, blue: 0.5), // Improved contrast
        accentColor: Color(red: 0.2, green: 0.7, blue: 0.9),
        successColor: Color(red: 0.0, green: 0.7, blue: 0.4),
        warningColor: Color(red: 1.0, green: 0.6, blue: 0.0),
        errorColor: Color(red: 0.9, green: 0.2, blue: 0.2),
        infoColor: Color(red: 0.0, green: 0.7, blue: 0.9)
    )
    
    static let forest = AppTheme(
        name: "Forest",
        primaryColor: Color(red: 0.0, green: 0.5, blue: 0.2),
        secondaryColor: Color(red: 0.2, green: 0.7, blue: 0.3),
        backgroundColor: Color(red: 0.95, green: 0.98, blue: 0.95),
        secondaryBackgroundColor: Color(red: 0.9, green: 0.95, blue: 0.9),
        textColor: Color(red: 0.1, green: 0.3, blue: 0.1),
        secondaryTextColor: Color(red: 0.3, green: 0.4, blue: 0.3), // Improved contrast
        accentColor: Color(red: 0.3, green: 0.8, blue: 0.4),
        successColor: Color(red: 0.0, green: 0.7, blue: 0.3),
        warningColor: Color(red: 0.9, green: 0.6, blue: 0.0),
        errorColor: Color(red: 0.8, green: 0.2, blue: 0.2),
        infoColor: Color(red: 0.0, green: 0.6, blue: 0.8)
    )
    
    static let sunset = AppTheme(
        name: "Sunset",
        primaryColor: Color(red: 0.8, green: 0.3, blue: 0.0),
        secondaryColor: Color(red: 1.0, green: 0.5, blue: 0.0),
        backgroundColor: Color(red: 1.0, green: 0.98, blue: 0.95),
        secondaryBackgroundColor: Color(red: 1.0, green: 0.95, blue: 0.9),
        textColor: Color(red: 0.3, green: 0.2, blue: 0.1),
        secondaryTextColor: Color(red: 0.5, green: 0.4, blue: 0.3), // Improved contrast
        accentColor: Color(red: 1.0, green: 0.6, blue: 0.2),
        successColor: Color(red: 0.0, green: 0.7, blue: 0.3),
        warningColor: Color(red: 1.0, green: 0.7, blue: 0.0),
        errorColor: Color(red: 0.9, green: 0.2, blue: 0.2),
        infoColor: Color(red: 0.0, green: 0.6, blue: 0.8)
    )
    
    static let midnight = AppTheme(
        name: "Midnight",
        primaryColor: Color(red: 0.6, green: 0.6, blue: 0.9), // Brighter purple for better readability
        secondaryColor: Color(red: 0.7, green: 0.7, blue: 0.95), // Lighter secondary
        backgroundColor: Color(red: 0.05, green: 0.05, blue: 0.1),
        secondaryBackgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
        textColor: Color(red: 0.9, green: 0.9, blue: 0.95),
        secondaryTextColor: Color(red: 0.7, green: 0.7, blue: 0.8),
        accentColor: Color(red: 0.7, green: 0.7, blue: 0.9), // Brighter accent purple
        successColor: Color(red: 0.0, green: 0.7, blue: 0.4),
        warningColor: Color(red: 1.0, green: 0.6, blue: 0.0),
        errorColor: Color(red: 0.9, green: 0.3, blue: 0.3),
        infoColor: Color(red: 0.0, green: 0.7, blue: 0.9)
    )
    
    // MARK: - Available Themes
    static let allThemes: [AppTheme] = [
        .default,
        .ocean,
        .forest,
        .sunset,
        .midnight
    ]
}

// MARK: - Theme Preview Helper
extension AppTheme {
    /// Creates a preview of how the theme looks
    func preview() -> some View {
        VStack(spacing: 16) {
            Text(name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(textColor)
            
            HStack(spacing: 12) {
                Circle()
                    .fill(primaryColor)
                    .frame(width: 30, height: 30)
                
                Circle()
                    .fill(secondaryColor)
                    .frame(width: 30, height: 30)
                
                Circle()
                    .fill(accentColor)
                    .frame(width: 30, height: 30)
                
                Circle()
                    .fill(successColor)
                    .frame(width: 30, height: 30)
                
                Circle()
                    .fill(warningColor)
                    .frame(width: 30, height: 30)
                
                Circle()
                    .fill(errorColor)
                    .frame(width: 30, height: 30)
            }
            
            Text("Sample Text")
                .foregroundColor(textColor)
            
            Text("Secondary Text")
                .foregroundColor(secondaryTextColor)
                .font(.caption)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(secondaryBackgroundColor, lineWidth: 1)
        )
    }
}
