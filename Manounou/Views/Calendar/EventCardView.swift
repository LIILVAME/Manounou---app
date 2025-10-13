//
//  EventCardView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI

struct EventCardView: View {
    let event: Event
    let geometry: GeometryProxy
    let onTap: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: geometry.size.width * 0.04) {
                // Event type indicator
                eventTypeIndicator
                
                // Event content
                eventContent
                
                // Time and actions
                eventActions
            }
            .padding(geometry.size.width * 0.04)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.width * 0.04)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: geometry.size.width * 0.01,
                        x: 0,
                        y: geometry.size.width * 0.005
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Event Type Indicator
    private var eventTypeIndicator: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(event.eventType.color.opacity(0.2))
                    .frame(
                        width: geometry.size.width * 0.12,
                        height: geometry.size.width * 0.12
                    )
                
                Image(systemName: event.eventType.icon)
                    .font(.system(size: geometry.size.width * 0.05, weight: .medium))
                    .foregroundColor(event.eventType.color)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Event Content
    private var eventContent: some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.008) {
            // Title
            Text(event.title)
                .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Description
            if let description = event.description, !description.isEmpty {
                Text(description)
                    .font(.system(size: geometry.size.width * 0.035, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            // Event type and children info
            HStack(spacing: geometry.size.width * 0.02) {
                // Event type
                Text(event.eventType.name)
                    .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                    .foregroundColor(event.eventType.color)
                    .padding(.horizontal, geometry.size.width * 0.02)
                    .padding(.vertical, geometry.size.height * 0.005)
                    .background(
                        RoundedRectangle(cornerRadius: geometry.size.width * 0.015)
                            .fill(event.eventType.color.opacity(0.1))
                    )
                
                // Children count
                if !event.childrenIds.isEmpty {
                    HStack(spacing: geometry.size.width * 0.01) {
                        Image(systemName: "person.2")
                            .font(.system(size: geometry.size.width * 0.025, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(event.childrenIds.count)")
                            .font(.system(size: geometry.size.width * 0.03, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Event Actions
    private var eventActions: some View {
        VStack(alignment: .trailing, spacing: geometry.size.height * 0.01) {
            // Time
            VStack(alignment: .trailing, spacing: geometry.size.height * 0.003) {
                Text(timeText)
                    .font(.system(size: geometry.size.width * 0.035, weight: .semibold))
                    .foregroundColor(.primary)
                
                if !event.isAllDay {
                    Text(durationText)
                        .font(.system(size: geometry.size.width * 0.03, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status indicator
            statusIndicator
            
            // Edit button
            Button(action: onEdit) {
                Image(systemName: "ellipsis")
                    .font(.system(size: geometry.size.width * 0.04, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(
                        width: geometry.size.width * 0.08,
                        height: geometry.size.width * 0.08
                    )
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Status Indicator
    private var statusIndicator: some View {
        HStack(spacing: geometry.size.width * 0.01) {
            Circle()
                .fill(statusColor)
                .frame(
                    width: geometry.size.width * 0.02,
                    height: geometry.size.width * 0.02
                )
            
            Text(statusText)
                .font(.system(size: geometry.size.width * 0.025, weight: .medium))
                .foregroundColor(statusColor)
        }
    }
    
    // MARK: - Computed Properties
    private var timeText: String {
        if event.isAllDay {
            return "Toute la journée"
        } else {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: event.startDate)
        }
    }
    
    private var durationText: String {
        let duration = event.endDate.timeIntervalSince(event.startDate)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h\(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else {
            return "\(minutes)m"
        }
    }
    
    private var statusColor: Color {
        if event.isPast {
            return .gray
        } else if event.isOngoing {
            return .green
        } else if event.isToday {
            return .orange
        } else {
            return .blue
        }
    }
    
    private var statusText: String {
        if event.isPast {
            return "Terminé"
        } else if event.isOngoing {
            return "En cours"
        } else if event.isToday {
            return "Aujourd'hui"
        } else {
            return "À venir"
        }
    }
}

// MARK: - Preview
#if DEBUG
struct EventCardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                ForEach(Event.sampleEvents, id: \.id) { event in
                    EventCardView(
                        event: event,
                        geometry: geometry,
                        onTap: {
                            Logger.info("Event tapped", category: .ui)
                        },
                        onEdit: {
                            Logger.info("Event edit action triggered", category: .ui)
                        }
                    )
                }
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif