import { useState, useEffect, useCallback } from 'react';
import { useAuth } from './useAuth';
import { User } from '../types/database';

// Interface pour les données de mise à jour du profil
export interface UpdateProfileData {
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  address?: string;
  bio?: string;
  avatar?: string;
  preferences?: {
    language?: string;
    timezone?: string;
    notifications?: boolean;
  };
}

// Interface pour les statistiques du profil
export interface ProfileStats {
  totalChildren: number;
  totalEvents: number;
  totalDocuments: number;
  totalRelationships: number;
  joinDate: string;
  lastActivity: string;
}

export const useProfile = () => {
  const { user, updateProfile: updateUserProfile } = useAuth();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [profileStats, setProfileStats] = useState<ProfileStats | null>(null);

  // Rafraîchir les données du profil
  const refreshProfile = useCallback(async () => {
    if (!user) {
      return;
    }

    setLoading(true);
    setError(null);

    try {
      // TODO: Implémenter l'appel au service de profil
      console.log('Refreshing profile for user:', user.id);

      // Simuler un délai
      await new Promise(resolve => setTimeout(resolve, 1000));

      // TODO: Récupérer les vraies données depuis le service
      const stats: ProfileStats = {
        totalChildren: 0,
        totalEvents: 0,
        totalDocuments: 0,
        totalRelationships: 0,
        joinDate: user.createdAt.toISOString(),
        lastActivity: new Date().toISOString(),
      };

      setProfileStats(stats);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : 'Erreur lors du rafraîchissement du profil'
      );
      console.error('Error refreshing profile:', err);
    } finally {
      setLoading(false);
    }
  }, [user]);

  // Mettre à jour le profil
  const updateProfile = useCallback(
    async (updates: UpdateProfileData) => {
      if (!user) {
        throw new Error('Utilisateur non connecté');
      }

      setLoading(true);
      setError(null);

      try {
        // TODO: Implémenter l'appel au service de profil
        console.log('Updating profile for user:', user.id, updates);

        // Simuler un délai
        await new Promise(resolve => setTimeout(resolve, 1000));

        // TODO: Appeler le vrai service et mettre à jour l'utilisateur
        await updateUserProfile(updates);

        // Rafraîchir les statistiques
        await refreshProfile();

        return { success: true };
      } catch (err) {
        const errorMessage =
          err instanceof Error
            ? err.message
            : 'Erreur lors de la mise à jour du profil';
        setError(errorMessage);
        console.error('Error updating profile:', err);
        return { success: false, error: errorMessage };
      } finally {
        setLoading(false);
      }
    },
    [user, updateUserProfile, refreshProfile]
  );

  // Changer le mot de passe
  const changePassword = useCallback(
    async (currentPassword: string, newPassword: string) => {
      if (!user) {
        throw new Error('Utilisateur non connecté');
      }

      setLoading(true);
      setError(null);

      try {
        // TODO: Implémenter l'appel au service d'authentification
        console.log('Changing password for user:', user.id);

        // Simuler un délai
        await new Promise(resolve => setTimeout(resolve, 1000));

        // TODO: Appeler le vrai service de changement de mot de passe

        return { success: true };
      } catch (err) {
        const errorMessage =
          err instanceof Error
            ? err.message
            : 'Erreur lors du changement de mot de passe';
        setError(errorMessage);
        console.error('Error changing password:', err);
        return { success: false, error: errorMessage };
      } finally {
        setLoading(false);
      }
    },
    [user]
  );

  // Supprimer le compte
  const deleteAccount = useCallback(
    async (password: string) => {
      if (!user) {
        throw new Error('Utilisateur non connecté');
      }

      setLoading(true);
      setError(null);

      try {
        // TODO: Implémenter l'appel au service de suppression de compte
        console.log('Deleting account for user:', user.id);

        // Simuler un délai
        await new Promise(resolve => setTimeout(resolve, 1000));

        // TODO: Appeler le vrai service de suppression de compte

        return { success: true };
      } catch (err) {
        const errorMessage =
          err instanceof Error
            ? err.message
            : 'Erreur lors de la suppression du compte';
        setError(errorMessage);
        console.error('Error deleting account:', err);
        return { success: false, error: errorMessage };
      } finally {
        setLoading(false);
      }
    },
    [user]
  );

  // Charger les données au montage
  useEffect(() => {
    if (user) {
      refreshProfile();
    }
  }, [user, refreshProfile]);

  return {
    // État
    user,
    loading,
    error,
    profileStats,

    // Actions
    refreshProfile,
    updateProfile,
    changePassword,
    deleteAccount,
  };
};

// Hook pour les informations de base du profil
export const useBasicProfile = () => {
  const { user } = useAuth();

  return {
    fullName: user ? user.displayName : '',
    initials: user
      ? user.displayName
          .split(' ')
          .map(n => n[0])
          .join('')
          .toUpperCase()
      : '',
    email: user?.email || '',
    phone: user?.phone || '',
    avatar: user?.avatarUrl || null,
    role: user?.role || 'parent',
  };
};

// Hook pour vérifier si le profil est complet
export const useProfileCompletion = () => {
  const { user } = useAuth();

  const getCompletionPercentage = useCallback(() => {
    if (!user) {
      return 0;
    }

    const fields = [user.displayName, user.email, user.phone, user.address];

    const completedFields = fields.filter(
      field => field && field.trim() !== ''
    ).length;
    return Math.round((completedFields / fields.length) * 100);
  }, [user]);

  const getMissingFields = useCallback(() => {
    if (!user) {
      return [];
    }

    const missingFields = [];
    if (!user.displayName) {
      missingFields.push('Nom complet');
    }
    if (!user.email) {
      missingFields.push('Email');
    }
    if (!user.phone) {
      missingFields.push('Téléphone');
    }
    if (!user.address) {
      missingFields.push('Adresse');
    }

    return missingFields;
  }, [user]);

  return {
    completionPercentage: getCompletionPercentage(),
    missingFields: getMissingFields(),
    isComplete: getCompletionPercentage() === 100,
  };
};
