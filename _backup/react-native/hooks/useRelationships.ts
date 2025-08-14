import { useState, useEffect, useCallback } from 'react';
import { UserRelationship, RelationshipStatus, User } from '../types/database';
import {
  getUserRelationships,
  createRelationship,
  acceptRelationship,
  declineRelationship,
  deleteRelationship,
  getRelationshipStats as getRelationshipStatsService,
  RelationshipWithUsers,
} from '../services/relationshipsService';
import { useAuth } from './useAuth';

interface UseRelationshipsReturn {
  relationships: RelationshipWithUsers[];
  loading: boolean;
  error: string | null;
  refreshRelationships: () => Promise<void>;
  sendRequest: (
    nannouId: string
  ) => Promise<{ success: boolean; error?: string }>;
  acceptRequest: (
    relationshipId: string
  ) => Promise<{ success: boolean; error?: string }>;
  declineRequest: (
    relationshipId: string
  ) => Promise<{ success: boolean; error?: string }>;
  removeRelationship: (
    relationshipId: string
  ) => Promise<{ success: boolean; error?: string }>;
  getPendingRequests: () => RelationshipWithUsers[];
  getAcceptedRelationships: () => RelationshipWithUsers[];
  searchNannies: (searchTerm: string) => Promise<User[]>;
  getRelationshipStats: () => Promise<{
    total: number;
    pending: number;
    accepted: number;
    declined: number;
  }>;
}

/**
 * Hook pour gérer les relations entre utilisateurs (parents et nounous)
 */
export const useRelationships = (): UseRelationshipsReturn => {
  const { user } = useAuth();
  const [relationships, setRelationships] = useState<RelationshipWithUsers[]>(
    []
  );
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refreshRelationships = useCallback(async () => {
    if (!user) {
      setRelationships([]);
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      const relationshipsData = await getUserRelationships(
        user.id,
        user.role as 'parent' | 'nounou'
      );
      setRelationships(relationshipsData || []);
    } catch (err) {
      setError('Erreur lors du chargement des relations');
    } finally {
      setLoading(false);
    }
  }, [user]);

  const sendRequest = useCallback(
    async (nannouId: string) => {
      if (!user) {
        return { success: false, error: 'Utilisateur non connecté' };
      }

      try {
        await createRelationship(user.id, nannouId);
        await refreshRelationships();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: "Erreur lors de l'envoi de la demande",
        };
      }
    },
    [refreshRelationships, user]
  );

  const acceptRequest = useCallback(
    async (relationshipId: string) => {
      try {
        await acceptRelationship(relationshipId);
        await refreshRelationships();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: "Erreur lors de l'acceptation de la demande",
        };
      }
    },
    [refreshRelationships]
  );

  const declineRequest = useCallback(
    async (relationshipId: string) => {
      try {
        await declineRelationship(relationshipId);
        await refreshRelationships();
        return { success: true };
      } catch (err) {
        return { success: false, error: 'Erreur lors du refus de la demande' };
      }
    },
    [refreshRelationships]
  );

  const removeRelationship = useCallback(
    async (relationshipId: string) => {
      try {
        await deleteRelationship(relationshipId);
        await refreshRelationships();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: 'Erreur lors de la suppression de la relation',
        };
      }
    },
    [refreshRelationships]
  );

  const getPendingRequests = useCallback(() => {
    return relationships.filter(rel => rel.status === 'pending');
  }, [relationships]);

  const getAcceptedRelationships = useCallback(() => {
    return relationships.filter(rel => rel.status === 'accepted');
  }, [relationships]);

  const searchNannies = useCallback(
    async (searchTerm: string): Promise<User[]> => {
      // Cette fonctionnalité nécessiterait une fonction de recherche dans le service
      // Pour l'instant, on retourne un tableau vide
      return [];
    },
    []
  );

  const getRelationshipStats = useCallback(async (): Promise<{
    total: number;
    pending: number;
    accepted: number;
    declined: number;
  }> => {
    if (!user) {
      return { total: 0, pending: 0, accepted: 0, declined: 0 };
    }

    try {
      const stats = await getRelationshipStatsService(
        user.id,
        user.role as 'parent' | 'nounou'
      );
      return stats || { total: 0, pending: 0, accepted: 0, declined: 0 };
    } catch (err) {
      return { total: 0, pending: 0, accepted: 0, declined: 0 };
    }
  }, [user]);

  useEffect(() => {
    refreshRelationships();
  }, [refreshRelationships]);

  return {
    relationships,
    loading,
    error,
    refreshRelationships,
    sendRequest,
    acceptRequest,
    declineRequest,
    removeRelationship,
    getPendingRequests,
    getAcceptedRelationships,
    searchNannies,
    getRelationshipStats,
  };
};

/**
 * Hook pour obtenir une relation spécifique par ID
 */
export const useRelationship = (relationshipId: string | null) => {
  const { relationships, loading } = useRelationships();
  const relationship = relationships.find(r => r.id === relationshipId) || null;

  return {
    relationship,
    loading: loading && !!relationshipId,
  };
};

/**
 * Hook pour obtenir les demandes en attente
 */
export const usePendingRequests = () => {
  const { relationships, loading, getPendingRequests } = useRelationships();

  const pendingRequests = getPendingRequests();

  return {
    pendingRequests,
    loading,
    count: pendingRequests.length,
  };
};

/**
 * Hook pour obtenir les relations acceptées
 */
export const useAcceptedRelationships = () => {
  const { relationships, loading, getAcceptedRelationships } =
    useRelationships();

  const acceptedRelationships = getAcceptedRelationships();

  return {
    acceptedRelationships,
    loading,
    count: acceptedRelationships.length,
  };
};
