//
//  HomeComponents.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

// MARK: - Welcome Header Component
struct WelcomeHeaderView: View {
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Utilisateur")
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.system(size: geometry.size.width * 0.06))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.vertical, geometry.size.height * 0.02)
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Bonjour"
        case 12..<17:
            return "Bon après-midi"
        case 17..<22:
            return "Bonsoir"
        default:
            return "Bonne nuit"
        }
    }
}

// MARK: - Quick Stats Component
struct QuickStatsView: View {
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
            Text("Aperçu rapide")
                .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: geometry.size.width * 0.04) {
                StatCardView(
                    title: "Enfants",
                    value: "2",
                    icon: "person.2.fill",
                    color: .green,
                    geometry: geometry
                )
                
                StatCardView(
                    title: "Événements",
                    value: "5",
                    icon: "calendar",
                    color: .orange,
                    geometry: geometry
                )
                
                StatCardView(
                    title: "Documents",
                    value: "12",
                    icon: "doc.fill",
                    color: .purple,
                    geometry: geometry
                )
            }
        }
    }
}

// MARK: - Stat Card Component
struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: geometry.size.height * 0.01) {
            Image(systemName: icon)
                .font(.system(size: geometry.size.width * 0.06))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, geometry.size.height * 0.02)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Quick Actions Component
struct QuickActionsView: View {
    let geometry: GeometryProxy
    let onAddChild: () -> Void
    let onAddEvent: () -> Void
    let onAddDocument: () -> Void
    let onSettings: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
            Text("Actions rapides")
                .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: geometry.size.width * 0.03), count: 2), spacing: geometry.size.height * 0.015) {
                ActionButtonView(
                    title: "Ajouter enfant",
                    icon: "person.badge.plus",
                    color: .green,
                    geometry: geometry,
                    action: onAddChild
                )
                
                ActionButtonView(
                    title: "Nouvel événement",
                    icon: "calendar.badge.plus",
                    color: .orange,
                    geometry: geometry,
                    action: onAddEvent
                )
                
                ActionButtonView(
                    title: "Ajouter document",
                    icon: "doc.badge.plus",
                    color: .purple,
                    geometry: geometry,
                    action: onAddDocument
                )
                
                ActionButtonView(
                    title: "Paramètres",
                    icon: "gearshape.fill",
                    color: .blue,
                    geometry: geometry,
                    action: onSettings
                )
            }
        }
    }
}

// MARK: - Action Button Component
struct ActionButtonView: View {
    let title: String
    let icon: String
    let color: Color
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: geometry.size.height * 0.01) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.06))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, geometry.size.height * 0.02)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recent Activity Component
struct RecentActivityView: View {
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
            Text("Activité récente")
                .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: geometry.size.height * 0.01) {
                ActivityItemView(
                    icon: "person.badge.plus",
                    title: "Enfant ajouté",
                    subtitle: "Emma Martin - Il y a 2 heures",
                    color: .green
                )
                
                ActivityItemView(
                    icon: "calendar.badge.plus",
                    title: "Événement créé",
                    subtitle: "Rendez-vous médecin - Demain 14h",
                    color: .orange
                )
                
                ActivityItemView(
                    icon: "doc.badge.plus",
                    title: "Document ajouté",
                    subtitle: "Certificat médical - Hier",
                    color: .purple
                )
            }
        }
    }
}

// MARK: - Activity Item Component
struct ActivityItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}