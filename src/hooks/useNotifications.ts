import { useState, useEffect, useCallback } from 'react';
import { useAuth } from './useAuth';

// Interface temporaire pour les notifications
interface NotificationData {
  id: string;
  recipient_id: string;
  sender_id?: string;
  title: string;
  message: string;
  type: string;
  read: boolean;
  created_at: string;
  updated_at: string;
}

interface UseNotificationsReturn {
  notifications: NotificationData[];
  unreadCount: number;
  loading: boolean;
  error: string | null;
  refreshNotifications: () => Promise<void>;
  markAsRead: (
    notificationId: string
  ) => Promise<{ success: boolean; error?: string }>;
  markAllAsRead: () => Promise<{ success: boolean; error?: string }>;
  deleteNotification: (
    notificationId: string
  ) => Promise<{ success: boolean; error?: string }>;
  clearAllNotifications: () => Promise<{ success: boolean; error?: string }>;
  sendNotification: (
    recipientId: string,
    title: string,
    message: string,
    type?: string
  ) => Promise<{ success: boolean; error?: string }>;
  getUnreadNotifications: () => NotificationData[];
  getNotificationsByType: (type: string) => NotificationData[];
}

/**
 * Hook pour gérer les notifications
 */
export const useNotifications = (): UseNotificationsReturn => {
  const { user } = useAuth();
  const [notifications, setNotifications] = useState<NotificationData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refreshNotifications = useCallback(async () => {
    if (!user) {
      setNotifications([]);
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      // TODO: Implémenter le service de notifications
      const notificationsData: NotificationData[] = [];
      setNotifications(notificationsData || []);
    } catch (err) {
      setError('Erreur lors du chargement des notifications');
    } finally {
      setLoading(false);
    }
  }, [user]);

  const markAsRead = useCallback(
    async (notificationId: string) => {
      try {
        // TODO: Implémenter le marquage comme lu
        console.log('Mark as read:', notificationId);
        await refreshNotifications();
        return { success: true };
      } catch (err) {
        return { success: false, error: 'Erreur lors du marquage comme lu' };
      }
    },
    [refreshNotifications]
  );

  const markAllAsRead = useCallback(async () => {
    if (!user) {
      return { success: false, error: 'Utilisateur non connecté' };
    }

    try {
      // TODO: Implémenter le marquage de toutes comme lues
      console.log('Mark all as read for user:', user.id);
      await refreshNotifications();
      return { success: true };
    } catch (err) {
      return {
        success: false,
        error: 'Erreur lors du marquage de toutes les notifications comme lues',
      };
    }
  }, [refreshNotifications, user]);

  const deleteNotification = useCallback(
    async (notificationId: string) => {
      try {
        // TODO: Implémenter la suppression de notification
        console.log('Delete notification:', notificationId);
        await refreshNotifications();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: 'Erreur lors de la suppression de la notification',
        };
      }
    },
    [refreshNotifications]
  );

  const clearAllNotifications = useCallback(async () => {
    if (!user) {
      return { success: false, error: 'Utilisateur non connecté' };
    }

    try {
      // TODO: Implémenter la suppression de toutes les notifications
      console.log('Clear all notifications for user:', user.id);
      await refreshNotifications();
      return { success: true };
    } catch (err) {
      return {
        success: false,
        error: 'Erreur lors de la suppression de toutes les notifications',
      };
    }
  }, [refreshNotifications, user]);

  const sendNotification = useCallback(
    async (
      recipientId: string,
      title: string,
      message: string,
      type: string = 'info'
    ) => {
      if (!user) {
        return { success: false, error: 'Utilisateur non connecté' };
      }

      try {
        // TODO: Implémenter l'envoi de notification
        console.log('Send notification:', {
          recipientId,
          title,
          message,
          type,
          senderId: user.id,
        });
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: "Erreur lors de l'envoi de la notification",
        };
      }
    },
    [user]
  );

  const getUnreadNotifications = useCallback(() => {
    return notifications.filter(notification => !notification.read);
  }, [notifications]);

  const getNotificationsByType = useCallback(
    (type: string) => {
      return notifications.filter(notification => notification.type === type);
    },
    [notifications]
  );

  const unreadCount = getUnreadNotifications().length;

  useEffect(() => {
    refreshNotifications();
  }, [refreshNotifications]);

  return {
    notifications,
    unreadCount,
    loading,
    error,
    refreshNotifications,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    clearAllNotifications,
    sendNotification,
    getUnreadNotifications,
    getNotificationsByType,
  };
};

/**
 * Hook pour obtenir une notification spécifique par ID
 */
export const useNotification = (notificationId: string | null) => {
  const { notifications, loading } = useNotifications();
  const notification = notifications.find(n => n.id === notificationId) || null;

  return {
    notification,
    loading: loading && !!notificationId,
  };
};

/**
 * Hook pour obtenir les notifications récentes
 */
export const useRecentNotifications = (limit: number = 5) => {
  const { notifications } = useNotifications();

  const recentNotifications = notifications
    .sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    )
    .slice(0, limit);

  return {
    recentNotifications,
  };
};

/**
 * Hook pour écouter les nouvelles notifications en temps réel
 */
export const useRealtimeNotifications = () => {
  const { user } = useAuth();
  const { refreshNotifications } = useNotifications();

  useEffect(() => {
    if (!user) {
      return;
    }

    // Ici, on pourrait implémenter l'écoute en temps réel avec Supabase
    // Pour l'instant, on rafraîchit périodiquement
    const interval = setInterval(() => {
      refreshNotifications();
    }, 30000); // Rafraîchir toutes les 30 secondes

    return () => clearInterval(interval);
  }, [user, refreshNotifications]);
};
