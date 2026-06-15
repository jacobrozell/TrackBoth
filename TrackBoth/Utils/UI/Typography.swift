import SwiftUI
import UIKit

// MARK: - Typography System
/// Centralized typography system for consistent, modern font styling throughout the app
struct AppTypography {
    // Get current font design from ThemeManager
    private static var currentFontDesign: Font.Design {
        ThemeManager.shared.selectedFontDesign.swiftUIDesign
    }
    
    // MARK: - Display Fonts (Large, impactful text)
    static var displayLarge: Font {
        Font.system(size: 48, weight: .bold, design: currentFontDesign)
    }
    static var displayMedium: Font {
        Font.system(size: 36, weight: .bold, design: currentFontDesign)
    }
    static var displaySmall: Font {
        Font.system(size: 32, weight: .bold, design: currentFontDesign)
    }
    
    // MARK: - Heading Fonts
    static var h1: Font {
        Font.system(size: 28, weight: .bold, design: currentFontDesign)
    }
    static var h2: Font {
        Font.system(size: 24, weight: .semibold, design: currentFontDesign)
    }
    static var h3: Font {
        Font.system(size: 20, weight: .semibold, design: currentFontDesign)
    }
    static var h4: Font {
        Font.system(size: 18, weight: .semibold, design: currentFontDesign)
    }
    
    // MARK: - Body Fonts
    static var bodyLarge: Font {
        Font.system(size: 18, weight: .regular, design: currentFontDesign)
    }
    static var body: Font {
        Font.system(size: 16, weight: .regular, design: currentFontDesign)
    }
    static var bodyMedium: Font {
        Font.system(size: 16, weight: .medium, design: currentFontDesign)
    }
    static var bodySmall: Font {
        Font.system(size: 14, weight: .regular, design: currentFontDesign)
    }
    
    // MARK: - Caption & Label Fonts
    static var caption: Font {
        Font.system(size: 12, weight: .medium, design: currentFontDesign)
    }
    static var captionSmall: Font {
        Font.system(size: 11, weight: .medium, design: currentFontDesign)
    }
    static var label: Font {
        Font.system(size: 14, weight: .semibold, design: currentFontDesign)
    }
    static var labelSmall: Font {
        Font.system(size: 12, weight: .semibold, design: currentFontDesign)
    }
    
    // MARK: - Button Fonts
    static var buttonLarge: Font {
        Font.system(size: 18, weight: .semibold, design: currentFontDesign)
    }
    static var button: Font {
        Font.system(size: 16, weight: .semibold, design: currentFontDesign)
    }
    static var buttonSmall: Font {
        Font.system(size: 14, weight: .semibold, design: currentFontDesign)
    }
}

// MARK: - UIFont Extension for Font Design
extension UIFont {
    func rounded() -> UIFont {
        guard let descriptor = fontDescriptor.withDesign(.rounded) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    func withDesign(_ fontDesign: FontDesign) -> UIFont {
        let uifontDesign: UIFontDescriptor.SystemDesign
        switch fontDesign {
        case .default:
            uifontDesign = .default
        case .rounded:
            uifontDesign = .rounded
        case .serif:
            uifontDesign = .serif
        case .monospaced:
            uifontDesign = .monospaced
        }
        
        guard let descriptor = fontDescriptor.withDesign(uifontDesign) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

// MARK: - Typography View Modifiers
extension View {
    // Display Styles
    func displayLarge() -> some View {
        self.font(AppTypography.displayLarge)
    }
    
    func displayMedium() -> some View {
        self.font(AppTypography.displayMedium)
    }
    
    func displaySmall() -> some View {
        self.font(AppTypography.displaySmall)
    }
    
    // Heading Styles
    func h1() -> some View {
        self.font(AppTypography.h1)
    }
    
    func h2() -> some View {
        self.font(AppTypography.h2)
    }
    
    func h3() -> some View {
        self.font(AppTypography.h3)
    }
    
    func h4() -> some View {
        self.font(AppTypography.h4)
    }
    
    // Body Styles
    func bodyLarge() -> some View {
        self.font(AppTypography.bodyLarge)
    }
    
    func body() -> some View {
        self.font(AppTypography.body)
    }
    
    func bodyMedium() -> some View {
        self.font(AppTypography.bodyMedium)
    }
    
    func bodySmall() -> some View {
        self.font(AppTypography.bodySmall)
    }
    
    // Caption & Label Styles
    func caption() -> some View {
        self.font(AppTypography.caption)
    }
    
    func captionSmall() -> some View {
        self.font(AppTypography.captionSmall)
    }
    
    func label() -> some View {
        self.font(AppTypography.label)
    }
    
    func labelSmall() -> some View {
        self.font(AppTypography.labelSmall)
    }
    
    // Button Styles
    func buttonLarge() -> some View {
        self.font(AppTypography.buttonLarge)
    }
    
    func button() -> some View {
        self.font(AppTypography.button)
    }
    
    func buttonSmall() -> some View {
        self.font(AppTypography.buttonSmall)
    }
}

