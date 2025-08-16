//
//  CalendarView.swift
//  Manounou
//
//  Created by Assistant on 16/08/2025.
//

import SwiftUI
import UserNotifications

// MARK: - Calendar View Type

enum CalendarViewType: String, CaseIterable {
    case month = "month"
    case week = "week"
    case day = "day"
    case agenda = "agenda"
    
    var displayName: String {
        switch self {
        case .month: return "Mois"
        case .week: return "Semaine"
        case .day: return "Jour"
        case .agenda: return "Agenda"
        }
    }
    
    var icon: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        case .day: return "calendar.day.timeline.leading"
        case .agenda: return "list.bullet.clipboard"
        }
    }
}

// MARK: - Calendar View

struct CalendarView: View {
    @EnvironmentObject var eventsViewModel: EventsViewModel
    @EnvironmentObject var childrenViewModel: ChildrenViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var selectedViewType: CalendarViewType = .month
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var eventsSheetOffset: CGFloat = 180
    @State private var isEventsSheetExpanded = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Contenu principal du calendrier
                VStack(spacing: 0) {
                    // Sélecteur de vue
                    viewTypeSelector
                    
                    // Zone de contenu principal
                    calendarContent
                    
                    Spacer()
                }
                
                // Bottom Sheet pour les événements
                eventsBottomSheet(geometry: geometry)
            }
        }
        .navigationTitle("Calendrier")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddEvent) {
            AddEventView()
                .environmentObject(eventsViewModel)
                .environmentObject(childrenViewModel)
        }
        .onAppear {
            Task {
                await eventsViewModel.loadEvents()
            }
        }
    }
    
    // MARK: - View Type Selector
    
    private var viewTypeSelector: some View {
        HStack(spacing: 0) {
            ForEach([CalendarViewType.day, .week, .month], id: \.self) { viewType in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedViewType = viewType
                    }
                } label: {
                    Text(viewType.displayName)
                        .font(.system(size: 15, weight: selectedViewType == viewType ? .semibold : .medium))
                        .foregroundColor(selectedViewType == viewType ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedViewType == viewType ? Color.blue : Color.clear)
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Calendar Content
    
    @ViewBuilder
    private var calendarContent: some View {
        Group {
            switch selectedViewType {
            case .month:
                MonthCalendarView(
                    selectedDate: $selectedDate,
                    events: eventsViewModel.events
                )
            case .week:
                WeekCalendarView(
                    selectedDate: $selectedDate,
                    events: eventsViewModel.events
                )
            case .day:
                DayCalendarView(
                    selectedDate: $selectedDate,
                    events: eventsViewModel.events
                )
            case .agenda:
                AgendaCalendarView(
                    events: eventsViewModel.events
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Events Bottom Sheet
    
    private func eventsBottomSheet(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 0) {
                // Handle de glissement
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color(.systemGray3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                
                // En-tête de la section événements
                eventsHeader
                
                // Contenu des événements
                eventsContent
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
            )
            .offset(y: eventsSheetOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newOffset = eventsSheetOffset + value.translation.y
                        let minOffset: CGFloat = 80
                        let maxOffset: CGFloat = 180
                        
                        eventsSheetOffset = max(minOffset, min(maxOffset, newOffset))
                    }
                    .onEnded { value in
                        let velocity = value.predictedEndTranslation.y
                        let threshold: CGFloat = 30
                        
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            if velocity > threshold {
                                eventsSheetOffset = 180 // Position fermée
                                isEventsSheetExpanded = false
                            } else {
                                eventsSheetOffset = 80 // Position ouverte
                                isEventsSheetExpanded = true
                            }
                        }
                    }
            )
        }
    }
    
    // MARK: - Events Header
    
    private var eventsHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Événements")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("\(eventsViewModel.events.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.8))
                    )
                
                Button(action: { showingAddEvent = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Events Content
    
    @ViewBuilder
    private var eventsContent: some View {
        if eventsViewModel.events.isEmpty {
            EmptyStateView.events {
                showingAddEvent = true
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 20)
        } else {
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(eventsViewModel.events, id: \.id) { event in
                        EventRowView(
                            event: event,
                            style: .compact
                        ) {
                            // Action au tap sur l'événement
                            // TODO: Naviguer vers les détails de l'événement
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 2)
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 12)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        CalendarView()
            .environmentObject(EventsViewModel())
            .environmentObject(ChildrenViewModel())
            .environmentObject(NotificationManager())
    }
}