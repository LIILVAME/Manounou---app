import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import {
  Text,
  Card,
  Title,
  Paragraph,
  Button,
  Avatar,
  Chip,
  FAB,
} from 'react-native-paper';
import { useAuth } from '../../contexts/AuthContext';
import { useI18n } from '../../contexts/I18nContext';
import { colors, spacing, typography } from '../../constants/theme';
import { Child, Schedule, Notification } from '../../types';

interface DashboardScreenProps {
  navigation: any;
}

const DashboardScreen: React.FC<DashboardScreenProps> = ({ navigation }) => {
  const { user } = useAuth();
  const { t } = useI18n();
  const [children, setChildren] = useState<Child[]>([]);
  const [todaySchedule, setTodaySchedule] = useState<Schedule[]>([]);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      // Simulate API calls
      // In real app, these would be actual API calls
      setChildren([
        {
          id: '1',
          firstName: 'Emma',
          lastName: 'Martin',
          birthDate: new Date('2020-03-15'),
          allergies: ['Arachides'],
          medicalInfo: 'RAS',
          photo: undefined,
          parentId: user?.id || '',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ]);

      setTodaySchedule([
        {
          id: '1',
          childId: '1',
          date: new Date(),
          startTime: '08:00',
          endTime: '18:00',
          activities: [
            {
              id: '1',
              name: 'Petit déjeuner',
              time: '08:30',
              description: 'Céréales et fruits',
              type: 'meal',
            },
            {
              id: '2',
              name: 'Sieste',
              time: '14:00',
              description: '1h30 de repos',
              type: 'other',
            },
          ],
          notes: 'Journée normale',
          status: 'planned',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ]);

      setNotifications([
        {
          id: '1',
          userId: user?.id || '',
          title: 'Planning mis à jour',
          message: "Le planning d'Emma a été modifié pour demain",
          type: 'info',
          read: false,
          createdAt: new Date(),
        },
      ]);
    } catch (error) {
      console.error('Error loading dashboard data:', error);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadDashboardData();
    setRefreshing(false);
  };

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) {
      return t('dashboard.goodMorning');
    }
    if (hour < 18) {
      return t('dashboard.goodAfternoon');
    }
    return t('dashboard.goodEvening');
  };

  const unreadNotifications = notifications.filter(n => !n.read).length;

  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.userInfo}>
            <Avatar.Text
              size={50}
              label={
                user?.displayName
                  ? user.displayName.substring(0, 2).toUpperCase()
                  : 'U'
              }
              style={styles.avatar}
            />
            <View style={styles.greetingContainer}>
              <Text style={styles.greeting}>{getGreeting()}</Text>
              <Text style={styles.userName}>
                {user?.displayName || 'Utilisateur'}
              </Text>
              <Chip
                mode="outlined"
                style={styles.roleChip}
                textStyle={styles.roleChipText}
              >
                {t(`roles.${user?.role}`)}
              </Chip>
            </View>
          </View>
          {unreadNotifications > 0 && (
            <Button
              mode="text"
              onPress={() => navigation.navigate('Notifications')}
              style={styles.notificationButton}
            >
              {unreadNotifications} {t('dashboard.newNotifications')}
            </Button>
          )}
        </View>

        {/* Quick Stats */}
        <View style={styles.statsContainer}>
          <Card style={styles.statCard}>
            <Card.Content style={styles.statContent}>
              <Text style={styles.statNumber}>{children.length}</Text>
              <Text style={styles.statLabel}>
                {user?.role === 'parent'
                  ? t('dashboard.children')
                  : t('dashboard.childrenInCare')}
              </Text>
            </Card.Content>
          </Card>
          <Card style={styles.statCard}>
            <Card.Content style={styles.statContent}>
              <Text style={styles.statNumber}>{todaySchedule.length}</Text>
              <Text style={styles.statLabel}>
                {t('dashboard.todaySchedules')}
              </Text>
            </Card.Content>
          </Card>
        </View>

        {/* Today's Schedule */}
        <Card style={styles.card}>
          <Card.Content>
            <Title style={styles.cardTitle}>
              {t('dashboard.todaySchedule')}
            </Title>
            {todaySchedule.length > 0 ? (
              todaySchedule.map(schedule => (
                <View key={schedule.id} style={styles.scheduleItem}>
                  <Text style={styles.scheduleTime}>
                    {schedule.startTime} - {schedule.endTime}
                  </Text>
                  <Text style={styles.scheduleChild}>
                    {children.find(c => c.id === schedule.childId)?.firstName}
                  </Text>
                  <Text style={styles.scheduleActivities}>
                    {schedule.activities.length} {t('dashboard.activities')}
                  </Text>
                </View>
              ))
            ) : (
              <Paragraph>{t('dashboard.noScheduleToday')}</Paragraph>
            )}
            <Button
              mode="outlined"
              onPress={() => navigation.navigate('Planning')}
              style={styles.cardButton}
            >
              {t('dashboard.viewFullPlanning')}
            </Button>
          </Card.Content>
        </Card>

        {/* Recent Notifications */}
        {notifications.length > 0 && (
          <Card style={styles.card}>
            <Card.Content>
              <Title style={styles.cardTitle}>
                {t('dashboard.recentNotifications')}
              </Title>
              {notifications.slice(0, 3).map(notification => (
                <View key={notification.id} style={styles.notificationItem}>
                  <View style={styles.notificationContent}>
                    <Text style={styles.notificationTitle}>
                      {notification.title}
                    </Text>
                    <Text style={styles.notificationMessage}>
                      {notification.message}
                    </Text>
                  </View>
                  {!notification.read && (
                    <View style={styles.unreadIndicator} />
                  )}
                </View>
              ))}
              <Button
                mode="outlined"
                onPress={() => navigation.navigate('Notifications')}
                style={styles.cardButton}
              >
                {t('dashboard.viewAllNotifications')}
              </Button>
            </Card.Content>
          </Card>
        )}

        {/* Quick Actions */}
        <Card style={styles.card}>
          <Card.Content>
            <Title style={styles.cardTitle}>
              {t('dashboard.quickActions')}
            </Title>
            <View style={styles.quickActions}>
              <Button
                mode="contained"
                onPress={() => navigation.navigate('Children')}
                style={styles.actionButton}
              >
                {user?.role === 'parent'
                  ? t('dashboard.manageChildren')
                  : t('dashboard.viewChildren')}
              </Button>
              <Button
                mode="contained"
                onPress={() => navigation.navigate('Documents')}
                style={styles.actionButton}
              >
                {t('dashboard.documents')}
              </Button>
              <Button
                mode="contained"
                onPress={() => navigation.navigate('Vacations')}
                style={styles.actionButton}
              >
                {t('dashboard.vacations')}
              </Button>
            </View>
          </Card.Content>
        </Card>
      </ScrollView>

      {/* Floating Action Button */}
      <FAB
        style={styles.fab}
        icon="plus"
        onPress={() => {
          if (user?.role === 'parent') {
            navigation.navigate('AddChild');
          } else {
            navigation.navigate('AddSchedule');
          }
        }}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  scrollView: {
    flex: 1,
  },
  header: {
    padding: spacing.lg,
    backgroundColor: colors.primary,
  },
  userInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  avatar: {
    backgroundColor: colors.secondary,
  },
  greetingContainer: {
    marginLeft: spacing.md,
    flex: 1,
  },
  greeting: {
    ...typography.body,
    color: colors.onPrimary,
    opacity: 0.8,
  },
  userName: {
    ...typography.h3,
    color: colors.onPrimary,
    marginTop: spacing.xs,
  },
  roleChip: {
    alignSelf: 'flex-start',
    marginTop: spacing.sm,
    backgroundColor: colors.secondary,
  },
  roleChipText: {
    color: colors.onSecondary,
    fontSize: 12,
  },
  notificationButton: {
    alignSelf: 'flex-end',
  },
  statsContainer: {
    flexDirection: 'row',
    padding: spacing.lg,
    paddingTop: spacing.md,
    gap: spacing.md,
  },
  statCard: {
    flex: 1,
  },
  statContent: {
    alignItems: 'center',
  },
  statNumber: {
    ...typography.h2,
    color: colors.primary,
    fontWeight: 'bold',
  },
  statLabel: {
    ...typography.caption,
    color: colors.textSecondary,
    textAlign: 'center',
    marginTop: spacing.xs,
  },
  card: {
    margin: spacing.lg,
    marginTop: 0,
  },
  cardTitle: {
    ...typography.h4,
    marginBottom: spacing.md,
  },
  cardButton: {
    marginTop: spacing.md,
  },
  scheduleItem: {
    padding: spacing.md,
    backgroundColor: colors.surface,
    borderRadius: 8,
    marginBottom: spacing.sm,
  },
  scheduleTime: {
    ...typography.subtitle,
    fontWeight: 'bold',
    color: colors.primary,
  },
  scheduleChild: {
    ...typography.body,
    marginTop: spacing.xs,
  },
  scheduleActivities: {
    ...typography.caption,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
  notificationItem: {
    flexDirection: 'row',
    padding: spacing.md,
    backgroundColor: colors.surface,
    borderRadius: 8,
    marginBottom: spacing.sm,
  },
  notificationContent: {
    flex: 1,
  },
  notificationTitle: {
    ...typography.subtitle,
    fontWeight: 'bold',
  },
  notificationMessage: {
    ...typography.caption,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
  unreadIndicator: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: colors.error,
    marginLeft: spacing.sm,
    alignSelf: 'center',
  },
  quickActions: {
    gap: spacing.sm,
  },
  actionButton: {
    marginBottom: spacing.sm,
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
    backgroundColor: colors.primary,
  },
});

export default DashboardScreen;
