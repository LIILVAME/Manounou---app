//
//  TempHomeView.swift
//  Manounou
//
//  Created by Assistant on 18/08/2025.
//  Extracted from MainTabView for better modularity
//

import SwiftUI
import Foundation

struct TempHomeView: View {
    @EnvironmentObject var childrenViewModel: TempChildrenViewModel
    @EnvironmentObject var eventsViewModel: TempEventsViewModel
    @EnvironmentObject var documentsViewModel: TempDocumentsViewModel
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        // Welcome Header
                        welcomeHeader(geometry: geometry)
                        
                        // Quick Stats
                        quickStats(geometry: geometry)
                        
                        // Upcoming Events
                        upcomingEvents(geometry: geometry)
                        
                        // Quick Actions
                        quickActions(geometry: geometry)
                        
                        // Recent Documents
                        recentDocuments(geometry: geometry)
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .padding(.top, geometry.size.height * 0.02)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .refreshable {
            await loadData()
        }
    }
    
    // MARK: - Welcome Header
    private func welcomeHeader(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
            HStack {
                VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                    Text(greetingText)
                        .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Utilisateur")
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Profile Avatar
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * 0.12,
                                height: geometry.size.width * 0.12
                            )
                        
                        Text("US")
                            .font(.system(size: geometry.size.width * 0.05, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text("Voici un aperçu de votre famille")
                .font(.system(size: geometry.size.width * 0.04, weight: .regular))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Quick Stats
    private func quickStats(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            Text("Aperçu")
                .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: geometry.size.width * 0.04) {
                // Children Count
                statCard(
                    title: "Enfants",
                    value: "\(childrenViewModel.children.count)",
                    icon: "person.2.fill",
                    color: .blue,
                    geometry: geometry
                )
                
                // Events Count
                statCard(
                    title: "Événements",
                    value: "\(eventsViewModel.events.count)",
                    icon: "calendar",
                    color: .green,
                    geometry: geometry
                )
                
                // Documents Count
                statCard(
                    title: "Documents",
                    value: "\(documentsViewModel.documents.count)",
                    icon: "doc.fill",
                    color: .purple,
                    geometry: geometry
                )
            }
        }
    }
    
    // MARK: - Stat Card
    private func statCard(
        title: String,
        value: String,
        icon: String,
        color: Color,
        geometry: GeometryProxy
    ) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                Text(value)
                    .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(geometry.size.width * 0.04)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Upcoming Events
    private func upcomingEvents(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            HStack {
                Text("Événements à venir")
                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Voir tout") {}
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            if eventsViewModel.events.isEmpty {
                emptyEventsView(geometry: geometry)
            } else {
                VStack(spacing: geometry.size.height * 0.01) {
                    ForEach(Array(eventsViewModel.events.prefix(3)), id: \.id) { event in
                        eventRow(event: event, geometry: geometry)
                    }
                }
            }
        }
    }
    
    // MARK: - Event Row
    private func eventRow(event: TempEvent, geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            // Event type indicator
            ZStack {
                Circle()
                    .fill(event.eventType.color.opacity(0.2))
                    .frame(
                        width: geometry.size.width * 0.1,
                        height: geometry.size.width * 0.1
                    )
                
                Image(systemName: event.eventType.icon)
                    .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                    .foregroundColor(event.eventType.color)
            }
            
            // Event info
            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                Text(event.title)
                    .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(eventDateText(event.startDate))
                    .font(.system(size: geometry.size.width * 0.035, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Time indicator
            if event.isToday {
                Text("Aujourd'hui")
                    .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                    .foregroundColor(.orange)
                    .padding(.horizontal, geometry.size.width * 0.02)
                    .padding(.vertical, geometry.size.height * 0.005)
                    .background(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.015)
                            .fill(.orange.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, geometry.size.height * 0.01)
        .padding(.horizontal, geometry.size.width * 0.03)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Empty Events View
    private func emptyEventsView(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: geometry.size.width * 0.06, weight: .light))
                .foregroundColor(.secondary)
            
            Text("Aucun événement prévu")
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(.secondary)
            
            Button("Ajouter un événement") {}
                .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, geometry.size.height * 0.02)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Quick Actions
    private func quickActions(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            Text("Actions rapides")
                .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: geometry.size.width * 0.04) {
                // Add Child
                actionButton(
                    title: "Ajouter enfant",
                    icon: "person.badge.plus",
                    color: .blue,
                    geometry: geometry
                ) {}
                
                // Add Event
                actionButton(
                    title: "Nouvel événement",
                    icon: "calendar.badge.plus",
                    color: .green,
                    geometry: geometry
                ) {}
            }
            
            HStack(spacing: geometry.size.width * 0.04) {
                // Add Document
                actionButton(
                    title: "Ajouter document",
                    icon: "doc.badge.plus",
                    color: .purple,
                    geometry: geometry
                ) {}
                
                // View Calendar
                actionButton(
                    title: "Voir calendrier",
                    icon: "calendar",
                    color: .orange,
                    geometry: geometry
                ) {}
            }
        }
    }
    
    // MARK: - Action Button
    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        geometry: GeometryProxy,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: geometry.size.height * 0.015) {
                Image(systemName: icon)
                    .font(.system(size: geometry.size.width * 0.06, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height * 0.12)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .fill(color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Recent Documents
    private func recentDocuments(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            HStack {
                Text("Documents récents")
                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Voir tout") {}
                    .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            if documentsViewModel.documents.isEmpty {
                emptyDocumentsView(geometry: geometry)
            } else {
                VStack(spacing: geometry.size.height * 0.01) {
                    ForEach(Array(documentsViewModel.documents.prefix(3)), id: \.id) { document in
                        documentRow(document: document, geometry: geometry)
                    }
                }
            }
        }
    }
    
    // MARK: - Document Row
    private func documentRow(document: TempDocument, geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            // Document type indicator
            ZStack {
                RoundedRectangle(cornerRadius: geometry.size.width * 0.02)
                    .fill(document.documentType.color.opacity(0.2))
                    .frame(
                        width: geometry.size.width * 0.1,
                        height: geometry.size.width * 0.1
                    )
                
                Image(systemName: document.documentType.icon)
                    .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                    .foregroundColor(document.documentType.color)
            }
            
            // Document info
            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                Text(document.title)
                    .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(document.documentType.displayName)
                    .font(.system(size: geometry.size.width * 0.035, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Recent indicator
            if document.isRecent {
                Text("Nouveau")
                    .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                    .foregroundColor(.green)
                    .padding(.horizontal, geometry.size.width * 0.02)
                    .padding(.vertical, geometry.size.height * 0.005)
                    .background(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.015)
                            .fill(.green.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, geometry.size.height * 0.01)
        .padding(.horizontal, geometry.size.width * 0.03)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Empty Documents View
    private func emptyDocumentsView(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.015) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: geometry.size.width * 0.06, weight: .light))
                .foregroundColor(.secondary)
            
            Text("Aucun document ajouté")
                .font(.system(size: geometry.size.width * 0.035, weight: .medium))
                .foregroundColor(.secondary)
            
            Button("Ajouter un document") {}
                .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, geometry.size.height * 0.02)
        .background(
            RoundedRectangle(cornerRadius: geometry.size.width * 0.03)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Helper Functions
    private func loadData() async {
        await childrenViewModel.loadChildren()
        await eventsViewModel.loadEvents()
        await documentsViewModel.loadDocuments()
    }
    
    private func eventDateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
    
    // MARK: - Computed Properties
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