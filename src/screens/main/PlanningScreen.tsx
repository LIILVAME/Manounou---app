import React, { useState, useEffect } from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  Alert,
  RefreshControl,
} from 'react-native';
import {
  Text,
  Card,
  Title,
  Paragraph,
  Button,
  IconButton,
  Chip,
  FAB,
  SegmentedButtons,
} from 'react-native-paper';
import { useAuth } from '../../contexts/AuthContext';
import { useI18n } from '../../contexts/I18nContext';
import { colors, spacing, typography } from '../../constants/theme';
import { Schedule, Child, Activity } from '../../types';

interface PlanningScreenProps {
  navigation: any;
  route?: {
    params?: {
      childId?: string;
    };
  };
}

const PlanningScreen: React.FC<PlanningScreenProps> = ({
  navigation,
  route,
}) => {
  const { user } = useAuth();
  const { t } = useI18n();
  const [schedules, setSchedules] = useState<Schedule[]>([]);
  const [children, setChildren] = useState<Child[]>([]);
  const [selectedChild, setSelectedChild] = useState<string>('all');
  const [viewMode, setViewMode] = useState<'day' | 'week'>('day');
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    if (route?.params?.childId) {
      setSelectedChild(route.params.childId);
    }
  }, [route?.params?.childId]);

  const loadData = async () => {
    try {
      setLoading(true);

      // Load children
      const mockChildren: Child[] = [
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
        {
          id: '2',
          firstName: 'Lucas',
          lastName: 'Martin',
          birthDate: new Date('2018-07-22'),
          allergies: [],
          medicalInfo: 'RAS',
          photo: undefined,
          parentId: user?.id || '',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];
      setChildren(mockChildren);

      // Load schedules
      const mockSchedules: Schedule[] = [
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
              name: 'Jeu libre',
              time: '09:30',
              description: 'Jeux éducatifs',
              type: 'play',
            },
            {
              id: '3',
              name: 'Sortie parc',
              time: '10:30',
              description: 'Parc de la ville',
              type: 'outing',
            },
            {
              id: '4',
              name: 'Déjeuner',
              time: '12:00',
              description: 'Pâtes et légumes',
              type: 'meal',
            },
            {
              id: '5',
              name: 'Sieste',
              time: '14:00',
              description: '1h30 de repos',
              type: 'nap',
            },
            {
              id: '6',
              name: 'Goûter',
              time: '16:00',
              description: 'Fruits et biscuits',
              type: 'meal',
            },
          ],
          notes: 'Journée normale, Emma est en forme',
          status: 'planned' as const,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];
      setSchedules(mockSchedules);
    } catch (error) {
      Alert.alert(t('common.error'), t('errors.loadPlanning'));
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const getFilteredSchedules = () => {
    let filtered = schedules;

    // Filter by child
    if (selectedChild !== 'all') {
      filtered = filtered.filter(
        schedule => schedule.childId === selectedChild
      );
    }

    // Filter by date
    if (viewMode === 'day') {
      filtered = filtered.filter(schedule => {
        const scheduleDate = new Date(schedule.date);
        return scheduleDate.toDateString() === selectedDate.toDateString();
      });
    } else {
      // Week view - get schedules for the current week
      const startOfWeek = new Date(selectedDate);
      startOfWeek.setDate(selectedDate.getDate() - selectedDate.getDay());
      const endOfWeek = new Date(startOfWeek);
      endOfWeek.setDate(startOfWeek.getDate() + 6);

      filtered = filtered.filter(schedule => {
        const scheduleDate = new Date(schedule.date);
        return scheduleDate >= startOfWeek && scheduleDate <= endOfWeek;
      });
    }

    return filtered;
  };

  const getActivityIcon = (type: string) => {
    switch (type) {
      case 'meal':
        return 'food';
      case 'nap':
        return 'sleep';
      case 'play':
        return 'toy-brick';
      case 'outing':
        return 'tree';
      case 'learning':
        return 'book';
      default:
        return 'clock';
    }
  };

  const getActivityColor = (type: string) => {
    switch (type) {
      case 'meal':
        return colors.success;
      case 'nap':
        return colors.info;
      case 'play':
        return colors.warning;
      case 'outing':
        return colors.primary;
      case 'learning':
        return colors.secondary;
      default:
        return colors.textSecondary;
    }
  };

  const handleEditSchedule = (schedule: Schedule) => {
    navigation.navigate('EditSchedule', { scheduleId: schedule.id });
  };

  const handleDeleteSchedule = (schedule: Schedule) => {
    Alert.alert(
      t('planning.deleteConfirmTitle'),
      t('planning.deleteConfirmMessage'),
      [
        {
          text: t('common.cancel'),
          style: 'cancel',
        },
        {
          text: t('common.delete'),
          style: 'destructive',
          onPress: () => deleteSchedule(schedule.id),
        },
      ]
    );
  };

  const deleteSchedule = async (scheduleId: string) => {
    try {
      setSchedules((prev: Schedule[]) =>
        prev.filter((schedule: Schedule) => schedule.id !== scheduleId)
      );
      Alert.alert(t('common.success'), t('planning.deleteSuccess'));
    } catch (error) {
      Alert.alert(t('common.error'), t('errors.deleteSchedule'));
    }
  };

  const navigateDate = (direction: 'prev' | 'next') => {
    const newDate = new Date(selectedDate);
    if (viewMode === 'day') {
      newDate.setDate(selectedDate.getDate() + (direction === 'next' ? 1 : -1));
    } else {
      newDate.setDate(selectedDate.getDate() + (direction === 'next' ? 7 : -7));
    }
    setSelectedDate(newDate);
  };

  const renderScheduleCard = (schedule: Schedule) => {
    const child = children.find((c: Child) => c.id === schedule.childId);
    const canEdit = user?.role === 'parent' || user?.role === 'nounou';

    return (
      <Card key={schedule.id} style={styles.scheduleCard}>
        <Card.Content>
          <View style={styles.scheduleHeader}>
            <View style={styles.scheduleInfo}>
              <Title style={styles.scheduleTitle}>
                {child?.firstName} {child?.lastName}
              </Title>
              <Text style={styles.scheduleTime}>
                {schedule.startTime} - {schedule.endTime}
              </Text>
              <Text style={styles.scheduleDate}>
                {schedule.date.toLocaleDateString()}
              </Text>
            </View>
            {canEdit && (
              <View style={styles.scheduleActions}>
                <IconButton
                  icon="pencil"
                  size={20}
                  onPress={() => handleEditSchedule(schedule)}
                />
                <IconButton
                  icon="delete"
                  size={20}
                  iconColor={colors.error}
                  onPress={() => handleDeleteSchedule(schedule)}
                />
              </View>
            )}
          </View>

          {/* Activities */}
          <View style={styles.activitiesSection}>
            <Text style={styles.sectionTitle}>{t('planning.activities')}</Text>
            {schedule.activities.map((activity, index) => (
              <View key={activity.id} style={styles.activityItem}>
                <View style={styles.activityTime}>
                  <IconButton
                    icon={getActivityIcon(activity.type)}
                    size={16}
                    iconColor={getActivityColor(activity.type)}
                    style={styles.activityIcon}
                  />
                  <Text style={styles.activityTimeText}>{activity.time}</Text>
                </View>
                <View style={styles.activityContent}>
                  <Text style={styles.activityName}>{activity.name}</Text>
                  {activity.description && (
                    <Text style={styles.activityDescription}>
                      {activity.description}
                    </Text>
                  )}
                </View>
              </View>
            ))}
          </View>

          {/* Notes */}
          {schedule.notes && (
            <View style={styles.notesSection}>
              <Text style={styles.sectionTitle}>{t('planning.notes')}</Text>
              <Text style={styles.notesText}>{schedule.notes}</Text>
            </View>
          )}
        </Card.Content>
      </Card>
    );
  };

  const filteredSchedules = getFilteredSchedules();

  return (
    <View style={styles.container}>
      {/* Header Controls */}
      <View style={styles.header}>
        {/* View Mode Toggle */}
        <SegmentedButtons
          value={viewMode}
          onValueChange={(value: string) =>
            setViewMode(value as 'day' | 'week')
          }
          buttons={[
            {
              value: 'day',
              label: t('planning.dayView'),
            },
            {
              value: 'week',
              label: t('planning.weekView'),
            },
          ]}
          style={styles.viewModeToggle}
        />

        {/* Date Navigation */}
        <View style={styles.dateNavigation}>
          <IconButton
            icon="chevron-left"
            onPress={() => navigateDate('prev')}
          />
          <Text style={styles.dateText}>
            {viewMode === 'day'
              ? selectedDate.toLocaleDateString()
              : `${t('planning.week')} ${selectedDate.toLocaleDateString()}`}
          </Text>
          <IconButton
            icon="chevron-right"
            onPress={() => navigateDate('next')}
          />
        </View>

        {/* Child Filter */}
        {children.length > 1 && (
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            style={styles.childFilter}
          >
            <Chip
              selected={selectedChild === 'all'}
              onPress={() => setSelectedChild('all')}
              style={styles.filterChip}
            >
              {t('planning.allChildren')}
            </Chip>
            {children.map((child: Child) => (
              <Chip
                key={child.id}
                selected={selectedChild === child.id}
                onPress={() => setSelectedChild(child.id)}
                style={styles.filterChip}
              >
                {child.firstName}
              </Chip>
            ))}
          </ScrollView>
        )}
      </View>

      {/* Schedules List */}
      <ScrollView
        style={styles.scrollView}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        {loading ? (
          <View style={styles.loadingContainer}>
            <Text>{t('common.loading')}</Text>
          </View>
        ) : filteredSchedules.length > 0 ? (
          <View style={styles.schedulesContainer}>
            {filteredSchedules.map(renderScheduleCard)}
          </View>
        ) : (
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>{t('planning.noSchedules')}</Text>
            {user?.role === 'parent' && (
              <Button
                mode="contained"
                onPress={() => navigation.navigate('AddSchedule')}
                style={styles.addButton}
              >
                {t('planning.addFirstSchedule')}
              </Button>
            )}
          </View>
        )}
      </ScrollView>

      {/* Floating Action Button */}
      {(user?.role === 'parent' || user?.role === 'nounou') && (
        <FAB
          style={styles.fab}
          icon="plus"
          onPress={() => navigation.navigate('AddSchedule')}
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    backgroundColor: colors.surface,
    padding: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  viewModeToggle: {
    marginBottom: spacing.md,
  },
  dateNavigation: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.md,
  },
  dateText: {
    ...typography.subtitle,
    fontWeight: 'bold',
    marginHorizontal: spacing.md,
  },
  childFilter: {
    flexDirection: 'row',
  },
  filterChip: {
    marginRight: spacing.sm,
  },
  scrollView: {
    flex: 1,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.xl,
  },
  schedulesContainer: {
    padding: spacing.md,
  },
  scheduleCard: {
    marginBottom: spacing.md,
  },
  scheduleHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: spacing.md,
  },
  scheduleInfo: {
    flex: 1,
  },
  scheduleTitle: {
    ...typography.h4,
    marginBottom: spacing.xs,
  },
  scheduleTime: {
    ...typography.body,
    color: colors.primary,
    fontWeight: '600',
  },
  scheduleDate: {
    ...typography.caption,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
  scheduleActions: {
    flexDirection: 'row',
  },
  activitiesSection: {
    marginBottom: spacing.md,
  },
  sectionTitle: {
    ...typography.subtitle,
    fontWeight: 'bold',
    marginBottom: spacing.sm,
  },
  activityItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: spacing.sm,
    paddingVertical: spacing.xs,
  },
  activityTime: {
    flexDirection: 'row',
    alignItems: 'center',
    width: 80,
  },
  activityIcon: {
    margin: 0,
    width: 24,
    height: 24,
  },
  activityTimeText: {
    ...typography.caption,
    fontWeight: 'bold',
    marginLeft: spacing.xs,
  },
  activityContent: {
    flex: 1,
    marginLeft: spacing.sm,
  },
  activityName: {
    ...typography.body,
    fontWeight: '600',
  },
  activityDescription: {
    ...typography.caption,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
  notesSection: {
    marginTop: spacing.sm,
  },
  notesText: {
    ...typography.body,
    color: colors.textSecondary,
    backgroundColor: colors.background,
    padding: spacing.sm,
    borderRadius: 8,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.xl,
  },
  emptyText: {
    ...typography.body,
    color: colors.textSecondary,
    textAlign: 'center',
    marginBottom: spacing.lg,
  },
  addButton: {
    marginTop: spacing.md,
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
    backgroundColor: colors.primary,
  },
});

export default PlanningScreen;
