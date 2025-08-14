import { useState, useEffect, useCallback, useMemo } from 'react';
import { useAuth } from './useAuth';
import { useEvents } from './useEvents';

// Types pour le calendrier
export type CalendarView = 'month' | 'week' | 'day' | 'agenda';
export type EventType =
  | 'appointment'
  | 'reminder'
  | 'milestone'
  | 'activity'
  | 'medical'
  | 'education'
  | 'other';
export type RecurrenceType =
  | 'none'
  | 'daily'
  | 'weekly'
  | 'monthly'
  | 'yearly'
  | 'custom';

// Interface pour un événement de calendrier
export interface CalendarEvent {
  id: string;
  title: string;
  description?: string;
  startDate: Date;
  endDate: Date;
  allDay: boolean;
  type: EventType;
  color?: string;
  location?: string;
  attendees?: string[];
  reminders?: {
    id: string;
    minutes: number;
    type: 'notification' | 'email' | 'sms';
  }[];
  recurrence?: {
    type: RecurrenceType;
    interval: number;
    endDate?: Date;
    count?: number;
    daysOfWeek?: number[];
    dayOfMonth?: number;
    monthOfYear?: number;
  };
  metadata?: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
  createdBy: string;
}

// Interface pour les filtres de calendrier
export interface CalendarFilters {
  types?: EventType[];
  dateRange?: {
    start: Date;
    end: Date;
  };
  attendees?: string[];
  search?: string;
  showAllDay?: boolean;
  showRecurring?: boolean;
}

// Interface pour les paramètres de calendrier
export interface CalendarSettings {
  defaultView: CalendarView;
  weekStartsOn: 0 | 1 | 2 | 3 | 4 | 5 | 6; // 0 = Dimanche, 1 = Lundi, etc.
  workingHours: {
    start: string; // Format HH:mm
    end: string;
  };
  timeZone: string;
  showWeekends: boolean;
  showWeekNumbers: boolean;
  defaultEventDuration: number; // en minutes
  reminderDefaults: {
    minutes: number;
    type: 'notification' | 'email' | 'sms';
  }[];
  colorScheme: Record<EventType, string>;
}

// Interface pour les statistiques de calendrier
export interface CalendarStats {
  totalEvents: number;
  upcomingEvents: number;
  overdueEvents: number;
  eventsByType: Record<EventType, number>;
  busyDays: number;
  freeDays: number;
  averageEventsPerDay: number;
}

// Interface pour les conflits d'événements
export interface EventConflict {
  id: string;
  events: CalendarEvent[];
  type: 'overlap' | 'double-booking' | 'travel-time';
  severity: 'low' | 'medium' | 'high';
  suggestion?: string;
}

// Paramètres par défaut
const defaultSettings: CalendarSettings = {
  defaultView: 'month',
  weekStartsOn: 1, // Lundi
  workingHours: {
    start: '09:00',
    end: '17:00',
  },
  timeZone: 'Europe/Paris',
  showWeekends: true,
  showWeekNumbers: false,
  defaultEventDuration: 60,
  reminderDefaults: [
    { minutes: 15, type: 'notification' },
    { minutes: 60, type: 'notification' },
  ],
  colorScheme: {
    appointment: '#3B82F6',
    reminder: '#F59E0B',
    milestone: '#10B981',
    activity: '#8B5CF6',
    medical: '#EF4444',
    education: '#06B6D4',
    other: '#6B7280',
  }
};

// Stockage local
const CALENDAR_SETTINGS_KEY = 'manounou_calendar_settings';

