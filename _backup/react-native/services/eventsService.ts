import { supabase } from '../config/supabase';
import { Event, EventType, EventStatus } from '../types/database';

export interface CreateEventData {
  title: string;
  description?: string;
  start_time: string;
  end_time: string;
  type: EventType;
  child_id?: string;
  location?: string;
  notes?: string;
}

export interface UpdateEventData extends Partial<CreateEventData> {
  id: string;
  status?: EventStatus;
}

export interface EventFilters {
  startDate?: string;
  endDate?: string;
  type?: EventType;
  status?: EventStatus;
  childId?: string;
}

export class EventsService {
  static async getEvents(
    userId: string,
    filters?: EventFilters
  ): Promise<Event[]> {
    let query = supabase
      .from('events')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('user_id', userId);

    // Appliquer les filtres
    if (filters?.startDate) {
      query = query.gte('start_time', filters.startDate);
    }
    if (filters?.endDate) {
      query = query.lte('end_time', filters.endDate);
    }
    if (filters?.type) {
      query = query.eq('type', filters.type);
    }
    if (filters?.status) {
      query = query.eq('status', filters.status);
    }
    if (filters?.childId) {
      query = query.eq('child_id', filters.childId);
    }

    const { data, error } = await query.order('start_time', {
      ascending: true,
    });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  static async getEventById(eventId: string): Promise<Event | null> {
    const { data, error } = await supabase
      .from('events')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('id', eventId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null; // Événement non trouvé
      }
      throw new Error(error.message);
    }

    return data;
  }

  static async createEvent(
    userId: string,
    eventData: CreateEventData
  ): Promise<Event> {
    const { data, error } = await supabase
      .from('events')
      .insert({
        user_id: userId,
        ...eventData,
        status: 'scheduled',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  static async updateEvent(eventData: UpdateEventData): Promise<Event> {
    const { id, ...updates } = eventData;

    const { data, error } = await supabase
      .from('events')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  static async deleteEvent(eventId: string): Promise<void> {
    const { error } = await supabase.from('events').delete().eq('id', eventId);

    if (error) {
      throw new Error(error.message);
    }
  }

  static async getEventsByDateRange(
    userId: string,
    startDate: string,
    endDate: string
  ): Promise<Event[]> {
    const { data, error } = await supabase
      .from('events')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('user_id', userId)
      .gte('start_time', startDate)
      .lte('end_time', endDate)
      .order('start_time', { ascending: true });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  static async getUpcomingEvents(
    userId: string,
    limit: number = 10
  ): Promise<Event[]> {
    const now = new Date().toISOString();

    const { data, error } = await supabase
      .from('events')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('user_id', userId)
      .gte('start_time', now)
      .eq('status', 'scheduled')
      .order('start_time', { ascending: true })
      .limit(limit);

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  static async getEventsByChild(childId: string): Promise<Event[]> {
    const { data, error } = await supabase
      .from('events')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('child_id', childId)
      .order('start_time', { ascending: true });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  static async markEventAsCompleted(
    eventId: string,
    notes?: string
  ): Promise<Event> {
    const { data, error } = await supabase
      .from('events')
      .update({
        status: 'completed',
        notes: notes || null,
        updated_at: new Date().toISOString(),
      })
      .eq('id', eventId)
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  static async markEventAsCancelled(
    eventId: string,
    reason?: string
  ): Promise<Event> {
    const { data, error } = await supabase
      .from('events')
      .update({
        status: 'cancelled',
        notes: reason || null,
        updated_at: new Date().toISOString(),
      })
      .eq('id', eventId)
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  static async getEventStats(
    userId: string,
    startDate: string,
    endDate: string
  ) {
    const { data, error } = await supabase
      .from('events')
      .select('status')
      .eq('user_id', userId)
      .gte('start_time', startDate)
      .lte('end_time', endDate);

    if (error) {
      throw new Error(error.message);
    }

    const stats = {
      total: data?.length || 0,
      scheduled: 0,
      completed: 0,
      cancelled: 0,
    };

    data?.forEach(event => {
      stats[event.status as keyof typeof stats]++;
    });

    return stats;
  }

  static async searchEvents(
    userId: string,
    searchTerm: string
  ): Promise<Event[]> {
    const { data, error } = await supabase
      .from('events')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('user_id', userId)
      .or(
        `title.ilike.%${searchTerm}%,description.ilike.%${searchTerm}%,location.ilike.%${searchTerm}%`
      )
      .order('start_time', { ascending: true });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }
}
