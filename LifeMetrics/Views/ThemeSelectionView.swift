import SwiftUI

struct ThemeSelectionView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(AppTheme.allThemes, id: \.name) { theme in
                        ThemePreviewCard(
                            theme: theme,
                            isSelected: themeManager.currentAppTheme.name == theme.name
                        ) {
                            themeManager.updateAppTheme(theme)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .themedPrimary()
                }
            }
            .themedBackground()
        }
    }
}

struct ThemePreviewCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Theme preview
                theme.preview()
                
                // Theme name
                Text(theme.name)
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.primaryColor)
                        .font(.title2)
                }
            }
            .padding()
            .background(theme.backgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? theme.primaryColor : theme.secondaryBackgroundColor,
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Theme Settings Integration
extension ThemeSelectionView {
    /// Creates a compact theme selector for settings
    static func compactThemeSelector() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Theme")
                .font(.headline)
                .themedPrimaryText()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AppTheme.allThemes, id: \.name) { theme in
                        CompactThemeCard(
                            theme: theme,
                            isSelected: ThemeManager.shared.currentAppTheme.name == theme.name
                        ) {
                            ThemeManager.shared.updateAppTheme(theme)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CompactThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Color swatches
                HStack(spacing: 4) {
                    Circle()
                        .fill(theme.primaryColor)
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .fill(theme.secondaryColor)
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 16, height: 16)
                }
                
                Text(theme.name)
                    .font(.caption)
                    .foregroundColor(theme.textColor)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(theme.primaryColor)
                }
            }
            .padding(8)
            .background(theme.backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? theme.primaryColor : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 80)
    }
}

#Preview {
    ThemeSelectionView()
}
