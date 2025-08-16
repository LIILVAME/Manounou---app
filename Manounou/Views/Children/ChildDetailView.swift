//
//  ChildDetailView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

struct ChildDetailView: View {
    let child: Child
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        // Header with photo and basic info
                        headerSection(geometry: geometry)
                        
                        // Information cards
                        informationCards(geometry: geometry)
                        
                        // Notes section
                        if let notes = child.notes, !notes.isEmpty {
                            notesSection(notes: notes, geometry: geometry)
                        }
                        
                        // Action buttons
                        actionButtons(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.02)
                }
            }
            .navigationTitle(child.fullName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Modifier") {
                        showingEditView = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditChildView(child: child)
        }
    }
    
    // MARK: - Header Section
    private func headerSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            // Profile photo
            profilePhoto(geometry: geometry)
            
            // Basic information
            VStack(spacing: geometry.size.height * 0.01) {
                Text(child.fullName)
                    .font(.system(size: geometry.size.width * 0.07, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(child.ageText)
                    .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                    .foregroundColor(.secondary)
                
                // Gender and category badges
                HStack(spacing: geometry.size.width * 0.03) {
                    genderBadge(geometry: geometry)
                    categoryBadge(geometry: geometry)
                }
            }
        }
        .padding(.vertical, geometry.size.height * 0.02)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                .fill(
                    LinearGradient(
                        colors: [
                            child.gender.color.opacity(0.1),
                            child.gender.color.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    private func profilePhoto(geometry: GeometryProxy) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            child.gender.color.opacity(0.3),
                            child.gender.color.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(
                    width: geometry.size.width * 0.25,
                    height: geometry.size.width * 0.25
                )
            
            if let profileImageURL = child.profileImageURL, !profileImageURL.isEmpty {
                AsyncImage(url: URL(string: profileImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    initialsView(geometry: geometry)
                }
                .frame(
                    width: geometry.size.width * 0.25,
                    height: geometry.size.width * 0.25
                )
                .clipShape(Circle())
            } else {
                initialsView(geometry: geometry)
            }
        }
    }
    
    private func initialsView(geometry: GeometryProxy) -> some View {
        Text(child.initials)
            .font(.system(size: geometry.size.width * 0.08, weight: .bold))
            .foregroundColor(child.gender.color)
    }
    
    private func genderBadge(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.02) {
            Image(systemName: child.gender.icon)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(child.gender.color)
            
            Text(child.gender.displayName)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(child.gender.color)
        }
        .padding(.horizontal, geometry.size.width * 0.03)
        .padding(.vertical, geometry.size.height * 0.01)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                .fill(child.gender.color.opacity(0.15))
        )
    }
    
    private func categoryBadge(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.02) {
            Image(systemName: child.ageCategory.icon)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(child.ageCategory.color)
            
            Text(child.ageCategory.displayName)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(child.ageCategory.color)
        }
        .padding(.horizontal, geometry.size.width * 0.03)
        .padding(.vertical, geometry.size.height * 0.01)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                .fill(child.ageCategory.color.opacity(0.15))
        )
    }
    
    // MARK: - Information Cards
    private func informationCards(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            // Birth information
            informationCard(
                title: "Informations de naissance",
                icon: "calendar",
                iconColor: .blue,
                geometry: geometry
            ) {
                VStack(spacing: geometry.size.height * 0.015) {
                    informationRow(
                        label: "Date de naissance",
                        value: child.birthDateText,
                        geometry: geometry
                    )
                    
                    informationRow(
                        label: "Âge exact",
                        value: "\(child.ageInYears) ans et \(child.ageInMonths) mois",
                        geometry: geometry
                    )
                }
            }
            
            // Personal information
            informationCard(
                title: "Informations personnelles",
                icon: "person.circle",
                iconColor: .green,
                geometry: geometry
            ) {
                VStack(spacing: geometry.size.height * 0.015) {
                    informationRow(
                        label: "Prénom",
                        value: child.firstName,
                        geometry: geometry
                    )
                    
                    informationRow(
                        label: "Nom de famille",
                        value: child.lastName,
                        geometry: geometry
                    )
                    
                    informationRow(
                        label: "Genre",
                        value: child.gender.displayName,
                        geometry: geometry
                    )
                }
            }
            
            // Metadata
            informationCard(
                title: "Informations système",
                icon: "info.circle",
                iconColor: .orange,
                geometry: geometry
            ) {
                VStack(spacing: geometry.size.height * 0.015) {
                    informationRow(
                        label: "Créé le",
                        value: DateFormatters.mediumDateFormatter.string(from: child.createdAt),
                        geometry: geometry
                    )
                    
                    informationRow(
                        label: "Modifié le",
                        value: DateFormatters.mediumDateFormatter.string(from: child.updatedAt),
                        geometry: geometry
                    )
                }
            }
        }
    }
    
    private func informationCard<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        geometry: GeometryProxy,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            // Card header
            HStack(spacing: geometry.size.width * 0.03) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Card content
            content()
        }
        .padding(geometry.size.width * 0.04)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: geometry.size.width * 0.01,
                    x: 0,
                    y: geometry.size.width * 0.005
                )
        )
    }
    
    private func informationRow(
        label: String,
        value: String,
        geometry: GeometryProxy
    ) -> some View {
        HStack {
            Text(label)
                .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
    
    // MARK: - Notes Section
    private func notesSection(notes: String, geometry: GeometryProxy) -> some View {
        informationCard(
            title: "Notes",
            icon: "note.text",
            iconColor: .purple,
            geometry: geometry
        ) {
            Text(notes)
                .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Action Buttons
    private func actionButtons(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.02) {
            // Edit button
            Button(action: { showingEditView = true }) {
                HStack(spacing: geometry.size.width * 0.03) {
                    Image(systemName: "pencil")
                        .font(.system(size: geometry.size.width * 0.045, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Modifier les informations")
                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height * 0.06)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(geometry.size.width * 0.03)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Additional actions
            HStack(spacing: geometry.size.width * 0.03) {
                actionButton(
                    title: "Événements",
                    icon: "calendar",
                    color: .orange,
                    geometry: geometry
                ) {
                    // TODO: Navigate to child events
                    print("View events for \(child.fullName)")
                }
                
                actionButton(
                    title: "Documents",
                    icon: "doc",
                    color: .green,
                    geometry: geometry
                ) {
                    // TODO: Navigate to child documents
                    print("View documents for \(child.fullName)")
                }
            }
        }
        .padding(.bottom, geometry.size.height * 0.03)
    }
    
    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        geometry: GeometryProxy,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: geometry.size.height * 0.01) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height * 0.08)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                    .fill(color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Child View Placeholder
struct EditChildView: View {
    let child: Child
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Modification de \(child.fullName)")
                    .font(.title2)
                    .padding()
                
                Text("Formulaire de modification en cours de développement")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Modifier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        dismiss()
                    }
                }
            }
        }
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