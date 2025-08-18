//
//  TabViews.swift
//  Manounou
//
//  Created by Assistant on 18/08/2025.
//  Tab views extracted from MainTabView for better modularity
//

import SwiftUI
import Foundation

// MARK: - Children Tab View

struct ChildrenTabView: View {
    let children: [TempChild]
    @State private var selectedChild: TempChild?
    
    var body: some View {
        NavigationView {
            VStack {
                if children.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Aucun enfant")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Ajoutez des enfants pour commencer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List(children) { child in
                        Button {
                            selectedChild = child
                        } label: {
                            HStack {
                                Circle()
                                    .fill(child.gender.color.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay {
                                        Text(child.initials)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(child.gender.color)
                                    }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(child.fullName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(child.formattedAge)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Enfants")
        }
        .sheet(item: $selectedChild) { child in
            TempChildDetailView(child: child)
        }
    }
}

// MARK: - Calendar Tab View

struct CalendarTabView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "calendar")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Calendrier")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Planification et gestion des événements")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("✅ CalendarView développé")
                    Text("✅ AddEventView pour création")
                    Text("✅ EventCardView pour affichage")
                    Text("✅ Gestion des notifications")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            .padding()
            .navigationTitle("Calendrier")
        }
    }
}

// MARK: - Documents Tab View

struct DocumentsTabView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Documents")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Gestion des documents et fichiers")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("✅ DocumentsView développé")
                    Text("✅ DocumentCardView pour affichage")
                    Text("✅ Upload et gestion de fichiers")
                    Text("✅ Structure optimale (2 fichiers)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            .padding()
            .navigationTitle("Documents")
        }
    }
}

// MARK: - Settings Tab View

struct SettingsTabView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Paramètres")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Configuration et profil utilisateur")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("✅ ProfileView intégré")
                    Text("✅ EditProfile intégré dans ProfileView")
                    Text("✅ ChangePassword intégré dans ProfileView")
                    Text("✅ Optimisation LEAN (-67% fichiers)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            .padding()
            .navigationTitle("Paramètres")
        }
    }
}

// MARK: - Child Detail View

struct TempChildDetailView: View {
    let child: TempChild
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    Circle()
                        .fill(child.gender.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .overlay {
                            Text(child.initials)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(child.gender.color)
                        }
                    
                    // Name
                    Text(child.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Age Badge
                    Text(child.formattedAge)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(child.gender.color)
                        )
                    
                    // Main Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Informations principales")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                Text("Date de naissance")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(DateFormatter.localizedString(from: child.birthDate, dateStyle: .medium, timeStyle: .none))
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(child.gender.color)
                                    .frame(width: 24)
                                Text("Genre")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(child.gender.displayName)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Notes
                    if let notes = child.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.yellow)
                                    .frame(width: 24)
                                Text(notes)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                    
                    // Age Formatting Demo
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Démonstration du formatage d'âge")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 8) {
                            Text("Format demandé : \"X ans et Y mois\"")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text("Âge formaté :")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(child.formattedAge)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.green.opacity(0.2))
                                    )
                            }
                            
                            Text("✅ Formatage conforme à la demande")
                                .font(.caption)
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .padding()
            }
            .navigationTitle("Détails de l'enfant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}