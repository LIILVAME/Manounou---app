import { useState, useEffect, useCallback } from 'react';
import { Child } from '../types';
import { Child as DatabaseChild } from '../types/database';
import { ChildrenService, CreateChildData } from '../services/childrenService';
import { useAuth } from './useAuth';

// Fonction pour mapper les données de la base vers le type Child
const mapDatabaseChildToChild = (dbChild: DatabaseChild): Child => {
  return {
    id: dbChild.id,
    parentId: dbChild.parent_id,
    firstName: dbChild.first_name,
    lastName: dbChild.last_name,
    birthDate: new Date(dbChild.birth_date),
    avatar: dbChild.avatar_url,
    allergies: dbChild.allergies ? [dbChild.allergies] : undefined,
    medicalInfo: dbChild.medical_notes,
    emergencyContact: dbChild.emergency_contact
      ? {
          name: dbChild.emergency_contact,
          phone: '',
          relation: '',
        }
      : undefined,
    createdAt: new Date(dbChild.created_at),
    updatedAt: new Date(dbChild.updated_at),
  };
};

interface UseChildrenReturn {
  children: Child[];
  loading: boolean;
  error: string | null;
  refreshChildren: () => Promise<void>;
  addChild: (
    childData: CreateChildData
  ) => Promise<{ success: boolean; error?: string }>;
  editChild: (
    id: string,
    updates: Partial<CreateChildData>
  ) => Promise<{ success: boolean; error?: string }>;
  removeChild: (id: string) => Promise<{ success: boolean; error?: string }>;
  searchChildrenByName: (query: string) => Promise<Child[]>;
  getChildrenStats: () => Promise<{
    count: number;
    withEvents: (Child & { events_count: number })[];
  }>;
}

/**
 * Hook pour gérer les enfants
 */
export const useChildren = (): UseChildrenReturn => {
  const { user } = useAuth();
  const [children, setChildren] = useState<Child[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refreshChildren = useCallback(async () => {
    if (!user) {
      setChildren([]);
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      let childrenData;
      if (user.role === 'parent') {
        childrenData = await ChildrenService.getChildren(user.id);
      } else if (user.role === 'nounou') {
        childrenData = await ChildrenService.getChildrenByNounou(user.id);
      } else {
        setChildren([]);
        return;
      }

      const mappedChildren = (childrenData || []).map(mapDatabaseChildToChild);
      setChildren(mappedChildren);
    } catch (err) {
      setError('Erreur lors du chargement des enfants');
    } finally {
      setLoading(false);
    }
  }, [user]);

  const addChild = useCallback(
    async (childData: CreateChildData) => {
      if (!user) {
        return { success: false, error: 'Utilisateur non connecté' };
      }

      try {
        await ChildrenService.createChild(user.id, childData);
        await refreshChildren();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: "Erreur lors de la création de l'enfant",
        };
      }
    },
    [refreshChildren, user]
  );

  const editChild = useCallback(
    async (id: string, updates: Partial<CreateChildData>) => {
      try {
        await ChildrenService.updateChild({ id, ...updates });
        await refreshChildren();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: "Erreur lors de la mise à jour de l'enfant",
        };
      }
    },
    [refreshChildren]
  );

  const removeChild = useCallback(
    async (id: string) => {
      try {
        await ChildrenService.deleteChild(id);
        await refreshChildren();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: "Erreur lors de la suppression de l'enfant",
        };
      }
    },
    [refreshChildren]
  );

  const searchChildrenByName = useCallback(
    async (query: string): Promise<Child[]> => {
      if (!user) {
        return [];
      }

      try {
        const result = await ChildrenService.searchChildren(user.id, query);
        return (result || []).map(mapDatabaseChildToChild);
      } catch (err) {
        return [];
      }
    },
    [user]
  );

  const getChildrenStats = useCallback(async () => {
    if (!user) {
      return { count: 0, withEvents: [] };
    }

    try {
      const [count, withEvents] = await Promise.all([
        ChildrenService.getChildrenCount(user.id),
        ChildrenService.getChildrenWithEvents(user.id),
      ]);

      return {
        count: count || 0,
        withEvents: (withEvents || []).map(child => ({
          ...mapDatabaseChildToChild(child),
          events_count: child.events_count,
        })),
      };
    } catch (err) {
      console.error('Erreur lors du calcul des statistiques:', err);
      return { count: 0, withEvents: [] };
    }
  }, [user]);

  useEffect(() => {
    refreshChildren();
  }, [refreshChildren]);

  return {
    children,
    loading,
    error,
    refreshChildren,
    addChild,
    editChild,
    removeChild,
    searchChildrenByName,
    getChildrenStats,
  };
};

/**
 * Hook pour obtenir un enfant spécifique par ID
 */
export const useChild = (childId: string | null) => {
  const { children, loading } = useChildren();
  const child = children.find(c => c.id === childId) || null;

  return {
    child,
    loading: loading && !!childId,
  };
};