export const useCalendar = () => {
  const { user } = useAuth();
  const {
    events: allEvents,
    loading: eventsLoading,
    error: eventsError,
  } = useEvents();

  const [currentDate, setCurrentDate] = useState(new Date());
  const [view, setView] = useState<CalendarView>('month');
  const [settings, setSettings] = useState<CalendarSettings>(defaultSettings);
  const [filters, setFilters] = useState<CalendarFilters>({});
  const [selectedEvent, setSelectedEvent] = useState<CalendarEvent | null>(
    null
  );
  const [draggedEvent, setDraggedEvent] = useState<CalendarEvent | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Charger les paramètres sauvegardés
  useEffect(() => {
    if (typeof localStorage !== 'undefined') {
      try {
        const saved = localStorage.getItem(CALENDAR_SETTINGS_KEY);
        if (saved) {
          const savedSettings = JSON.parse(saved);
          setSettings(prev => ({ ...prev, ...savedSettings }));
        }
      } catch (err) {
        console.error(
          'Erreur lors du chargement des paramètres du calendrier:',
          err
        );
      }
    }
  }, []);

  // Sauvegarder les paramètres
  const saveSettings = useCallback((newSettings: CalendarSettings) => {
    if (typeof localStorage !== 'undefined') {
      try {
        localStorage.setItem(
          CALENDAR_SETTINGS_KEY,
          JSON.stringify(newSettings)
        );
      } catch (err) {
        console.error('Erreur lors de la sauvegarde des paramètres:', err);
      }
    }
  }, []);

  // Convertir les événements en événements de calendrier
  const calendarEvents = useMemo(() => {
    if (!allEvents) {return [];}

    return allEvents.map(event => {
      // Créer les dates de début et fin à partir de start_time et end_time
      const startDate = new Date(`${event.start_time}`);
      const endDate = new Date(`${event.end_time}`);

      // Mapper les types d'événements
      const typeMapping: Record<string, EventType> = {
        medical: 'medical',
        garde: 'appointment',
        activite: 'activity',
        repas: 'other',
        sommeil: 'other',
        autre: 'other',
      };

      const eventType = typeMapping[event.event_type || 'autre'] || 'other';

      return {
        id: event.id,
        title: event.title,
        description: event.description,
        startDate,
        endDate,
        allDay: event.all_day || false,
        type: eventType,
        color: settings.colorScheme[eventType as keyof typeof settings.colorScheme] || '#6366F1',
        location: event.location,
        attendees: [], // Pas de participants dans le modèle Event actuel
        reminders: [], // Pas de rappels dans le modèle Event actuel
        recurrence: undefined, // Pas de récurrence dans le modèle Event actuel
        metadata: {}, // Pas de métadonnées dans le modèle Event actuel
        createdAt: new Date(event.created_at || event.createdAt || new Date()),
        updatedAt: new Date(event.updated_at || new Date()),
        createdBy: event.created_by,
      };
    }) as CalendarEvent[];
  }, [allEvents, settings.colorScheme]);

  // Filtrer les événements
  const filteredEvents = useMemo(() => {
    let filtered = calendarEvents;

    // Filtrer par type
    if (filters.types && filters.types.length > 0) {
      filtered = filtered.filter(event => filters.types!.includes(event.type));
    }

    // Filtrer par plage de dates
    if (filters.dateRange) {
      filtered = filtered.filter(event => {
        const eventDate = event.startDate;
        return (
          eventDate >= filters.dateRange!.start &&
          eventDate <= filters.dateRange!.end
        );
      });
    }

    // Filtrer par participants
    if (filters.attendees && filters.attendees.length > 0) {
      filtered = filtered.filter(event =>
        event.attendees?.some(attendee => filters.attendees!.includes(attendee))
      );
    }

    // Filtrer par recherche
    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      filtered = filtered.filter(
        event =>
          event.title.toLowerCase().includes(searchLower) ||
          event.description?.toLowerCase().includes(searchLower) ||
          event.location?.toLowerCase().includes(searchLower)
      );
    }

    // Filtrer les événements toute la journée
    if (filters.showAllDay === false) {
      filtered = filtered.filter(event => !event.allDay);
    }

    return filtered;
  }, [calendarEvents, filters]);

  // Obtenir les événements pour une date spécifique
  const getEventsForDate = useCallback(
    (date: Date) => {
      return filteredEvents.filter(event => {
        const eventDate = new Date(event.startDate);
        return (
          eventDate.getFullYear() === date.getFullYear() &&
          eventDate.getMonth() === date.getMonth() &&
          eventDate.getDate() === date.getDate()
        );
      });
    },
    [filteredEvents]
  );

  // Obtenir les événements pour une plage de dates
  const getEventsForRange = useCallback(
    (startDate: Date, endDate: Date) => {
      return filteredEvents.filter(event => {
        const eventStart = new Date(event.startDate);
        const eventEnd = new Date(event.endDate);

      return (
          (eventStart >= startDate && eventStart <= endDate) ||
          (eventEnd >= startDate && eventEnd <= endDate) ||
          (eventStart <= startDate && eventEnd >= endDate)
        );
      });
    },
    [filteredEvents]
  );

  // Obtenir les événements à venir
  const getUpcomingEvents = useCallback(
    (days = 7) => {
      const now = new Date();
      const futureDate = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);

    return filteredEvents
        .filter(
          event => event.startDate >= now && event.startDate <= futureDate
        )
        .sort((a, b) => a.startDate.getTime() - b.startDate.getTime());
    },
    [filteredEvents]
  );

  // Obtenir les événements en retard
  const getOverdueEvents = useCallback(() => {
    const now = new Date();

    return filteredEvents
      .filter(event => event.endDate < now)
      .sort((a, b) => b.endDate.getTime() - a.endDate.getTime());
  }, [filteredEvents]);

  // Détecter les conflits d'événements
  const detectConflicts = useCallback((): EventConflict[] => {
    const conflicts: EventConflict[] = [];
    const sortedEvents = [...filteredEvents].sort(
      (a, b) => a.startDate.getTime() - b.startDate.getTime()
    );

    for (let i = 0; i < sortedEvents.length - 1; i++) {
      const currentEvent = sortedEvents[i];
      const nextEvent = sortedEvents[i + 1];

      // Vérifier les chevauchements
      if (
        currentEvent.endDate > nextEvent.startDate &&
        currentEvent.startDate < nextEvent.endDate
      ) {
        const existingConflict = conflicts.find(c =>
          c.events.some(e => e.id === currentEvent.id || e.id === nextEvent.id)
        );

        if (existingConflict) {
          if (!existingConflict.events.some(e => e.id === currentEvent.id)) {
            existingConflict.events.push(currentEvent);
          }
          if (!existingConflict.events.some(e => e.id === nextEvent.id)) {
            existingConflict.events.push(nextEvent);
          }
        } else {
          conflicts.push({
            id: `conflict_${Date.now()}_${i}`,
            events: [currentEvent, nextEvent],
            type: 'overlap',
            severity: 'medium',
            suggestion: "Considérez décaler l'un des événements",
          });
        }
      }
    }

    return conflicts;
  }, [filteredEvents]);

  // Calculer les statistiques
  const getStats = useCallback((): CalendarStats => {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);
    const monthEvents = getEventsForRange(startOfMonth, endOfMonth);

    const eventsByType = monthEvents.reduce((acc, event) => {
      acc[event.type] = (acc[event.type] || 0) + 1;
      return acc;
    }, {} as Record<EventType, number>);

    const daysInMonth = endOfMonth.getDate();
    const daysWithEvents = new Set(
      monthEvents.map(event => event.startDate.getDate())
    ).size;

    return {
      totalEvents: monthEvents.length,
      upcomingEvents: getUpcomingEvents().length,
      overdueEvents: getOverdueEvents().length,
      eventsByType,
      busyDays: daysWithEvents,
      freeDays: daysInMonth - daysWithEvents,
      averageEventsPerDay: monthEvents.length / daysInMonth,
    };
  }, [getEventsForRange, getUpcomingEvents, getOverdueEvents]);

  // Navigation dans le calendrier
  const navigateToDate = useCallback((date: Date) => {
    setCurrentDate(date);
  }, []);

  const navigateToPrevious = useCallback(() => {
    const newDate = new Date(currentDate);

    switch (view) {
      case 'month':
        newDate.setMonth(newDate.getMonth() - 1);
        break;
      case 'week':
        newDate.setDate(newDate.getDate() - 7);
        break;
      case 'day':
        newDate.setDate(newDate.getDate() - 1);
        break;
    }

    setCurrentDate(newDate);
  }, [currentDate, view]);

  const navigateToNext = useCallback(() => {
    const newDate = new Date(currentDate);

    switch (view) {
      case 'month':
        newDate.setMonth(newDate.getMonth() + 1);
        break;
      case 'week':
        newDate.setDate(newDate.getDate() + 7);
        break;
      case 'day':
        newDate.setDate(newDate.getDate() + 1);
        break;
    }

    setCurrentDate(newDate);
  }, [currentDate, view]);

  const navigateToToday = useCallback(() => {
    setCurrentDate(new Date());
  }, []);

  // Gestion des vues
  const changeView = useCallback(
    (newView: CalendarView) => {
      setView(newView);
      const newSettings = { ...settings, defaultView: newView };
      setSettings(newSettings);
      saveSettings(newSettings);
    },
    [settings, saveSettings]
  );

  // Gestion des filtres
  const updateFilters = useCallback((newFilters: Partial<CalendarFilters>) => {
    setFilters(prev => ({ ...prev, ...newFilters }));
  }, []);

  const clearFilters = useCallback(() => {
    setFilters({});
  }, []);

  // Gestion des paramètres
  const updateSettings = useCallback(
    (newSettings: Partial<CalendarSettings>) => {
      const updated = { ...settings, ...newSettings };
      setSettings(updated);
      saveSettings(updated);
    },
    [settings, saveSettings]
  );

  const resetSettings = useCallback(() => {
    setSettings(defaultSettings);
    saveSettings(defaultSettings);
  }, [saveSettings]);

  // Gestion du drag & drop
  const startDrag = useCallback((event: CalendarEvent) => {
    setDraggedEvent(event);
  }, []);

  const endDrag = useCallback(() => {
    setDraggedEvent(null);
  }, []);

  const dropEvent = useCallback(
    async (targetDate: Date) => {
      if (!draggedEvent) {return;}

      try {
        setLoading(true);

      // TODO: Implémenter la mise à jour de l'événement
        console.log(
          "Déplacer l'événement",
          draggedEvent.id,
          'vers',
          targetDate
        );

        setDraggedEvent(null);
      } catch (err) {
        setError(
          err instanceof Error ? err.message : 'Erreur lors du déplacement'
        );
      } finally {
        setLoading(false);
      }
    },
    [draggedEvent]
  );

  // Utilitaires de date
  const formatDate = useCallback(
    (date: Date, format: 'short' | 'long' | 'time' = 'short') => {
      const options: Intl.DateTimeFormatOptions = {
        timeZone: settings.timeZone,
      };

      switch (format) {
        case 'short':
          options.day = 'numeric';
          options.month = 'short';
          options.year = 'numeric';
          break;
        case 'long':
          options.weekday = 'long';
          options.day = 'numeric';
          options.month = 'long';
          options.year = 'numeric';
          break;
        case 'time':
          options.hour = '2-digit';
          options.minute = '2-digit';
          break;
      }

      return new Intl.DateTimeFormat('fr-FR', options).format(date);
    },
    [settings.timeZone]
  );

  const isToday = useCallback((date: Date) => {
    const today = new Date();
    return (
      date.getFullYear() === today.getFullYear() &&
      date.getMonth() === today.getMonth() &&
      date.getDate() === today.getDate()
    );
  }, []);

  const isWeekend = useCallback((date: Date) => {
    const day = date.getDay();
    return day === 0 || day === 6; // Dimanche ou Samedi
  }, []);

  const getWeekDates = useCallback((date: Date) => {
    const startOfWeek = new Date(date);
    const day = startOfWeek.getDay();
    const diff = startOfWeek.getDate() - day + (day === 0 ? -6 : 1); // Ajuster pour commencer le lundi
    startOfWeek.setDate(diff);

    const weekDates = [];
    for (let i = 0; i < 7; i++) {
      const weekDate = new Date(startOfWeek);
      weekDate.setDate(startOfWeek.getDate() + i);
      weekDates.push(weekDate);
    }

    return weekDates;
  }, []);

  const getMonthDates = useCallback((date: Date) => {
    const year = date.getFullYear();
    const month = date.getMonth();

    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);

    const startDate = new Date(firstDay);
    const startDay = firstDay.getDay();
    startDate.setDate(firstDay.getDate() - (startDay === 0 ? 6 : startDay - 1));

    const endDate = new Date(lastDay);
    const endDay = lastDay.getDay();
    endDate.setDate(lastDay.getDate() + (endDay === 0 ? 0 : 7 - endDay));

    const dates = [];
    const currentDate = new Date(startDate);

    while (currentDate <= endDate) {
      dates.push(new Date(currentDate));
      currentDate.setDate(currentDate.getDate() + 1);
    }

    return dates;
  }, []);

  // État calculé
  const conflicts = useMemo(() => detectConflicts(), [detectConflicts]);
  const stats = useMemo(() => getStats(), [getStats]);
  const hasConflicts = conflicts.length > 0;
  const hasFilters = Object.keys(filters).length > 0;

  return {
    // État
    currentDate,
    view,
    settings,
    filters,
    selectedEvent,
    draggedEvent,
    loading: loading || eventsLoading,
    error: error || eventsError,

    // Données
    events: filteredEvents,
    allEvents: calendarEvents,
    conflicts,
    stats,

    // Actions de navigation
    navigateToDate,
    navigateToPrevious,
    navigateToNext,
    navigateToToday,

    // Actions de vue
    changeView,
    setView,

    // Actions de filtrage
    updateFilters,
    clearFilters,

    // Actions de paramètres
    updateSettings,
    resetSettings,

    // Actions d'événements
    setSelectedEvent,
    getEventsForDate,
    getEventsForRange,
    getUpcomingEvents,
    getOverdueEvents,

    // Actions de drag & drop
    startDrag,
    endDrag,
    dropEvent,

    // Utilitaires
    formatDate,
    isToday,
    isWeekend,
    getWeekDates,
    getMonthDates,

    // État calculé
    hasConflicts,
    hasFilters,
    isEmpty: filteredEvents.length === 0,
    isCurrentMonth:
      currentDate.getMonth() === new Date().getMonth() &&
      currentDate.getFullYear() === new Date().getFullYear(),
  };
};

