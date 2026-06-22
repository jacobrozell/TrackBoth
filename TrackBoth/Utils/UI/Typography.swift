import SwiftUI
import UIKit

// MARK: - Typography System
/// Semantic text styles that scale with Dynamic Type; design comes from the active theme.
struct AppTypography {
    private static var currentFontDesign: Font.Design {
        ThemeManager.shared.selectedFontDesign.swiftUIDesign
    }

    // MARK: - Display Fonts
    static var displayLarge: Font {
        Font.system(.largeTitle, design: currentFontDesign, weight: .bold)
    }
    static var displayMedium: Font {
        Font.system(.title, design: currentFontDesign, weight: .bold)
    }
    static var displaySmall: Font {
        Font.system(.title2, design: currentFontDesign, weight: .bold)
    }

    // MARK: - Heading Fonts
    static var h1: Font {
        Font.system(.title, design: currentFontDesign, weight: .bold)
    }
    static var h2: Font {
        Font.system(.title2, design: currentFontDesign, weight: .semibold)
    }
    static var h3: Font {
        Font.system(.title3, design: currentFontDesign, weight: .semibold)
    }
    static var h4: Font {
        Font.system(.headline, design: currentFontDesign, weight: .semibold)
    }

    // MARK: - Body Fonts
    static var bodyLarge: Font {
        Font.system(.title3, design: currentFontDesign)
    }
    static var body: Font {
        Font.system(.body, design: currentFontDesign)
    }
    static var bodyMedium: Font {
        Font.system(.body, design: currentFontDesign, weight: .medium)
    }
    static var bodySmall: Font {
        Font.system(.subheadline, design: currentFontDesign)
    }

    // MARK: - Caption & Label Fonts
    static var caption: Font {
        Font.system(.caption, design: currentFontDesign, weight: .medium)
    }
    static var captionSmall: Font {
        Font.system(.caption2, design: currentFontDesign, weight: .medium)
    }
    static var label: Font {
        Font.system(.subheadline, design: currentFontDesign, weight: .semibold)
    }
    static var labelSmall: Font {
        Font.system(.caption, design: currentFontDesign, weight: .semibold)
    }

    // MARK: - Button Fonts
    static var buttonLarge: Font {
        Font.system(.headline, design: currentFontDesign, weight: .semibold)
    }
    static var button: Font {
        Font.system(.body, design: currentFontDesign, weight: .semibold)
    }
    static var buttonSmall: Font {
        Font.system(.subheadline, design: currentFontDesign, weight: .semibold)
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
    func displayLarge() -> some View { font(AppTypography.displayLarge) }
    func displayMedium() -> some View { font(AppTypography.displayMedium) }
    func displaySmall() -> some View { font(AppTypography.displaySmall) }
    func h1() -> some View { font(AppTypography.h1) }
    func h2() -> some View { font(AppTypography.h2) }
    func h3() -> some View { font(AppTypography.h3) }
    func h4() -> some View { font(AppTypography.h4) }
    func bodyLarge() -> some View { font(AppTypography.bodyLarge) }
    func body() -> some View { font(AppTypography.body) }
    func bodyMedium() -> some View { font(AppTypography.bodyMedium) }
    func bodySmall() -> some View { font(AppTypography.bodySmall) }
    func caption() -> some View { font(AppTypography.caption) }
    func captionSmall() -> some View { font(AppTypography.captionSmall) }
    func label() -> some View { font(AppTypography.label) }
    func labelSmall() -> some View { font(AppTypography.labelSmall) }
    func buttonLarge() -> some View { font(AppTypography.buttonLarge) }
    func button() -> some View { font(AppTypography.button) }
    func buttonSmall() -> some View { font(AppTypography.buttonSmall) }
}
