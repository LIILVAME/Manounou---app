import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import { Platform } from 'react-native';
import { supabase } from '../config/supabase';
import posthog from '../config/posthog';

// Configuration des notifications
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
    shouldShowBanner: true,
    shouldShowList: true,
  }),
});

export interface NotificationData {
  id?: string;
  title: string;
  body: string;
  data?: Record<string, any>;
  scheduledDate?: Date;
  userId?: string;
  type?:
    | 'event_reminder'
    | 'relationship_request'
    | 'document_shared'
    | 'general';
}

/**
 * Demander les permissions pour les notifications
 */
export const requestNotificationPermissions = async (): Promise<boolean> => {
  try {
    if (!Device.isDevice) {
      console.warn(
        'Les notifications push ne fonctionnent que sur un appareil physique'
      );
      return false;
    }

    const { status: existingStatus } =
      await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;

    if (existingStatus !== 'granted') {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }

    if (finalStatus !== 'granted') {
      console.warn('Permission de notification refusée');
      return false;
    }

    // Configuration pour Android
    if (Platform.OS === 'android') {
      await Notifications.setNotificationChannelAsync('default', {
        name: 'Notifications Manounou',
        importance: Notifications.AndroidImportance.MAX,
        vibrationPattern: [0, 250, 250, 250],
        lightColor: '#FF231F7C',
        sound: 'default',
      });
    }

    return true;
  } catch (error) {
    console.error('Erreur lors de la demande de permissions:', error);
    return false;
  }
};

/**
 * Obtenir le token de notification push
 */
export const getNotificationToken = async (): Promise<string | null> => {
  try {
    if (!Device.isDevice) {
      return null;
    }

    const token = await Notifications.getExpoPushTokenAsync({
      projectId: process.env.EXPO_PROJECT_ID,
    });

    return token.data;
  } catch (error) {
    console.error("Erreur lors de l'obtention du token:", error);
    return null;
  }
};

/**
 * Enregistrer le token de notification pour un utilisateur
 */
export const registerNotificationToken = async (
  userId: string
): Promise<void> => {
  try {
    const hasPermission = await requestNotificationPermissions();
    if (!hasPermission) {
      return;
    }

    const token = await getNotificationToken();
    if (!token) {
      return;
    }

    // Sauvegarder le token dans la base de données
    const { error } = await supabase.from('user_notification_tokens').upsert({
      user_id: userId,
      token: token,
      platform: Platform.OS,
      updated_at: new Date().toISOString(),
    });

    if (error) {
      console.error("Erreur lors de l'enregistrement du token:", error);
    } else {
      console.log('Token de notification enregistré avec succès');

      // Tracker l'événement
      try {
        posthog.capture('notification_token_registered', {
          platform: Platform.OS,
        });
      } catch (e) {
        console.error('Erreur PostHog:', e);
      }
    }
  } catch (error) {
    console.error("Erreur lors de l'enregistrement du token:", error);
  }
};

/**
 * Programmer une notification locale
 */
export const scheduleLocalNotification = async (
  notificationData: NotificationData
): Promise<string | null> => {
  try {
    const hasPermission = await requestNotificationPermissions();
    if (!hasPermission) {
      return null;
    }

    const notificationId = await Notifications.scheduleNotificationAsync({
      content: {
        title: notificationData.title,
        body: notificationData.body,
        data: notificationData.data || {},
        sound: 'default',
      },
      trigger: notificationData.scheduledDate
        ? notificationData.scheduledDate
        : null,
    });

    // Tracker l'événement
    try {
      posthog.capture('local_notification_scheduled', {
        type: notificationData.type || 'general',
        scheduled: !!notificationData.scheduledDate,
      });
    } catch (e) {
      console.error('Erreur PostHog:', e);
    }

    return notificationId;
  } catch (error) {
    console.error('Erreur lors de la programmation de la notification:', error);
    return null;
  }
};

/**
 * Envoyer une notification immédiate
 */
export const sendImmediateNotification = async (
  notificationData: NotificationData
): Promise<string | null> => {
  return scheduleLocalNotification({
    ...notificationData,
    scheduledDate: undefined,
  });
};

/**
 * Annuler une notification programmée
 */
export const cancelNotification = async (
  notificationId: string
): Promise<void> => {
  try {
    await Notifications.cancelScheduledNotificationAsync(notificationId);
  } catch (error) {
    console.error("Erreur lors de l'annulation de la notification:", error);
  }
};

/**
 * Annuler toutes les notifications programmées
 */
