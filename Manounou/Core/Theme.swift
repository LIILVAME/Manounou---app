// Theme.swift — Manounou Design System
// Brand: #FA4270 rose · SF Rounded · paper background #F4F2EC

import SwiftUI

// MARK: - App Theme

struct AppTheme {

    // MARK: - Colors
    struct Colors {
        // Brand
        static let brand       = Color(hex: "FA4270")
        static let brandLight  = Color(hex: "FA4270").opacity(0.12)
        static let brandGhost  = Color(hex: "FA4270").opacity(0.08)
        static let brandShadow = Color(hex: "FA4270").opacity(0.28)

        // Semantic palette
        static let green    = Color(hex: "1FA87A")
        static let greenBg  = Color(hex: "1FA87A").opacity(0.10)
        static let blue     = Color(hex: "2E7BEE")
        static let blueBg   = Color(hex: "2E7BEE").opacity(0.10)
        static let purple   = Color(hex: "7A5AE0")
        static let purpleBg = Color(hex: "7A5AE0").opacity(0.10)
        static let orange   = Color(hex: "FF8A3D")
        static let orangeBg = Color(hex: "FF8A3D").opacity(0.10)
        static let amber    = Color(hex: "E0A300")
        static let amberBg  = Color(hex: "E0A300").opacity(0.10)
        static let red      = Color(hex: "FF3B30")
        static let redBg    = Color(hex: "FF3B30").opacity(0.10)

        // Surfaces
        static let paper      = Color(hex: "F4F2EC")
        static let surface    = Color.white
        static let surfaceAlt = Color(red: 0.96, green: 0.96, blue: 0.97)

