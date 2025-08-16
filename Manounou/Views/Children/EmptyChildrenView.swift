//
//  EmptyChildrenView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

struct EmptyChildrenView: View {
    let geometry: GeometryProxy
    let onAddChild: () -> Void
    
    var body: some View {
        VStack(spacing: geometry.size.height * 0.04) {
            Spacer()
            
            // Illustration
            familyIllustration
            
            // Main message
            VStack(spacing: geometry.size.height * 0.015) {
                Text("Commencez votre carnet de famille")
                    .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Ajoutez les informations de vos enfants pour créer un espace familial personnalisé")
                    .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, geometry.size.width * 0.08)
            
            // Benefits list
            benefitsList
            
            // Call to action button
            ctaButton
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.blue.opacity(0.02)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Family Illustration
    private var familyIllustration: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.1),
                            Color.green.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(
                    width: geometry.size.width * 0.3,
                    height: geometry.size.width * 0.3
                )
            
            // Family icon
            Image(systemName: "figure.2.and.child.holdinghands")
                .font(.system(size: geometry.size.width * 0.12, weight: .light))
                .foregroundColor(.blue)
        }
        .scaleEffect(1.0)
        .animation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true),
            value: UUID()
        )
    }
    
    // MARK: - Benefits List
    private var benefitsList: some View {
        VStack(spacing: geometry.size.height * 0.02) {
            benefitItem(
                icon: "calendar.badge.plus",
                title: "Suivez les événements",
                description: "Gardez une trace des moments importants",
                color: .orange
            )
            
            benefitItem(
                icon: "doc.text",
                title: "Organisez les documents",
                description: "Centralisez tous les documents importants",
                color: .green
            )
            
            benefitItem(
                icon: "person.2.fill",
                title: "Partagez en famille",
                description: "Invitez la famille à participer",
                color: .purple
            )
        }
        .padding(.horizontal, geometry.size.width * 0.06)
    }
    
    private func benefitItem(
        icon: String,
        title: String,
        description: String,
        color: Color
    ) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                .foregroundColor(color)
                .frame(
                    width: geometry.size.width * 0.1,
                    height: geometry.size.width * 0.1
                )
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
            
            // Text content
            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                Text(title)
                    .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: geometry.size.width * 0.035, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
    
    // MARK: - CTA Button
    private var ctaButton: some View {
        Button(action: onAddChild) {
            HStack(spacing: geometry.size.width * 0.03) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Ajouter votre premier enfant")
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height * 0.07)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(geometry.size.width * 0.04)
            .shadow(
                color: Color.blue.opacity(0.3),
                radius: geometry.size.width * 0.02,
                x: 0,
                y: geometry.size.width * 0.01
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, geometry.size.width * 0.06)
        .scaleEffect(1.0)
        .animation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true),
            value: UUID()
        )
    }
}

// MARK: - Preview
#if DEBUG
struct EmptyChildrenView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            EmptyChildrenView(
                geometry: geometry,
                onAddChild: {
                    print("Add first child tapped")
                }
            )
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Empty Children State")
    }
}
#endif