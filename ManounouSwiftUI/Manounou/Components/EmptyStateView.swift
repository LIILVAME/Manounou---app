//
//  EmptyStateView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

/// Composant réutilisable pour afficher les états vides
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        iconColor: Color = .gray,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(iconColor)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        )
                }
                .padding(.top, 8)
            }
        }
        .padding(.top, 40)
    }
}

// MARK: - Présets pour les différents états vides

extension EmptyStateView {
    
    /// État vide pour les événements
    static func events(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "calendar",
            title: "Aucun événement",
            subtitle: "Ajoutez votre premier événement pour commencer à organiser votre planning",
            iconColor: .blue.opacity(0.6),
            actionTitle: action != nil ? "Ajouter un événement" : nil,
            action: action
        )
    }
    
    /// État vide pour les enfants
    static func children(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "person.2",
            title: "Aucun enfant",
            subtitle: "Ajoutez les informations de vos enfants pour personnaliser l'application",
            iconColor: .green.opacity(0.6),
            actionTitle: action != nil ? "Ajouter un enfant" : nil,
            action: action
        )
    }
    
    /// État vide pour les documents
    static func documents(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "doc",
            title: "Aucun document",
            subtitle: "Organisez vos documents importants en les ajoutant ici",
            iconColor: .orange.opacity(0.6),
            actionTitle: action != nil ? "Ajouter un document" : nil,
            action: action
        )
    }
    
    /// État vide pour une journée sans événements
    static func dayEvents() -> EmptyStateView {
        EmptyStateView(
            icon: "calendar",
            title: "Aucun événement aujourd'hui",
            subtitle: "Profitez de cette journée libre !",
            iconColor: .gray
        )
    }
    
    /// État vide pour l'agenda
    static func agenda(action: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "calendar",
            title: "Aucun événement planifié",
            subtitle: "Ajoutez votre premier événement pour commencer",
            iconColor: .gray,
            actionTitle: action != nil ? "Ajouter un événement" : nil,
            action: action
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        EmptyStateView.events(action: {})
        EmptyStateView.children()
        EmptyStateView.documents(action: {})
    }
    .padding()
}