//
//  MainTabView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
            
            ChildrenView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Enfants")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendrier")
                }
            
            DocumentsView()
                .tabItem {
                    Image(systemName: "doc.fill")
                    Text("Documents")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Paramètres")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - Temporary Basic Views
// Note : `HomeView` est désormais le véritable écran d'accueil défini dans
// Views/Home/HomeView.swift (câblé au target). Le placeholder a été retiré
// pour lever le conflit de symbole.

struct ChildrenView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Enfants")
                    .font(.largeTitle)
                    .padding()
                Text("Gérez vos enfants ici")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Enfants")
        }
    }
}

struct CalendarView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Calendrier")
                    .font(.largeTitle)
                    .padding()
                Text("Planifiez vos événements")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Calendrier")
        }
    }
}

struct DocumentsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Documents")
                    .font(.largeTitle)
                    .padding()
                Text("Gérez vos documents")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Documents")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Paramètres")
                    .font(.largeTitle)
                    .padding()
                Text("Configurez l'application")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Paramètres")
        }
    }
}

// MARK: - Preview
#Preview {
    let container = AppContainer.createForTesting()
    return MainTabView()
        .environmentObject(container.authViewModel)
        .environmentObject(container.childrenViewModel)
        .environmentObject(container.eventsViewModel)
        .environmentObject(container.documentsViewModel)
}
