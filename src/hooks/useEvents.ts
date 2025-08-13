import { useState, useEffect, useCallback } from 'react';
import { Event } from '../types';
import {
  EventsService,
  CreateEventData,
  UpdateEventData,
} from '../services/eventsService';
import { useAuth } from './useAuth';

// Fonction de mapping pour transformer les données DB vers l'interface Event
const mapDbEventToEvent = (dbEvent: any): Event => {
  return {
    id: dbEvent.id,
    childId: dbEvent.child_id || dbEvent.childId,
    child_id: dbEvent.child_id,
    title: dbEvent.title,
    description: dbEvent.description,
    startTime: dbEvent.start_time ? new Date(dbEvent.start_time) : dbEvent.startTime,
    endTime: dbEvent.end_time ? new Date(dbEvent.end_time) : dbEvent.endTime,
    start_time: dbEvent.start_time,
    end_time: dbEvent.end_time,
    type: dbEvent.event_type || dbEvent.type,
    event_type: dbEvent.event_type,
    location: dbEvent.location,
    all_day: dbEvent.all_day,
    createdBy: dbEvent.created_by || dbEvent.createdBy,
    created_by: dbEvent.created_by,
    createdAt: dbEvent.created_at ? new Date(dbEvent.created_at) : dbEvent.createdAt,
    created_at: dbEvent.created_at,
    updated_at: dbEvent.updated_at,
  };
};

interface UseEventsReturn {
  events: Event[];
  loading: boolean;
  error: string | null;
  refreshEvents: () => Promise<void>;
  addEvent: (
    eventData: CreateEventData
  ) => Promise<{ success: boolean; error?: string }>;
  editEvent: (
    id: string,
    updates: UpdateEventData
  ) => Promise<{ success: boolean; error?: string }>;
  removeEvent: (id: string) => Promise<{ success: boolean; error?: string }>;
  markEventCompleted: (
    id: string
  ) => Promise<{ success: boolean; error?: string }>;
  markEventCancelled: (
    id: string
  ) => Promise<{ success: boolean; error?: string }>;
  getUpcomingEvents: () => Promise<Event[]>;
  getEventsByChild: (childId: string) => Promise<Event[]>;
  getEventsByDateRange: (
    startDate: string,
    endDate: string
  ) => Promise<Event[]>;
  searchEvents: (query: string) => Promise<Event[]>;
  getEventsStats: () => Promise<{
    total: number;
    scheduled: number;
    completed: number;
    cancelled: number;
  }>;
}

/**
 * Hook pour gérer les événements
 */
