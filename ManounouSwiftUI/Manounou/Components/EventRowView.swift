//
//  EventRowView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

/// Composant réutilisable pour afficher un événement dans une liste
struct EventRowView: View {
    let event: Event
    let style: Style
    let onTap: (() -> Void)?
    
    enum Style {
        case compact    // Pour les listes denses
        case detailed   // Pour les vues détaillées
        case card       // Pour les cartes
    }
    
    init(
        event: Event,
        style: Style = .compact,
        onTap: (() -> Void)? = nil
    ) {
        self.event = event
        self.style = style
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: { onTap?() }) {
            content
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
    }
    
    @ViewBuilder
    private var content: some View {
        switch style {
        case .compact:
            compactView
        case .detailed:
            detailedView
        case .card:
            cardView
        }
    }
    
    // MARK: - Compact View
    
    private var compactView: some View {
        HStack(spacing: 12) {
            // Indicateur de couleur
            RoundedRectangle(cornerRadius: 2)
                .fill(event.eventType.color)
                .frame(width: 4, height: 40)
            
            // Contenu principal
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if event.isOngoing {
                        statusBadge("En cours", color: .green)
                    } else if event.isPast {
                        statusBadge("Terminé", color: .gray)
                    }
                }
                
                HStack(spacing: 8) {
                    Image(systemName: event.eventType.icon)
                        .foregroundColor(event.eventType.color)
                        .font(.caption)
                    
                    Text(event.timeText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if event.hasReminder {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .font(.caption2)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Detailed View
    
    private var detailedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // En-tête
            HStack {
                Image(systemName: event.eventType.icon)
                    .foregroundColor(event.eventType.color)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(event.eventType.name)
                        .font(.caption)
                        .foregroundColor(event.eventType.color)
                }
                
                Spacer()
                
                if event.isOngoing {
                    statusBadge("En cours", color: .green)
                } else if event.isPast {
                    statusBadge("Terminé", color: .gray)
                } else if event.isFuture {
                    statusBadge("À venir", color: .blue)
                }
            }
            
            // Informations temporelles
            HStack(spacing: 16) {
                timeInfo("Début", DateFormatters.timeFormatter.string(from: event.startDate))
                timeInfo("Fin", DateFormatters.timeFormatter.string(from: event.endDate))
                timeInfo("Durée", event.durationText)
            }
            
            // Description si disponible
            if let description = event.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Informations supplémentaires
            HStack {
                if event.hasReminder {
                    Label(event.reminderTime?.displayName ?? "Rappel", systemImage: "bell.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                if !event.childrenIds.isEmpty {
                    Label("\(event.childrenIds.count) enfant(s)", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Card View
    
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // En-tête avec heure
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(DateFormatters.timeFormatter.string(from: event.startDate))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Rectangle()
                        .fill(event.eventType.color)
                        .frame(width: 3, height: 30)
                        .cornerRadius(1.5)
                    
                    Text(DateFormatters.timeFormatter.string(from: event.endDate))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: event.eventType.icon)
                            .foregroundColor(event.eventType.color)
                        
                        Text(event.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        Text(event.eventType.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(event.eventType.color.opacity(0.2))
                            .foregroundColor(event.eventType.color)
                            .cornerRadius(8)
                    }
                    
                    if let description = event.description, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Helper Views
    
    private func statusBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color)
            )
    }
    
    private func timeInfo(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        EventRowView(
            event: Event.sampleEvents[0],
            style: .compact
        )
        
        EventRowView(
            event: Event.sampleEvents[1],
            style: .detailed
        )
        
        EventRowView(
            event: Event.sampleEvents[2],
            style: .card
        )
    }
    .padding()
}