// Hook pour les événements récurrents
export const useRecurringEvents = () => {
  const [recurringEvents, setRecurringEvents] = useState<CalendarEvent[]>([]);

  const generateRecurringEvents = useCallback(
    (baseEvent: CalendarEvent, endDate: Date): CalendarEvent[] => {
      if (!baseEvent.recurrence || baseEvent.recurrence.type === 'none') {
        return [baseEvent];
      }


    const events: CalendarEvent[] = [baseEvent];
      const {
        type,
        interval,
        count,
        endDate: recurrenceEndDate,
      } = baseEvent.recurrence;

    const currentDate = new Date(baseEvent.startDate);
      let eventCount = 1;
      const maxDate = recurrenceEndDate || endDate;
      const maxCount = count || 100; // Limite de sécurité

    while (currentDate < maxDate && eventCount < maxCount) {
        switch (type) {
          case 'daily':
            currentDate.setDate(currentDate.getDate() + interval);
            break;
          case 'weekly':
            currentDate.setDate(currentDate.getDate() + 7 * interval);
            break;
          case 'monthly':
            currentDate.setMonth(currentDate.getMonth() + interval);
            break;
          case 'yearly':
            currentDate.setFullYear(currentDate.getFullYear() + interval);
            break;
          default:
            return events;
        }

      if (currentDate <= maxDate) {
          const duration =
            baseEvent.endDate.getTime() - baseEvent.startDate.getTime();
          const newEvent: CalendarEvent = {
            ...baseEvent,
            id: `${baseEvent.id}_${eventCount}`,
            startDate: new Date(currentDate),
            endDate: new Date(currentDate.getTime() + duration),
          };

        events.push(newEvent);
          eventCount++;
        }
      }

      return events;
    },
    []
  );

  return {
    recurringEvents,
    generateRecurringEvents,
    setRecurringEvents,
  };
};

// Hook pour les rappels
export const useEventReminders = () => {
  const [activeReminders, setActiveReminders] = useState<string[]>([]);

  const scheduleReminder = useCallback(
    (event: CalendarEvent, reminderMinutes: number) => {
      const reminderTime = new Date(
        event.startDate.getTime() - reminderMinutes * 60 * 1000
      );
      const now = new Date();

    if (reminderTime > now) {
        const timeoutId = setTimeout(() => {
          // TODO: Déclencher la notification
          console.log(`Rappel pour: ${event.title}`);
          setActiveReminders(prev => prev.filter(id => id !== event.id));
        }, reminderTime.getTime() - now.getTime());

      setActiveReminders(prev => [...prev, event.id]);

      return () => clearTimeout(timeoutId);
      }

      return () => {};
    },
    []
  );

  const cancelReminder = useCallback((eventId: string) => {
    setActiveReminders(prev => prev.filter(id => id !== eventId));
  }, []);

  return {
    activeReminders,
    scheduleReminder,
    cancelReminder,
  };
};