export const cancelAllNotifications = async (): Promise<void> => {
  try {
    await Notifications.cancelAllScheduledNotificationsAsync();
  } catch (error) {
    console.error("Erreur lors de l'annulation des notifications:", error);
  }
};

/**
 * Programmer un rappel d'événement
 */
export const scheduleEventReminder = async (
  eventId: string,
  eventTitle: string,
  eventDate: Date,
  reminderMinutes: number = 30
): Promise<string | null> => {
  const reminderDate = new Date(
    eventDate.getTime() - reminderMinutes * 60 * 1000
  );

  // Ne pas programmer si la date est dans le passé
  if (reminderDate <= new Date()) {
    return null;
  }

  return scheduleLocalNotification({
    title: "Rappel d'événement",
    body: `${eventTitle} commence dans ${reminderMinutes} minutes`,
    data: {
      eventId,
      type: 'event_reminder',
    },
    scheduledDate: reminderDate,
    type: 'event_reminder',
  });
};

/**
 * Programmer des rappels quotidiens
 */
export const scheduleDailyReminders = async (
  userId: string,
  hour: number = 9,
  minute: number = 0
): Promise<void> => {
  try {
    // Annuler les rappels existants
    await cancelAllNotifications();

    // Programmer pour les 7 prochains jours
    for (let i = 1; i <= 7; i++) {
      const reminderDate = new Date();
      reminderDate.setDate(reminderDate.getDate() + i);
      reminderDate.setHours(hour, minute, 0, 0);

      await scheduleLocalNotification({
        title: 'Manounou',
        body: "N'oubliez pas de vérifier vos événements du jour !",
        data: {
          type: 'daily_reminder',
          userId,
        },
        scheduledDate: reminderDate,
        type: 'general',
      });
    }
  } catch (error) {
    console.error(
      'Erreur lors de la programmation des rappels quotidiens:',
      error
    );
  }
};

/**
 * Obtenir les notifications programmées
 */
export const getScheduledNotifications = async (): Promise<
  Notifications.NotificationRequest[]
> => {
  try {
    return await Notifications.getAllScheduledNotificationsAsync();
  } catch (error) {
    console.error('Erreur lors de la récupération des notifications:', error);
    return [];
  }
};

/**
 * Gérer la réception d'une notification
 */
export const handleNotificationReceived = (
  notification: Notifications.Notification
): void => {
  try {
    const { data } = notification.request.content;

    // Tracker l'événement
    const eventData = {
      notification_type: String(data?.type || 'unknown'),
      notification_id: notification.request.identifier || '',
      timestamp: new Date().toISOString(),
      platform: 'mobile',
      event_source: 'notification_handler',
    };
    posthog.capture('notification_received', eventData);

    // Logique spécifique selon le type de notification
    switch (data?.type) {
      case 'event_reminder':
        // Gérer les rappels d'événements
        break;
      case 'relationship_request':
        // Gérer les demandes de relation
        break;
      case 'document_shared':
        // Gérer le partage de documents
        break;
      default:
        // Notification générale
        break;
    }
  } catch (error) {
    console.error('Erreur lors du traitement de la notification:', error);
  }
};

/**
 * Gérer l'interaction avec une notification
 */
export const handleNotificationResponse = (
  response: Notifications.NotificationResponse
): void => {
  try {
    const { data } = response.notification.request.content;

    // Tracker l'événement
    const eventData = {
      notification_type: String(data?.type || 'unknown'),
      actionIdentifier: response.actionIdentifier || 'default',
      notification_id: response.notification.request.identifier || '',
      timestamp: new Date().toISOString(),
      platform: 'mobile',
      event_source: 'notification_response',
    };
    posthog.capture('notification_tapped', eventData);

    // Navigation ou actions spécifiques selon le type
    switch (data?.type) {
      case 'event_reminder':
        // Naviguer vers l'événement
        if (data?.eventId) {
          // Navigation logic here
        }
        break;
      case 'relationship_request':
        // Naviguer vers les demandes
        break;
      case 'document_shared':
        // Naviguer vers les documents
        break;
      default:
        // Action par défaut
        break;
    }
  } catch (error) {
    console.error('Erreur lors du traitement de la réponse:', error);
  }
};

/**
 * Nettoyer les tokens de notification expirés
 */
export const cleanupExpiredTokens = async (): Promise<void> => {
  try {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const { error } = await supabase
      .from('user_notification_tokens')
      .delete()
      .lt('updated_at', thirtyDaysAgo.toISOString());

    if (error) {
      console.error('Erreur lors du nettoyage des tokens:', error);
    }
  } catch (error) {
    console.error('Erreur lors du nettoyage des tokens:', error);
  }
};
