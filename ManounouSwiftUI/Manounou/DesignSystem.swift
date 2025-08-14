//
//  DesignSystem.swift
//  Manounou
//
//  Created by Assistant on 2025-01-14.
//  Système de design basé sur la charte graphique Manounou
//

import SwiftUI

// MARK: - Design System Colors
struct ManounouColors {
    // Couleur principale
    static let primary = Color(hex: "#6C63FF")
    
    // Couleurs de fond
    static let background = Color(hex: "#F6F6FA")
    static let surface = Color.white
    
    // Couleurs de texte
    static let textPrimary = Color(hex: "#202124")
    static let textSecondary = Color.secondary
    
    // Couleurs de bordure
    static let border = Color(hex: "#E7E7EF")
    
    // Couleurs fonctionnelles
    static let success = Color(hex: "#10B981")
    static let warning = Color(hex: "#F59E0B")
    static let error = Color(hex: "#EF4444")
    static let info = Color(hex: "#3B82F6")
    
    // Couleurs thématiques enfants
    static let childYellow = Color(hex: "#FEF3C7")
    static let childBlue = Color(hex: "#DBEAFE")
    static let heart = Color(hex: "#EF4444")
}

// MARK: - Design System Typography
struct ManounouTypography {
    // Tailles de police
    static let xs: Font = .system(size: 12)
    static let sm: Font = .system(size: 14)
    static let base: Font = .system(size: 16)
    static let lg: Font = .system(size: 18)
    static let xl: Font = .system(size: 20)
    static let xxl: Font = .system(size: 24)
    static let xxxl: Font = .system(size: 30)
    static let hero: Font = .system(size: 36)
    
    // Poids de police
    static func normal(_ size: Font) -> Font {
        size.weight(.regular)
    }
    
    static func medium(_ size: Font) -> Font {
        size.weight(.medium)
    }
    
    static func semibold(_ size: Font) -> Font {
        size.weight(.semibold)
    }
    
    static func bold(_ size: Font) -> Font {
        size.weight(.bold)
    }
}

// MARK: - Design System Spacing
struct ManounouSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Design System Border Radius
struct ManounouRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let full: CGFloat = 9999
}

// MARK: - Design System Shadows
struct ManounouShadows {
    static let low = Color.black.opacity(0.1)
    static let medium = Color.black.opacity(0.1)
    static let high = Color.black.opacity(0.1)
}

// MARK: - Manounou Logo Component
struct ManounouLogo: View {
    let size: CGFloat
    
    init(size: CGFloat = 80) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Cercle de fond
            Circle()
                .fill(ManounouColors.primary.opacity(0.1))
                .frame(width: size * 0.8, height: size * 0.8)
            
            // Icône maison avec cœur
            VStack(spacing: 2) {
                // Maison
                Image(systemName: "house.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(ManounouColors.primary)
                
                // Cœur
                Image(systemName: "heart.fill")
                    .font(.system(size: size * 0.2))
                    .foregroundColor(ManounouColors.heart)
                    .offset(y: -size * 0.1)
            }
        }
    }
}

// MARK: - Manounou Button Styles
struct ManounouPrimaryButtonStyle: ButtonStyle {
    let isDisabled: Bool
    
    init(isDisabled: Bool = false) {
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ManounouTypography.semibold(ManounouTypography.base))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                isDisabled ? Color.gray : 
                (configuration.isPressed ? ManounouColors.primary.opacity(0.8) : ManounouColors.primary)
            )
            .cornerRadius(ManounouRadius.sm)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ManounouSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ManounouTypography.semibold(ManounouTypography.base))
            .foregroundColor(ManounouColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: ManounouRadius.sm)
                    .stroke(ManounouColors.primary, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ManounouTertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ManounouTypography.semibold(ManounouTypography.base))
            .foregroundColor(ManounouColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.clear)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Manounou Card Style
struct ManounouCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(ManounouSpacing.lg)
            .background(ManounouColors.surface)
            .cornerRadius(ManounouRadius.md)
            .shadow(color: ManounouShadows.low, radius: 3, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: ManounouRadius.md)
                    .stroke(ManounouColors.border, lineWidth: 1)
            )
    }
}

// MARK: - Manounou Text Field Style
struct ManounouTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(ManounouTypography.base)
            .foregroundColor(ManounouColors.textPrimary)
            .padding(ManounouSpacing.md)
            .background(ManounouColors.surface)
            .cornerRadius(ManounouRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: ManounouRadius.sm)
                    .stroke(ManounouColors.border, lineWidth: 1)
            )
    }
}

// MARK: - Manounou Input Field Component
struct ManounouTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: ManounouSpacing.sm) {
            HStack {
                Text(title)
                    .font(ManounouTypography.medium(ManounouTypography.sm))
                    .foregroundColor(ManounouColors.textSecondary)
                
                if isRequired {
                    Text("*")
                        .font(ManounouTypography.medium(ManounouTypography.sm))
                        .foregroundColor(ManounouColors.error)
                }
            }
            
            TextField("", text: $text)
                .textFieldStyle(ManounouTextFieldStyle())
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
}

// MARK: - Manounou Secure Field Component
struct ManounouSecureField: View {
    let title: String
    @Binding var text: String
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: ManounouSpacing.sm) {
            HStack {
                Text(title)
                    .font(ManounouTypography.medium(ManounouTypography.sm))
                    .foregroundColor(ManounouColors.textSecondary)
                
                if isRequired {
                    Text("*")
                        .font(ManounouTypography.medium(ManounouTypography.sm))
                        .foregroundColor(ManounouColors.error)
                }
            }
            
            SecureField("", text: $text)
                .font(ManounouTypography.base)
                .foregroundColor(ManounouColors.textPrimary)
                .padding(ManounouSpacing.md)
                .background(ManounouColors.surface)
                .cornerRadius(ManounouRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: ManounouRadius.sm)
                        .stroke(ManounouColors.border, lineWidth: 1)
                )
        }
    }
}

// MARK: - Manounou Quick Action Card
struct ManounouQuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ManounouSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(title)
                    .font(ManounouTypography.medium(ManounouTypography.xs))
                    .foregroundColor(ManounouColors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(ManounouColors.background)
            .cornerRadius(ManounouRadius.lg)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Color Extension for Hex
extension Color {
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

// MARK: - Preview
#Preview {
    VStack(spacing: ManounouSpacing.lg) {
        ManounouLogo()
        
        Text("Manounou")
            .font(ManounouTypography.bold(ManounouTypography.hero))
            .foregroundColor(ManounouColors.textPrimary)
        
        Text("Simplifiez la garde")
            .font(ManounouTypography.medium(ManounouTypography.lg))
            .foregroundColor(ManounouColors.primary)
        
        ManounouCard {
            VStack(spacing: ManounouSpacing.md) {
                ManounouTextField(title: "Email", text: .constant(""), isRequired: true)
                ManounouSecureField(title: "Mot de passe", text: .constant(""), isRequired: true)
                
                Button("Se connecter") {}
                    .buttonStyle(ManounouPrimaryButtonStyle())
                
                Button("S'inscrire") {}
                    .buttonStyle(ManounouSecondaryButtonStyle())
            }
        }
        
        HStack(spacing: ManounouSpacing.md) {
            ManounouQuickActionCard(
                title: "Ajouter un enfant",
                icon: "person.badge.plus",
                color: ManounouColors.primary
            ) {}
            
            ManounouQuickActionCard(
                title: "Nouvel événement",
                icon: "calendar.badge.plus",
                color: ManounouColors.success
            ) {}
        }
    }
    .padding(ManounouSpacing.lg)
    .background(ManounouColors.background)
}