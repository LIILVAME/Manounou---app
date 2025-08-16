//
//  Theme.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI
import Foundation

// MARK: - App Theme

struct AppTheme {
    
    // MARK: - Colors
    
    struct Colors {
        // Primary Colors
        static let primary = Color("PrimaryColor") // Bleu principal
        static let primaryLight = Color("PrimaryLightColor")
        static let primaryDark = Color("PrimaryDarkColor")
        
        // Secondary Colors
        static let secondary = Color("SecondaryColor") // Orange/Coral
        static let secondaryLight = Color("SecondaryLightColor")
        static let secondaryDark = Color("SecondaryDarkColor")
        
        // Accent Colors
        static let accent = Color("AccentColor")
        static let accentLight = Color("AccentLightColor")
        static let accentDark = Color("AccentDarkColor")
        
        // Semantic Colors
        static let success = Color("SuccessColor") // Vert
        static let warning = Color("WarningColor") // Jaune/Orange
        static let error = Color("ErrorColor") // Rouge
        static let info = Color("InfoColor") // Bleu clair
        
        // Neutral Colors
        static let background = Color("BackgroundColor")
        static let surface = Color("SurfaceColor")
        static let surfaceSecondary = Color("SurfaceSecondaryColor")
        
        // Text Colors
        static let textPrimary = Color("TextPrimaryColor")
        static let textSecondary = Color("TextSecondaryColor")
        static let textTertiary = Color("TextTertiaryColor")
        static let textOnPrimary = Color.white
        static let textOnSecondary = Color.white
        
        // Border Colors
        static let border = Color("BorderColor")
        static let borderLight = Color("BorderLightColor")
        static let borderDark = Color("BorderDarkColor")
        
        // Gender Colors
        static let genderMale = Color.blue
        static let genderFemale = Color.pink
        static let genderOther = Color.purple
        
        // Age Category Colors
        static let ageBaby = Color.mint
        static let ageToddler = Color.green
        static let agePreschool = Color.orange
        static let ageSchool = Color.blue
        static let ageTeen = Color.purple
        
        // Status Colors
        static let statusActive = Color.green
        static let statusInactive = Color.gray
        static let statusPending = Color.orange
        static let statusCompleted = Color.blue
    }
    
    // MARK: - Typography
    
    struct Typography {
        // Font Families
        static let primaryFont = "SF Pro Display"
        static let secondaryFont = "SF Pro Text"
        static let monoFont = "SF Mono"
        
        // Font Sizes
        struct FontSize {
            static let largeTitle: CGFloat = 34
            static let title1: CGFloat = 28
            static let title2: CGFloat = 22
            static let title3: CGFloat = 20
            static let headline: CGFloat = 17
            static let body: CGFloat = 17
            static let callout: CGFloat = 16
            static let subheadline: CGFloat = 15
            static let footnote: CGFloat = 13
            static let caption1: CGFloat = 12
            static let caption2: CGFloat = 11
        }
        
        // Font Weights
        struct FontWeight {
            static let ultraLight = Font.Weight.ultraLight
            static let thin = Font.Weight.thin
            static let light = Font.Weight.light
            static let regular = Font.Weight.regular
            static let medium = Font.Weight.medium
            static let semibold = Font.Weight.semibold
            static let bold = Font.Weight.bold
            static let heavy = Font.Weight.heavy
            static let black = Font.Weight.black
        }
        
        // Predefined Text Styles
        static let largeTitle = Font.custom(primaryFont, size: FontSize.largeTitle, relativeTo: .largeTitle).weight(.bold)
        static let title1 = Font.custom(primaryFont, size: FontSize.title1, relativeTo: .title).weight(.bold)
        static let title2 = Font.custom(primaryFont, size: FontSize.title2, relativeTo: .title2).weight(.bold)
        static let title3 = Font.custom(primaryFont, size: FontSize.title3, relativeTo: .title3).weight(.semibold)
        static let headline = Font.custom(primaryFont, size: FontSize.headline, relativeTo: .headline).weight(.semibold)
        static let body = Font.custom(secondaryFont, size: FontSize.body, relativeTo: .body).weight(.regular)
        static let bodyBold = Font.custom(secondaryFont, size: FontSize.body, relativeTo: .body).weight(.semibold)
        static let callout = Font.custom(secondaryFont, size: FontSize.callout, relativeTo: .callout).weight(.regular)
        static let subheadline = Font.custom(secondaryFont, size: FontSize.subheadline, relativeTo: .subheadline).weight(.regular)
        static let footnote = Font.custom(secondaryFont, size: FontSize.footnote, relativeTo: .footnote).weight(.regular)
        static let caption = Font.custom(secondaryFont, size: FontSize.caption1, relativeTo: .caption).weight(.regular)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
        
        // Semantic Spacing
        static let elementSpacing = md
        static let sectionSpacing = lg
        static let screenPadding = md
        static let cardPadding = md
        static let buttonPadding = sm
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        
        // Semantic Radius
        static let button = sm
        static let card = md
        static let modal = lg
        static let avatar = xl
    }
    
    // MARK: - Shadows
    