export const useEvents = (): UseEventsReturn => {
  const { user } = useAuth();
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refreshEvents = useCallback(async () => {
    if (!user) {
      setEvents([]);
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      const eventsData = await EventsService.getEvents(user.id);
      setEvents((eventsData || []).map(mapDbEventToEvent));
    } catch (err) {
      setError('Erreur lors du chargement des événements');
    } finally {
      setLoading(false);
    }
  }, [user]);

  const addEvent = useCallback(
    async (eventData: CreateEventData) => {
      if (!user) {
        return { success: false, error: 'Utilisateur non connecté' };
      }

      try {
        await EventsService.createEvent(user.id, eventData);
        await refreshEvents();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: "Erreur lors de la création de l'événement",
        };
      }
    },
    [refreshEvents, user]
  );

  const editEvent = useCallback(
    async (id: string, updates: Partial<CreateEventData>) => {
      try {
        await EventsService.updateEvent({ id, ...updates });
        await refreshEvents();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: "Erreur lors de la mise à jour de l'événement",
        };
      }
    },
    [refreshEvents]
  );

  const removeEvent = useCallback(
    async (id: string) => {
      try {
        await EventsService.deleteEvent(id);
        await refreshEvents();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: "Erreur lors de la suppression de l'événement",
        };
      }
    },
    [refreshEvents]
  );

  const markEventCompleted = useCallback(
    async (id: string) => {
      try {
        await EventsService.markEventAsCompleted(id);
        await refreshEvents();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: 'Erreur lors de la mise à jour du statut',
        };
      }
    },
    [refreshEvents]
  );

  const markEventCancelled = useCallback(
    async (id: string) => {
      try {
        await EventsService.markEventAsCancelled(id);
        await refreshEvents();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: 'Erreur lors de la mise à jour du statut',
        };
      }
    },
    [refreshEvents]
  );

  const getUpcomingEvents = useCallback(async (): Promise<Event[]> => {
    if (!user) {
      return [];
    }

    try {
      const result = await EventsService.getUpcomingEvents(user.id);
      return (result || []).map(mapDbEventToEvent);
    } catch (err) {
      return [];
    }
  }, [user]);

  const getEventsByChild = useCallback(
    async (childId: string): Promise<Event[]> => {
      try {
        const result = await EventsService.getEventsByChild(childId);
        return (result || []).map(mapDbEventToEvent);
      } catch (err) {
        return [];
      }
    },
    []
  );

  const getEventsByDateRange = useCallback(
    async (startDate: string, endDate: string): Promise<Event[]> => {
      if (!user) {
        return [];
      }

      try {
        const result = await EventsService.getEventsByDateRange(
          user.id,
          startDate,
          endDate
        );
        return (result || []).map(mapDbEventToEvent);
      } catch (err) {
        return [];
      }
    },
    [user]
  );

  const searchEvents = useCallback(
    async (query: string): Promise<Event[]> => {
      if (!user) {
        return [];
      }

      try {
        const result = await EventsService.searchEvents(user.id, query);
        return (result || []).map(mapDbEventToEvent);
      } catch (err) {
        return [];
      }
    },
    [user]
  );

  const getEventsStats = useCallback(async () => {
    if (!user) {
      return { total: 0, scheduled: 0, completed: 0, cancelled: 0 };
    }

    try {
      const today = new Date().toISOString().split('T')[0];
      const nextMonth = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
        .toISOString()
        .split('T')[0];
      const stats = await EventsService.getEventStats(
        user.id,
        today,
        nextMonth
      );
      return stats || { total: 0, scheduled: 0, completed: 0, cancelled: 0 };
    } catch (err) {
      return { total: 0, scheduled: 0, completed: 0, cancelled: 0 };
    }
  }, [user]);

  useEffect(() => {
    refreshEvents();
  }, [refreshEvents]);

  return {
    events,
    loading,
    error,
    refreshEvents,
    addEvent,
    editEvent,
    removeEvent,
    markEventCompleted,
    markEventCancelled,
    getUpcomingEvents,
    getEventsByChild,
    getEventsByDateRange,
    searchEvents,
    getEventsStats,
  };
};

/**
 * Hook pour obtenir un événement spécifique par ID
 */
export const useEvent = (eventId: string | null) => {
  const { events, loading } = useEvents();
  const event = events.find(e => e.id === eventId) || null;

  return {
    event,
    loading: loading && !!eventId,
  };
};

/**
 * Hook pour obtenir les événements d'aujourd'hui
 */
export const useTodayEvents = () => {
  const { user } = useAuth();
  const [todayEvents, setTodayEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchTodayEvents = async () => {
      if (!user) {
        setTodayEvents([]);
        setLoading(false);
        return;
      }

      try {
        const today = new Date().toISOString().split('T')[0];
        const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000)
          .toISOString()
          .split('T')[0];

        const events = await EventsService.getEventsByDateRange(
          user.id,
          today,
          tomorrow
        );
        setTodayEvents((events || []).map(mapDbEventToEvent));
      } catch (err) {
        setTodayEvents([]);
      } finally {
        setLoading(false);
      }
    };

    fetchTodayEvents();
  }, [user]);

  return {
    todayEvents,
    loading,
  };
};
