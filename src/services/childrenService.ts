import { supabase } from '../config/supabase';
import { Child } from '../types/database';

export interface CreateChildData {
  first_name: string;
  last_name: string;
  birth_date: string;
  allergies?: string;
  medical_notes?: string;
  emergency_contact?: string;
  emergency_phone?: string;
}

export interface UpdateChildData extends Partial<CreateChildData> {
  id: string;
}

export class ChildrenService {
  static async getChildren(parentId: string): Promise<Child[]> {
    const { data, error } = await supabase
      .from('children')
      .select('*')
      .eq('parent_id', parentId)
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  static async getChildById(childId: string): Promise<Child | null> {
    const { data, error } = await supabase
      .from('children')
      .select('*')
      .eq('id', childId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null; // Enfant non trouvé
      }
      throw new Error(error.message);
    }

    return data;
  }

  static async createChild(
    parentId: string,
    childData: CreateChildData
  ): Promise<Child> {
    const { data, error } = await supabase
      .from('children')
      .insert({
        parent_id: parentId,
        ...childData,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  static async updateChild(childData: UpdateChildData): Promise<Child> {
    const { id, ...updates } = childData;

    const { data, error } = await supabase
      .from('children')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  static async deleteChild(childId: string): Promise<void> {
    const { error } = await supabase
      .from('children')
      .delete()
      .eq('id', childId);

    if (error) {
      throw new Error(error.message);
    }
  }

  static async getChildrenByNounou(nounouId: string): Promise<Child[]> {
    // Récupérer les enfants via les relations utilisateur
    const { data: relationships, error: relError } = await supabase
      .from('user_relationships')
      .select('parent_id')
      .eq('nounou_id', nounouId)
      .eq('status', 'active');

    if (relError) {
      throw new Error(relError.message);
    }

    if (!relationships || relationships.length === 0) {
      return [];
    }

    const parentIds = relationships.map(rel => rel.parent_id);

    const { data, error } = await supabase
      .from('children')
      .select('*')
      .in('parent_id', parentIds)
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  static async searchChildren(
    parentId: string,
    searchTerm: string
  ): Promise<Child[]> {
    const { data, error } = await supabase
      .from('children')
      .select('*')
      .eq('parent_id', parentId)
      .or(`first_name.ilike.%${searchTerm}%,last_name.ilike.%${searchTerm}%`)
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  static async getChildrenCount(parentId: string): Promise<number> {
    const { count, error } = await supabase
      .from('children')
      .select('*', { count: 'exact', head: true })
      .eq('parent_id', parentId);

    if (error) {
      throw new Error(error.message);
    }

    return count || 0;
  }

  static async getChildrenWithEvents(
    parentId: string
  ): Promise<(Child & { events_count: number })[]> {
    const { data, error } = await supabase
      .from('children')
      .select(
        `
        *,
        events:events(count)
      `
      )
      .eq('parent_id', parentId)
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(error.message);
    }

    return (data || []).map(child => ({
      ...child,
      events_count: child.events?.[0]?.count || 0,
    }));
  }
}