    struct Shadow {
        static let small = (color: Color.black.opacity(0.1), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let large = (color: Color.black.opacity(0.2), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let extraLarge = (color: Color.black.opacity(0.25), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
        
        // Semantic Shadows
        static let card = medium
        static let button = small
        static let modal = large
        static let floating = extraLarge
    }
    
    // MARK: - Icons
    
    struct Icons {
        // Navigation
        static let home = "house.fill"
        static let children = "person.2.fill"
        static let calendar = "calendar"
        static let documents = "doc.fill"
        static let settings = "gearshape.fill"
        
        // Actions
        static let add = "plus"
        static let edit = "pencil"
        static let delete = "trash"
        static let save = "checkmark"
        static let cancel = "xmark"
        static let search = "magnifyingglass"
        static let filter = "line.3.horizontal.decrease"
        static let sort = "arrow.up.arrow.down"
        
        // Status
        static let success = "checkmark.circle.fill"
        static let warning = "exclamationmark.triangle.fill"
        static let error = "xmark.circle.fill"
        static let info = "info.circle.fill"
        
        // Gender
        static let male = "figure.child"
        static let female = "figure.child"
        static let other = "person"
        
        // Age Categories
        static let baby = "figure.child.circle"
        static let toddler = "figure.walk"
        static let preschool = "figure.run"
        static let school = "backpack"
        static let teen = "figure.wave"
        
        // Events
        static let appointment = "calendar.badge.clock"
        static let vaccination = "cross.case.fill"
        static let milestone = "star.fill"
        static let reminder = "bell.fill"
        
        // Family
        static let family = "person.3.fill"
        static let parent = "person.fill"
        static let child = "figure.child"
        static let invite = "person.badge.plus"
    }
    
    // MARK: - Animations
    
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
    }
    
    // MARK: - Layout
    
    struct Layout {
        // Screen Dimensions
        static let minTouchTarget: CGFloat = 44
        static let maxContentWidth: CGFloat = 600
        
        // Grid
        static let gridSpacing: CGFloat = Spacing.md
        static let gridColumns = 2
        
        // Cards
        static let cardMinHeight: CGFloat = 120
        static let cardMaxHeight: CGFloat = 200
        
        // Lists
        static let listRowHeight: CGFloat = 60
        static let listSectionSpacing: CGFloat = Spacing.lg
    }
}

// MARK: - Theme Extensions

extension Color {
    // Convenience initializers for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension View {
    // Theme-aware modifiers
    func themedCard() -> some View {
        self
            .background(AppTheme.Colors.surface)
            .cornerRadius(AppTheme.CornerRadius.card)
            .shadow(
                color: AppTheme.Shadow.card.color,
                radius: AppTheme.Shadow.card.radius,
                x: AppTheme.Shadow.card.x,
                y: AppTheme.Shadow.card.y
            )
    }
    
    func themedButton(style: ButtonStyle = .primary) -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(style.backgroundColor)
            .foregroundColor(style.textColor)
            .cornerRadius(AppTheme.CornerRadius.button)
            .shadow(
                color: AppTheme.Shadow.button.color,
                radius: AppTheme.Shadow.button.radius,
                x: AppTheme.Shadow.button.x,
                y: AppTheme.Shadow.button.y
            )
    }
    
    func themedSection() -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.screenPadding)
            .padding(.vertical, AppTheme.Spacing.sectionSpacing)
    }
}

// MARK: - Button Styles

enum ButtonStyle {
    case primary
    case secondary
    case tertiary
    case destructive
    case success
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return AppTheme.Colors.primary
        case .secondary:
            return AppTheme.Colors.secondary
        case .tertiary:
            return AppTheme.Colors.surface
        case .destructive:
            return AppTheme.Colors.error
        case .success:
            return AppTheme.Colors.success
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary, .secondary, .destructive, .success:
            return Color.white
        case .tertiary:
            return AppTheme.Colors.textPrimary
        }
    }
}

// MARK: - Theme Preview

#if DEBUG
struct ThemePreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Colors
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Colors")
                        .font(AppTheme.Typography.title2)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: AppTheme.Spacing.sm) {
                        ColorSwatch("Primary", AppTheme.Colors.primary)
                        ColorSwatch("Secondary", AppTheme.Colors.secondary)
                        ColorSwatch("Accent", AppTheme.Colors.accent)
                        ColorSwatch("Success", AppTheme.Colors.success)
                        ColorSwatch("Warning", AppTheme.Colors.warning)
                        ColorSwatch("Error", AppTheme.Colors.error)
                    }
                }
                
                // Typography
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Typography")
                        .font(AppTheme.Typography.title2)
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("Large Title").font(AppTheme.Typography.largeTitle)
                        Text("Title 1").font(AppTheme.Typography.title1)
                        Text("Title 2").font(AppTheme.Typography.title2)
                        Text("Headline").font(AppTheme.Typography.headline)
                        Text("Body").font(AppTheme.Typography.body)
                        Text("Caption").font(AppTheme.Typography.caption)
                    }
                }
                
                // Buttons
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Buttons")
                        .font(AppTheme.Typography.title2)
                    
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("Primary").themedButton(style: .primary)
                        Text("Secondary").themedButton(style: .secondary)
                        Text("Tertiary").themedButton(style: .tertiary)
                        Text("Destructive").themedButton(style: .destructive)
                    }
                }
            }
            .themedSection()
        }
        .background(AppTheme.Colors.background)
    }
}

struct ColorSwatch: View {
    let name: String
    let color: Color
    
    init(_ name: String, _ color: Color) {
        self.name = name
        self.color = color
    }
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(height: 60)
                .cornerRadius(AppTheme.CornerRadius.sm)
            
            Text(name)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
}

struct ThemePreview_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreview()
    }
}
#endif