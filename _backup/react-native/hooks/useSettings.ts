// Hook simplifié pour les paramètres - Version lean MVP
import { useState, useEffect, useCallback } from 'react';
import { useAuth } from './useAuth';

// Interface simplifiée pour les paramètres MVP
interface SimpleUserSettings {
  notifications_enabled: boolean;
  email_notifications: boolean;
  language: string;
  theme: 'light' | 'dark';
}

// Paramètres par défaut
const defaultSettings: SimpleUserSettings = {
  notifications_enabled: true,
  email_notifications: true,
  language: 'fr',
  theme: 'light',
};

export const useSettings = () => {
  const { user } = useAuth();
  const [settings, setSettings] = useState<SimpleUserSettings>(defaultSettings);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Charger les paramètres
  const loadSettings = useCallback(async () => {
    if (!user) return;
    
    setLoading(true);
    try {
      // TODO: Charger depuis Supabase
      console.log('Loading settings for user:', user.id);
      // Pour l'instant, utiliser les paramètres par défaut
      setSettings(defaultSettings);
    } catch (err) {
      setError('Erreur lors du chargement des paramètres');
    } finally {
      setLoading(false);
    }
  }, [user]);

  // Mettre à jour les paramètres
  const updateSettings = useCallback(async (updates: Partial<SimpleUserSettings>) => {
    if (!user) {
      return { success: false, error: 'Utilisateur non connecté' };
    }

    try {
      console.log('Updating settings:', updates);
      
      // Mise à jour locale
      const newSettings = { ...settings, ...updates };
      setSettings(newSettings);
      
      // TODO: Sauvegarder dans Supabase
      
      return { success: true };
    } catch (err) {
      return { success: false, error: 'Erreur lors de la mise à jour' };
    }
  }, [user, settings]);

  // Activer/désactiver les notifications
  const toggleNotifications = useCallback(async (enabled: boolean) => {
    return updateSettings({ notifications_enabled: enabled });
  }, [updateSettings]);

  // Changer le thème
  const setTheme = useCallback(async (theme: 'light' | 'dark') => {
    return updateSettings({ theme });
  }, [updateSettings]);

  // Changer la langue
  const setLanguage = useCallback(async (language: string) => {
    return updateSettings({ language });
  }, [updateSettings]);

  // Charger les paramètres au montage
  useEffect(() => {
    loadSettings();
  }, [loadSettings]);

  return {
    settings,
    loading,
    error,
    updateSettings,
    toggleNotifications,
    setTheme,
    setLanguage,
    refreshSettings: loadSettings,
  };
};

export default useSettings;