        // Text
        static let ink        = Color(hex: "1C1C1E")
        static let muted      = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.55)
        static let mutedHeavy = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.70)

        // Borders & dividers
        static let border  = Color.black.opacity(0.08)
        static let divider = Color.black.opacity(0.06)

        // ── Legacy aliases (keep existing views compiling) ──
        static let primary          = brand
        static let primaryLight     = brandLight
        static let primaryDark      = Color(hex: "D4305A")
        static let secondary        = orange
        static let secondaryLight   = orangeBg
        static let secondaryDark    = Color(hex: "CC6B28")
        static let accent           = brand
        static let accentLight      = brandLight
        static let accentDark       = Color(hex: "D4305A")
        static let success          = green
        static let warning          = amber
        static let error            = red
        static let info             = blue
        static let background       = paper
        static let textPrimary      = ink
        static let textSecondary    = muted
        static let textTertiary     = Color(red: 60/255, green: 60/255, blue: 67/255).opacity(0.40)
        static let textOnPrimary    = Color.white
        static let textOnSecondary  = Color.white
        static let borderLight      = Color.black.opacity(0.06)
        static let borderDark       = Color.black.opacity(0.15)
        static let surfaceSecondary = surfaceAlt

        // Gender
        static let genderMale   = blue
        static let genderFemale = brand
        static let genderOther  = purple

        // Age category
        static let ageBaby      = Color.mint
        static let ageToddler   = green
        static let agePreschool = orange
        static let ageSchool    = blue
        static let ageTeen      = purple

        // Status
        static let statusActive    = green
        static let statusInactive  = Color.gray
        static let statusPending   = amber
        static let statusCompleted = blue
    }

    // MARK: - Typography  (SF Rounded — built-in, matches Baloo 2 spirit)
    struct Typography {
        static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .rounded)
        }

        static let display    = Font.system(size: 32, weight: .bold,     design: .rounded)
        static let largeTitle = Font.system(size: 30, weight: .bold,     design: .rounded)
        static let title1     = Font.system(size: 26, weight: .bold,     design: .rounded)
        static let title2     = Font.system(size: 22, weight: .bold,     design: .rounded)
        static let title3     = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let headline   = Font.system(size: 16, weight: .semibold, design: .rounded)
        static let body       = Font.system(size: 15, weight: .regular,  design: .rounded)
        static let bodyMedium = Font.system(size: 15, weight: .semibold, design: .rounded)
        static let bodyBold   = Font.system(size: 15, weight: .bold,     design: .rounded)
        static let callout    = Font.system(size: 14, weight: .regular,  design: .rounded)
        static let subheadline = Font.system(size: 14, weight: .semibold, design: .rounded)
        static let footnote   = Font.system(size: 13, weight: .semibold, design: .rounded)
        static let caption    = Font.system(size: 12, weight: .semibold, design: .rounded)
        static let caption2   = Font.system(size: 11, weight: .semibold, design: .rounded)

        // Legacy aliases
        static let primaryFont   = "SF Pro Rounded"
        static let secondaryFont = "SF Pro Text"
        static let monoFont      = "SF Mono"

        struct FontSize {
            static let largeTitle: CGFloat = 30
            static let title1: CGFloat = 26
            static let title2: CGFloat = 22
            static let title3: CGFloat = 18
            static let headline: CGFloat = 16
            static let body: CGFloat = 15
            static let callout: CGFloat = 14
            static let subheadline: CGFloat = 14
            static let footnote: CGFloat = 13
            static let caption1: CGFloat = 12
            static let caption2: CGFloat = 11
        }

        struct FontWeight {
            static let ultraLight = Font.Weight.ultraLight
            static let thin       = Font.Weight.thin
            static let light      = Font.Weight.light
            static let regular    = Font.Weight.regular
            static let medium     = Font.Weight.medium
            static let semibold   = Font.Weight.semibold
            static let bold       = Font.Weight.bold
            static let heavy      = Font.Weight.heavy
            static let black      = Font.Weight.black
        }
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs:    CGFloat = 4
        static let sm:    CGFloat = 8
        static let md:    CGFloat = 16
        static let lg:    CGFloat = 24
        static let xl:    CGFloat = 32
        static let xxl:   CGFloat = 48
        static let xxxl:  CGFloat = 64

        static let elementSpacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 28
        static let screenPadding:  CGFloat = 20
        static let cardPadding:    CGFloat = 16
        static let buttonPadding:  CGFloat = 8
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let xs:   CGFloat = 4
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 14
        static let lg:   CGFloat = 16
        static let xl:   CGFloat = 20
        static let xxl:  CGFloat = 26

        static let button: CGFloat = 14
        static let card:   CGFloat = 16
        static let modal:  CGFloat = 26
        static let avatar: CGFloat = 50
        static let chip:   CGFloat = 20
    }

    // MARK: - Shadows
    struct Shadow {
        static let small      = (color: Color.black.opacity(0.08),  radius: CGFloat(4),  x: CGFloat(0), y: CGFloat(2))
        static let medium     = (color: Color.black.opacity(0.10),  radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
        static let large      = (color: Color.black.opacity(0.16),  radius: CGFloat(24), x: CGFloat(0), y: CGFloat(8))
        static let extraLarge = (color: Color.black.opacity(0.20),  radius: CGFloat(36), x: CGFloat(0), y: CGFloat(12))

        static let card    = (color: Color.black.opacity(0.10), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(6))
        static let button  = small
        static let modal   = large
        static let floating = extraLarge
    }

    // MARK: - Icons
    struct Icons {
        static let home          = "house.fill"
        static let children      = "person.2.fill"
        static let calendar      = "calendar"
        static let planning      = "calendar.badge.clock"
        static let documents     = "doc.fill"
        static let settings      = "gearshape.fill"
        static let messages      = "bubble.left.and.bubble.right.fill"
        static let profile       = "person.crop.circle.fill"
        static let notifications = "bell.fill"

        static let add    = "plus"
        static let edit   = "pencil"
        static let delete = "trash"
        static let save   = "checkmark"
        static let cancel = "xmark"
        static let search = "magnifyingglass"
        static let filter = "line.3.horizontal.decrease"
        static let sort   = "arrow.up.arrow.down"
        static let share  = "square.and.arrow.up"

        static let success = "checkmark.circle.fill"
        static let warning = "exclamationmark.triangle.fill"
        static let error   = "xmark.circle.fill"
        static let info    = "info.circle.fill"

        static let male       = "figure.child"
        static let female     = "figure.child"
        static let other      = "person"
        static let baby       = "figure.child.circle"
        static let toddler    = "figure.walk"
        static let preschool  = "figure.run"
        static let school     = "backpack"
        static let teen       = "figure.wave"

        static let appointment = "calendar.badge.clock"
        static let vaccination = "cross.case.fill"
        static let milestone   = "star.fill"
        static let reminder    = "bell.fill"

        static let family = "person.3.fill"
        static let parent = "person.fill"
        static let child  = "figure.child"
        static let invite = "person.badge.plus"
    }

    // MARK: - Animations
    struct Animation {
        static let quick    = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow     = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring   = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let bouncy   = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
    }

    // MARK: - Layout
    struct Layout {
        static let minTouchTarget:    CGFloat = 44
        static let maxContentWidth:   CGFloat = 600
        static let gridSpacing:       CGFloat = 16
        static let gridColumns               = 2
        static let cardMinHeight:     CGFloat = 120
        static let cardMaxHeight:     CGFloat = 200
        static let listRowHeight:     CGFloat = 60
        static let listSectionSpacing: CGFloat = 28
    }
}

// MARK: - Color hex init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - View modifiers

extension View {
    func themedCard() -> some View {
        self
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
            .shadow(color: AppTheme.Shadow.card.color,
                    radius: AppTheme.Shadow.card.radius,
                    x: AppTheme.Shadow.card.x,
                    y: AppTheme.Shadow.card.y)
    }

    func themedButton(style: ManounouButtonStyle = .primary) -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(style.backgroundColor)
            .foregroundColor(style.textColor)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button))
            .shadow(color: AppTheme.Shadow.button.color,
                    radius: AppTheme.Shadow.button.radius,
                    x: AppTheme.Shadow.button.x,
                    y: AppTheme.Shadow.button.y)
    }

    func themedSection() -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.screenPadding)
            .padding(.vertical, AppTheme.Spacing.sectionSpacing)
    }
}

// MARK: - Button style enum (renamed to avoid conflict with SwiftUI.ButtonStyle)

enum ManounouButtonStyle {
    case primary, secondary, tertiary, destructive, success

    var backgroundColor: Color {
        switch self {
        case .primary:     return AppTheme.Colors.brand
        case .secondary:   return AppTheme.Colors.orange
        case .tertiary:    return AppTheme.Colors.surfaceAlt
        case .destructive: return AppTheme.Colors.red
        case .success:     return AppTheme.Colors.green
        }
    }

    var textColor: Color {
        switch self {
        case .tertiary: return AppTheme.Colors.ink
        default:        return .white
        }
    }
}

// Note: existing views calling .themedButton(style: .primary) still work
// because Swift infers ManounouButtonStyle from the method signature.
