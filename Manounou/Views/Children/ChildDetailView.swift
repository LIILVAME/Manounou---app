//
//  ChildDetailView.swift
//  Manounou
//
//  Created by Assistant on 18/08/2025.
//  Page dédiée aux informations détaillées des enfants
//

import SwiftUI

struct ChildDetailView: View {
    let child: Child
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditChild = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        // Header avec photo de profil
                        profileHeader(geometry: geometry)
                        
                        // Informations principales
                        mainInformation(geometry: geometry)
                        
                        // Informations détaillées
                        detailedInformation(geometry: geometry)
                        
                        // Notes
                        if let notes = child.notes, !notes.isEmpty {
                            notesSection(notes: notes, geometry: geometry)
                        }
                        
                        // Statistiques
                        statisticsSection(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.02)
                }
            }
            .navigationTitle("Détails de l'enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Modifier") {
                        showingEditChild = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditChild) {
            EditChildView(child: child)
        }
    }
    
    // MARK: - Profile Header
    
    private func profileHeader(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            // Photo de profil
            ZStack {
                Circle()
                    .fill(child.gender.color.opacity(0.2))
                    .frame(width: geometry.size.width * 0.3, height: geometry.size.width * 0.3)
                
                if let profileImageURL = child.profileImageURL, !profileImageURL.isEmpty {
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: child.gender.icon)
                            .font(.system(size: geometry.size.width * 0.08))
                            .foregroundColor(child.gender.color)
                    }
                    .frame(width: geometry.size.width * 0.3, height: geometry.size.width * 0.3)
                    .clipShape(Circle())
                } else {
                    Text(child.initials)
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(child.gender.color)
                }
            }
            
            // Nom complet
            Text(child.fullName)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Âge formaté selon la demande
            Text(child.formattedAge)
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(child.gender.color.opacity(0.1))
                )
        }
    }
    
    // MARK: - Main Information
    
    private func mainInformation(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            Text("Informations principales")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: geometry.size.height * 0.01) {
                informationRow(
                    icon: "calendar",
                    title: "Date de naissance",
                    value: child.birthDateText,
                    color: .blue,
                    geometry: geometry
                )
                
                informationRow(
                    icon: child.gender.icon,
                    title: "Genre",
                    value: child.gender.displayName,
                    color: child.gender.color,
                    geometry: geometry
                )
                
                informationRow(
                    icon: child.ageCategory.icon,
                    title: "Catégorie d'âge",
                    value: child.ageCategory.displayName,
                    color: child.ageCategory.color,
                    geometry: geometry
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Detailed Information
    
    private func detailedInformation(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            Text("Informations détaillées")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: geometry.size.height * 0.01) {
                informationRow(
                    icon: "number",
                    title: "Âge en années",
                    value: "\(child.ageInYears) an\(child.ageInYears > 1 ? "s" : "")",
                    color: .orange,
                    geometry: geometry
                )
                
                informationRow(
                    icon: "calendar.badge.clock",
                    title: "Âge en mois",
                    value: "\(child.ageInMonths) mois",
                    color: .green,
                    geometry: geometry
                )
                
                informationRow(
                    icon: "clock",
                    title: "Créé le",
                    value: DateFormatters.mediumDateFormatter.string(from: child.createdAt),
                    color: .purple,
                    geometry: geometry
                )
                
                informationRow(
                    icon: "pencil.circle",
                    title: "Modifié le",
                    value: DateFormatters.mediumDateFormatter.string(from: child.updatedAt),
                    color: .indigo,
                    geometry: geometry
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Notes Section
    
    private func notesSection(notes: String, geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            Text("Notes")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.yellow)
                        .frame(width: 24)
                    
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Statistics Section
    
    private func statisticsSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            Text("Statistiques")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: geometry.size.height * 0.015) {
                statisticCard(
                    title: "Jours de vie",
                    value: "\(daysSinceBirth)",
                    icon: "sun.max",
                    color: .orange,
                    geometry: geometry
                )
                
                statisticCard(
                    title: "Semaines de vie",
                    value: "\(weeksSinceBirth)",
                    icon: "calendar.badge.plus",
                    color: .blue,
                    geometry: geometry
                )
                
                statisticCard(
                    title: "Mois de vie",
                    value: "\(monthsSinceBirth)",
                    icon: "calendar",
                    color: .green,
                    geometry: geometry
                )
                
                statisticCard(
                    title: "Prochaine année",
                    value: daysUntilNextBirthday,
                    icon: "gift",
                    color: .pink,
                    geometry: geometry
                )
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func informationRow(
        icon: String,
        title: String,
        value: String,
        color: Color,
        geometry: GeometryProxy
    ) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
    
    private func statisticCard(
        title: String,
        value: String,
        icon: String,
        color: Color,
        geometry: GeometryProxy
    ) -> some View {
        VStack(spacing: geometry.size.height * 0.01) {
            Image(systemName: icon)
                .font(.system(size: geometry.size.width * 0.06))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
    
    // MARK: - Computed Properties
    
    private var daysSinceBirth: Int {
        Calendar.current.dateComponents([.day], from: child.birthDate, to: Date()).day ?? 0
    }
    
    private var weeksSinceBirth: Int {
        daysSinceBirth / 7
    }
    
    private var monthsSinceBirth: Int {
        Calendar.current.dateComponents([.month], from: child.birthDate, to: Date()).month ?? 0
    }
    
    private var daysUntilNextBirthday: String {
        let calendar = Calendar.current
        let today = Date()
        
        // Calculer le prochain anniversaire
        var nextBirthday = calendar.dateComponents([.month, .day], from: child.birthDate)
        nextBirthday.year = calendar.component(.year, from: today)
        
        guard let nextBirthdayDate = calendar.date(from: nextBirthday) else {
            return "N/A"
        }
        
        // Si l'anniversaire est déjà passé cette année, prendre l'année suivante
        let finalBirthdayDate = nextBirthdayDate < today ?
            calendar.date(byAdding: .year, value: 1, to: nextBirthdayDate) ?? nextBirthdayDate :
            nextBirthdayDate
        
        let days = calendar.dateComponents([.day], from: today, to: finalBirthdayDate).day ?? 0
        return "\(days) jours"
    }
}

// MARK: - Preview

#if DEBUG
struct ChildDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ChildDetailView(child: Child.sampleChildren[0])
    }
}
#endif