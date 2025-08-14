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
  Avatar,
  IconButton,
  Chip,
  FAB,
  Searchbar,
} from 'react-native-paper';
import { useAuth } from '../../contexts/AuthContext';
import { useI18n } from '../../contexts/I18nContext';
import { colors, spacing, typography } from '../../constants/theme';
import { Child } from '../../types';

interface ChildrenScreenProps {
  navigation: any;
}

const ChildrenScreen: React.FC<ChildrenScreenProps> = ({ navigation }) => {
  const { user } = useAuth();
  const { t } = useI18n();
  const [children, setChildren] = useState<Child[]>([]);
  const [filteredChildren, setFilteredChildren] = useState<Child[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadChildren();
  }, []);

  useEffect(() => {
    filterChildren();
  }, [children, searchQuery]);

  const loadChildren = async () => {
    try {
      setLoading(true);
      // Simulate API call
      const mockChildren: Child[] = [
        {
          id: '1',
          firstName: 'Emma',
          lastName: 'Martin',
          birthDate: new Date('2020-03-15'),
          allergies: ['Arachides', 'Lactose'],
          medicalInfo: 'Asthme léger - inhalateur en cas de crise',
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
    } catch (error) {
      Alert.alert(t('common.error'), t('errors.loadChildren'));
    } finally {
      setLoading(false);
    }
  };

  const filterChildren = () => {
    if (!searchQuery.trim()) {
      setFilteredChildren(children);
    } else {
      const filtered = children.filter(child =>
        `${child.firstName} ${child.lastName}`
          .toLowerCase()
          .includes(searchQuery.toLowerCase())
      );
      setFilteredChildren(filtered);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadChildren();
    setRefreshing(false);
  };

  const calculateAge = (birthDate: Date) => {
    const today = new Date();
    const birth = new Date(birthDate);
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();

    if (
      monthDiff < 0 ||
      (monthDiff === 0 && today.getDate() < birth.getDate())
    ) {
      age--;
    }

    return age;
  };

  const handleEditChild = (child: Child) => {
    navigation.navigate('EditChild', { childId: child.id });
  };

  const handleDeleteChild = (child: Child) => {
    Alert.alert(
      t('children.deleteConfirmTitle'),
      t('children.deleteConfirmMessage', { name: child.firstName }),
      [
        {
          text: t('common.cancel'),
          style: 'cancel',
        },
        {
          text: t('common.delete'),
          style: 'destructive',
          onPress: () => deleteChild(child.id),
        },
      ]
    );
  };

  const deleteChild = async (childId: string) => {
    try {
      // Simulate API call
      setChildren(prev => prev.filter(child => child.id !== childId));
      Alert.alert(t('common.success'), t('children.deleteSuccess'));
    } catch (error) {
      Alert.alert(t('common.error'), t('errors.deleteChild'));
    }
  };

  const renderChildCard = (child: Child) => {
    const age = calculateAge(child.birthDate);
    const canEdit = user?.role === 'parent';

    return (
      <Card key={child.id} style={styles.childCard}>
        <Card.Content>
          <View style={styles.childHeader}>
            <View style={styles.childInfo}>
              <Avatar.Text
                size={60}
                label={`${child.firstName[0]}${child.lastName[0]}`}
                style={styles.childAvatar}
              />
              <View style={styles.childDetails}>
                <Title style={styles.childName}>
                  {child.firstName} {child.lastName}
                </Title>
                <Text style={styles.childAge}>
                  {age} {age > 1 ? t('children.years') : t('children.year')}
                </Text>
                <Text style={styles.birthDate}>
                  {t('children.born')} {child.birthDate.toLocaleDateString()}
                </Text>
              </View>
            </View>
            {canEdit && (
              <View style={styles.childActions}>
                <IconButton
                  icon="pencil"
                  size={20}
                  onPress={() => handleEditChild(child)}
                />
                <IconButton
                  icon="delete"
                  size={20}
                  iconColor={colors.error}
                  onPress={() => handleDeleteChild(child)}
                />
              </View>
            )}
          </View>

          {/* Medical Info */}
          {child.medicalInfo && child.medicalInfo !== 'RAS' && (
            <View style={styles.medicalSection}>
              <Text style={styles.sectionTitle}>
                {t('children.medicalInfo')}
              </Text>
              <Text style={styles.medicalText}>{child.medicalInfo}</Text>
            </View>
          )}

          {/* Allergies */}
          {child.allergies && child.allergies.length > 0 && (
            <View style={styles.allergiesSection}>
              <Text style={styles.sectionTitle}>{t('children.allergies')}</Text>
              <View style={styles.allergiesContainer}>
                {child.allergies.map((allergy, index) => (
                  <Chip
                    key={index}
                    mode="outlined"
                    style={styles.allergyChip}
                    textStyle={styles.allergyChipText}
                  >
                    {allergy}
                  </Chip>
                ))}
              </View>
            </View>
          )}

          {/* Quick Actions */}
          <View style={styles.quickActions}>
            <Button
              mode="outlined"
              compact
              onPress={() =>
                navigation.navigate('Planning', { childId: child.id })
              }
              style={styles.actionButton}
            >
              {t('children.viewPlanning')}
            </Button>
            <Button
              mode="outlined"
              compact
              onPress={() =>
                navigation.navigate('Documents', { childId: child.id })
              }
              style={styles.actionButton}
            >
              {t('children.viewDocuments')}
            </Button>
          </View>
        </Card.Content>
      </Card>
    );
  };

  return (
    <View style={styles.container}>
      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <Searchbar
          placeholder={t('children.searchPlaceholder')}
          onChangeText={setSearchQuery}
          value={searchQuery}
          style={styles.searchBar}
        />
      </View>

      {/* Children List */}
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
        ) : filteredChildren.length > 0 ? (
          <View style={styles.childrenContainer}>
            {filteredChildren.map(renderChildCard)}
          </View>
        ) : (
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>
              {searchQuery
                ? t('children.noSearchResults')
                : user?.role === 'parent'
                ? t('children.noChildrenParent')
                : t('children.noChildrenNanny')}
            </Text>
            {user?.role === 'parent' && !searchQuery && (
              <Button
                mode="contained"
                onPress={() => navigation.navigate('AddChild')}
                style={styles.addButton}
              >
                {t('children.addFirstChild')}
              </Button>
            )}
          </View>
        )}
      </ScrollView>

      {/* Floating Action Button */}
      {user?.role === 'parent' && (
        <FAB
          style={styles.fab}
          icon="plus"
          onPress={() => navigation.navigate('AddChild')}
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
  searchContainer: {
    padding: spacing.md,
    backgroundColor: colors.surface,
  },
  searchBar: {
    elevation: 0,
    backgroundColor: colors.background,
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
  childrenContainer: {
    padding: spacing.md,
  },
  childCard: {
    marginBottom: spacing.md,
  },
  childHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: spacing.md,
  },
  childInfo: {
    flexDirection: 'row',
    flex: 1,
  },
  childAvatar: {
    backgroundColor: colors.primary,
  },
  childDetails: {
    marginLeft: spacing.md,
    flex: 1,
  },
  childName: {
    ...typography.h4,
    marginBottom: spacing.xs,
  },
  childAge: {
    ...typography.body,
    color: colors.primary,
    fontWeight: '600',
  },
  birthDate: {
    ...typography.caption,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
  childActions: {
    flexDirection: 'row',
  },
  medicalSection: {
    marginBottom: spacing.md,
  },
  sectionTitle: {
    ...typography.subtitle,
    fontWeight: 'bold',
    marginBottom: spacing.xs,
  },
  medicalText: {
    ...typography.body,
    color: colors.textSecondary,
    backgroundColor: colors.warning + '20',
    padding: spacing.sm,
    borderRadius: 8,
  },
  allergiesSection: {
    marginBottom: spacing.md,
  },
  allergiesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.xs,
  },
  allergyChip: {
    backgroundColor: colors.error + '20',
    borderColor: colors.error,
  },
  allergyChipText: {
    color: colors.error,
    fontSize: 12,
  },
  quickActions: {
    flexDirection: 'row',
    gap: spacing.sm,
    marginTop: spacing.sm,
  },
  actionButton: {
    flex: 1,
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

export default ChildrenScreen;
