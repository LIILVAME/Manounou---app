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
import { Vacation } from '../../types';

interface VacationsScreenProps {
  navigation: any;
}

const VacationsScreen: React.FC<VacationsScreenProps> = ({ navigation }) => {
  const { user } = useAuth();
  const { t } = useI18n();
  const [vacations, setVacations] = useState<Vacation[]>([]);
  const [selectedStatus, setSelectedStatus] = useState<string>('all');
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadVacations();
  }, []);

  const loadVacations = async () => {
    try {
      setLoading(true);

      // Mock data for vacations
      const mockVacations: Vacation[] = [
        {
          id: '1',
          userId: user?.id || '',
          startDate: new Date('2024-02-15'),
          endDate: new Date('2024-02-22'),
          reason: 'Vacances familiales',
          status: 'approved',
          createdAt: new Date('2024-01-15'),
        },
        {
          id: '2',
          userId: user?.id || '',
          startDate: new Date('2024-03-10'),
          endDate: new Date('2024-03-12'),
          reason: 'Week-end prolongé',
          status: 'pending',
          createdAt: new Date('2024-01-20'),
        },
        {
          id: '3',
          userId: user?.id || '',
          startDate: new Date('2024-01-05'),
          endDate: new Date('2024-01-08'),
          reason: "Congés de fin d'année",
          status: 'approved',
          createdAt: new Date('2023-12-15'),
        },
        {
          id: '4',
          userId: user?.id || '',
          startDate: new Date('2024-04-01'),
          endDate: new Date('2024-04-05'),
          reason: 'Vacances de Pâques',
          status: 'rejected',
          createdAt: new Date('2024-01-25'),
        },
      ];
      setVacations(mockVacations);
    } catch (error) {
      Alert.alert(t('common.error'), t('errors.loadVacations'));
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadVacations();
    setRefreshing(false);
  };

  const getFilteredVacations = () => {
    let filtered = vacations;

    // Filter by status
    if (selectedStatus !== 'all') {
      filtered = filtered.filter(
        (vacation: Vacation) => vacation.status === selectedStatus
      );
    }

    // Sort by start date (newest first)
    return filtered.sort(
      (a: Vacation, b: Vacation) =>
        new Date(b.startDate).getTime() - new Date(a.startDate).getTime()
    );
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved':
        return colors.success;
      case 'pending':
        return colors.warning;
      case 'rejected':
        return colors.error;
      default:
        return colors.textSecondary;
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'approved':
        return 'check-circle';
      case 'pending':
        return 'clock';
      case 'rejected':
        return 'close-circle';
      default:
        return 'help-circle';
    }
  };

  const calculateDuration = (startDate: Date, endDate: Date) => {
    const diffTime = Math.abs(endDate.getTime() - startDate.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
    return diffDays;
  };

  const handleEditVacation = (vacation: Vacation) => {
    if (vacation.status === 'pending') {
      navigation.navigate('EditVacation', { vacationId: vacation.id });
    } else {
      Alert.alert(t('vacations.cannotEdit'), t('vacations.cannotEditMessage'));
    }
  };

  const handleDeleteVacation = (vacation: Vacation) => {
    if (vacation.status === 'pending') {
      Alert.alert(
        t('vacations.deleteConfirmTitle'),
        t('vacations.deleteConfirmMessage'),
        [
          {
            text: t('common.cancel'),
            style: 'cancel',
          },
          {
            text: t('common.delete'),
            style: 'destructive',
            onPress: () => deleteVacation(vacation.id),
          },
        ]
      );
    } else {
      Alert.alert(
        t('vacations.cannotDelete'),
        t('vacations.cannotDeleteMessage')
      );
    }
  };

  const deleteVacation = async (vacationId: string) => {
    try {
      setVacations((prev: Vacation[]) =>
        prev.filter((vacation: Vacation) => vacation.id !== vacationId)
      );
      Alert.alert(t('common.success'), t('vacations.deleteSuccess'));
    } catch (error) {
      Alert.alert(t('common.error'), t('errors.deleteVacation'));
    }
  };

  const renderVacationCard = (vacation: Vacation) => {
    const duration = calculateDuration(vacation.startDate, vacation.endDate);
    const canEdit = vacation.status === 'pending';
    const isPast = vacation.endDate < new Date();

    return (
      <Card key={vacation.id} style={styles.vacationCard}>
        <Card.Content>
          <View style={styles.vacationHeader}>
            <View style={styles.vacationInfo}>
              <View style={styles.titleRow}>
                <Title style={styles.vacationTitle}>
                  {vacation.startDate.toLocaleDateString()} -{' '}
                  {vacation.endDate.toLocaleDateString()}
                </Title>
                <Chip
                  icon={getStatusIcon(vacation.status)}
                  style={[
                    styles.statusChip,
                    { backgroundColor: getStatusColor(vacation.status) + '20' },
                  ]}
                  textStyle={[
                    styles.statusText,
                    { color: getStatusColor(vacation.status) },
                  ]}
                >
                  {t(`vacations.status.${vacation.status}`)}
                </Chip>
              </View>

              <Text style={styles.duration}>
                {t('vacations.duration', { days: duration.toString() })}
              </Text>

              {vacation.reason && (
                <Text style={styles.reason}>{vacation.reason}</Text>
              )}

              <Text style={styles.createdDate}>
                {t('vacations.requestedOn')}{' '}
                {vacation.createdAt.toLocaleDateString()}
              </Text>
            </View>

            {canEdit && (
              <View style={styles.vacationActions}>
                <IconButton
                  icon="pencil"
                  size={20}
                  onPress={() => handleEditVacation(vacation)}
                />
                <IconButton
                  icon="delete"
                  size={20}
                  iconColor={colors.error}
                  onPress={() => handleDeleteVacation(vacation)}
                />
              </View>
            )}
          </View>

          {/* Additional info for past vacations */}
          {isPast && vacation.status === 'approved' && (
            <View style={styles.pastVacationInfo}>
              <Text style={styles.pastVacationText}>
                {t('vacations.completed')}
              </Text>
            </View>
          )}
        </Card.Content>
      </Card>
    );
  };

  const filteredVacations = getFilteredVacations();
  const statusOptions = ['all', 'pending', 'approved', 'rejected'];

  return (
    <View style={styles.container}>
      {/* Header with Status Filter */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>{t('vacations.title')}</Text>

        <SegmentedButtons
          value={selectedStatus}
          onValueChange={(value: string) => setSelectedStatus(value)}
          buttons={statusOptions.map(status => ({
            value: status,
            label: t(`vacations.status.${status}`),
            icon: status !== 'all' ? getStatusIcon(status) : undefined,
          }))}
          style={styles.statusFilter}
        />
      </View>

      {/* Vacations List */}
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
        ) : filteredVacations.length > 0 ? (
          <View style={styles.vacationsContainer}>
            {filteredVacations.map(renderVacationCard)}
          </View>
        ) : (
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>
              {selectedStatus === 'all'
                ? t('vacations.noVacations')
                : t('vacations.noVacationsForStatus', {
                    status: t(`vacations.status.${selectedStatus}`),
                  })}
            </Text>
            <Button
              mode="contained"
              onPress={() => navigation.navigate('AddVacation')}
              style={styles.addButton}
            >
              {t('vacations.addFirstVacation')}
            </Button>
          </View>
        )}
      </ScrollView>

      {/* Floating Action Button */}
      <FAB
        style={styles.fab}
        icon="plus"
        onPress={() => navigation.navigate('AddVacation')}
      />
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
  headerTitle: {
    ...typography.h3,
    marginBottom: spacing.md,
    textAlign: 'center',
  },
  statusFilter: {
    marginBottom: spacing.sm,
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
  vacationsContainer: {
    padding: spacing.md,
  },
  vacationCard: {
    marginBottom: spacing.md,
  },
  vacationHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  vacationInfo: {
    flex: 1,
  },
  titleRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: spacing.sm,
  },
  vacationTitle: {
    ...typography.subtitle,
    flex: 1,
    marginRight: spacing.sm,
  },
  statusChip: {
    height: 28,
  },
  statusText: {
    fontSize: 12,
    fontWeight: 'bold',
  },
  duration: {
    ...typography.body,
    color: colors.primary,
    fontWeight: '600',
    marginBottom: spacing.sm,
  },
  reason: {
    ...typography.body,
    color: colors.text,
    marginBottom: spacing.sm,
  },
  createdDate: {
    ...typography.caption,
    color: colors.textSecondary,
  },
  vacationActions: {
    flexDirection: 'row',
  },
  pastVacationInfo: {
    marginTop: spacing.md,
    padding: spacing.sm,
    backgroundColor: colors.success + '20',
    borderRadius: 8,
  },
  pastVacationText: {
    ...typography.caption,
    color: colors.success,
    fontWeight: 'bold',
    textAlign: 'center',
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

export default VacationsScreen;
