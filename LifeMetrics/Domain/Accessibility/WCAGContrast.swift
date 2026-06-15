import Foundation

// MARK: - WCAG Contrast
enum WCAGContrast {
    static let minimumBodyRatio = 4.5

    static func ratio(foreground: (r: Double, g: Double, b: Double), background: (r: Double, g: Double, b: Double)) -> Double {
        let l1 = relativeLuminance(foreground)
        let l2 = relativeLuminance(background)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    static func bodyTextRatio(for theme: AppTheme) -> Double {
        ratio(foreground: textRGB(for: theme), background: backgroundRGB(for: theme))
    }

    static func secondaryTextRatio(for theme: AppTheme) -> Double {
        ratio(foreground: secondaryTextRGB(for: theme), background: backgroundRGB(for: theme))
    }

    private static func relativeLuminance(_ rgb: (r: Double, g: Double, b: Double)) -> Double {
        func channel(_ value: Double) -> Double {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        let r = channel(rgb.r)
        let g = channel(rgb.g)
        let b = channel(rgb.b)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    private static func textRGB(for theme: AppTheme) -> (Double, Double, Double) {
        switch theme.name {
        case "Ocean": return (0.1, 0.2, 0.3)
        case "Forest": return (0.1, 0.3, 0.1)
        case "Sunset": return (0.3, 0.2, 0.1)
        case "Midnight": return (0.9, 0.9, 0.95)
        default: return (0.1, 0.2, 0.3)
        }
    }

    private static func secondaryTextRGB(for theme: AppTheme) -> (Double, Double, Double) {
        switch theme.name {
        case "Ocean": return (0.3, 0.4, 0.5)
        case "Forest": return (0.3, 0.4, 0.3)
        case "Sunset": return (0.5, 0.4, 0.3)
        case "Midnight": return (0.7, 0.7, 0.8)
        default: return (0.3, 0.4, 0.5)
        }
    }

    private static func backgroundRGB(for theme: AppTheme) -> (Double, Double, Double) {
        switch theme.name {
        case "Ocean": return (0.95, 0.98, 1.0)
        case "Forest": return (0.94, 0.97, 0.94)
        case "Sunset": return (1.0, 0.98, 0.95)
        case "Midnight": return (0.05, 0.05, 0.1)
        default: return (1.0, 1.0, 1.0)
        }
    }
}
