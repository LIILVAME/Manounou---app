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
struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Accueil")
                    .font(.largeTitle)
                    .padding()
                Text("Bienvenue dans Manounou")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Accueil")
        }
    }
}

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
    MainTabView()
        .environmentObject(AuthViewModel(authService: MockAuthService()))
}
