import React, { useState, useEffect } from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  Alert,
  RefreshControl,
  Linking,
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
  Searchbar,
  Menu,
  Divider,
} from 'react-native-paper';
import { useAuth } from '../../contexts/AuthContext';
import { useI18n } from '../../contexts/I18nContext';
import { colors, spacing, typography } from '../../constants/theme';
import { Document, Child } from '../../types';

interface DocumentsScreenProps {
  navigation: any;
  route?: {
    params?: {
      childId?: string;
    };
  };
}

const DocumentsScreen: React.FC<DocumentsScreenProps> = ({
  navigation,
  route,
}) => {
  const { user } = useAuth();
  const { t } = useI18n();
  const [documents, setDocuments] = useState<Document[]>([]);
  const [children, setChildren] = useState<Child[]>([]);
  const [selectedChild, setSelectedChild] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedType, setSelectedType] = useState<string>('all');
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [menuVisible, setMenuVisible] = useState(false);

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

      // Load documents
      const mockDocuments: Document[] = [
        {
          id: '1',
          childId: '1',
          name: 'Carnet de santé Emma',
          type: 'medical',
          url: 'https://example.com/document1.pdf',
          uploadedBy: user?.id || '',
          createdAt: new Date('2024-01-15'),
        },
        {
          id: '2',
          childId: '1',
          name: 'Autorisation sortie piscine',
          type: 'authorization',
          url: 'https://example.com/document2.pdf',
          uploadedBy: user?.id || '',
          createdAt: new Date('2024-01-10'),
        },
        {
          id: '3',
          childId: '2',
          name: 'Ordonnance Lucas',
          type: 'medical',
          url: 'https://example.com/document3.pdf',
          uploadedBy: user?.id || '',
          createdAt: new Date('2024-01-08'),
        },
        {
          id: '4',
          childId: '1',
          name: 'Photo classe Emma',
          type: 'other',
          url: 'https://example.com/document4.jpg',
          uploadedBy: user?.id || '',
          createdAt: new Date('2024-01-05'),
        },
      ];
      setDocuments(mockDocuments);
    } catch (error) {
      Alert.alert(t('common.error'), t('errors.loadDocuments'));
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const getFilteredDocuments = () => {
    let filtered = documents;

    // Filter by child
    if (selectedChild !== 'all') {
      filtered = filtered.filter(doc => doc.childId === selectedChild);
    }

    // Filter by type
    if (selectedType !== 'all') {
      filtered = filtered.filter(doc => doc.type === selectedType);
    }

    // Filter by search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(doc => doc.name.toLowerCase().includes(query));
    }

    // Sort by creation date (newest first)
    return filtered.sort(
      (a, b) =>
        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    );
  };

  const getDocumentIcon = (type: string) => {
    switch (type) {
      case 'medical':
        return 'medical-bag';
      case 'authorization':
        return 'file-document-outline';
      case 'other':
        return 'file';
      default:
        return 'file';
    }
  };

  const getDocumentColor = (type: string) => {
    switch (type) {
      case 'medical':
        return colors.error;
      case 'authorization':
        return colors.warning;
      case 'other':
        return colors.info;
      default:
        return colors.textSecondary;
    }
  };

  const getFileExtension = (url: string) => {
    return url.split('.').pop()?.toUpperCase() || 'FILE';
  };

  const handleOpenDocument = async (document: Document) => {
    try {
      const supported = await Linking.canOpenURL(document.url);
      if (supported) {
        await Linking.openURL(document.url);
      } else {
        Alert.alert(t('common.error'), t('errors.cannotOpenDocument'));
      }
    } catch (error) {
      Alert.alert(t('common.error'), t('errors.openDocument'));
    }
  };

  const handleDeleteDocument = (document: Document) => {
    Alert.alert(
      t('documents.deleteConfirmTitle'),
      t('documents.deleteConfirmMessage', { name: document.name }),
      [
        {
          text: t('common.cancel'),
          style: 'cancel',
        },
        {
          text: t('common.delete'),
          style: 'destructive',
          onPress: () => deleteDocument(document.id),
        },
      ]
    );
  };

  const deleteDocument = async (documentId: string) => {
    try {
      setDocuments((prev: Document[]) =>
        prev.filter((doc: Document) => doc.id !== documentId)
      );
      Alert.alert(t('common.success'), t('documents.deleteSuccess'));
    } catch (error) {
      Alert.alert(t('common.error'), t('errors.deleteDocument'));
    }
  };

  const renderDocumentCard = (document: Document) => {
    const child = children.find((c: Child) => c.id === document.childId);
    const canDelete =
      user?.role === 'parent' || document.uploadedBy === user?.id;
    const fileExtension = getFileExtension(document.url);

    return (
      <Card key={document.id} style={styles.documentCard}>
        <Card.Content>
          <View style={styles.documentHeader}>
            <View style={styles.documentIcon}>
              <IconButton
                icon={getDocumentIcon(document.type)}
                size={24}
                iconColor={getDocumentColor(document.type)}
                style={styles.iconButton}
              />
              <Text style={styles.fileExtension}>{fileExtension}</Text>
            </View>

            <View style={styles.documentInfo}>
              <Title style={styles.documentTitle}>{document.name}</Title>
              <Text style={styles.documentChild}>
                {child?.firstName} {child?.lastName}
              </Text>
              <View style={styles.documentMeta}>
                <Chip
                  mode="outlined"
                  style={styles.typeChip}
                  textStyle={styles.chipText}
                >
                  {t(`documents.types.${document.type}`)}
                </Chip>
                <Text style={styles.documentDate}>
                  {document.createdAt.toLocaleDateString()}
                </Text>
              </View>
            </View>

            <View style={styles.documentActions}>
              <IconButton
                icon="eye"
                size={20}
                onPress={() => handleOpenDocument(document)}
              />
              {canDelete && (
                <IconButton
                  icon="delete"
                  size={20}
                  iconColor={colors.error}
                  onPress={() => handleDeleteDocument(document)}
                />
              )}
            </View>
          </View>
        </Card.Content>
      </Card>
    );
  };

  const filteredDocuments = getFilteredDocuments();
  const documentTypes = ['all', 'medical', 'authorization', 'other'];

  return (
    <View style={styles.container}>
      {/* Search and Filters */}
      <View style={styles.header}>
        <Searchbar
          placeholder={t('documents.searchPlaceholder')}
          onChangeText={setSearchQuery}
          value={searchQuery}
          style={styles.searchBar}
        />

        {/* Type Filter */}
        <View style={styles.filterRow}>
          <Menu
            visible={menuVisible}
            onDismiss={() => setMenuVisible(false)}
            anchor={
              <Button
                mode="outlined"
                onPress={() => setMenuVisible(true)}
                icon="filter"
                style={styles.filterButton}
              >
                {t(`documents.types.${selectedType}`)}
              </Button>
            }
          >
            {documentTypes.map(type => (
              <Menu.Item
                key={type}
                onPress={() => {
                  setSelectedType(type);
                  setMenuVisible(false);
                }}
                title={t(`documents.types.${type}`)}
              />
            ))}
          </Menu>
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
              {t('documents.allChildren')}
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

      {/* Documents List */}
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
        ) : filteredDocuments.length > 0 ? (
          <View style={styles.documentsContainer}>
            {filteredDocuments.map(renderDocumentCard)}
          </View>
        ) : (
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>
              {searchQuery.trim()
                ? t('documents.noSearchResults')
                : t('documents.noDocuments')}
            </Text>
            {user?.role === 'parent' && !searchQuery.trim() && (
              <Button
                mode="contained"
                onPress={() => navigation.navigate('AddDocument')}
                style={styles.addButton}
              >
                {t('documents.addFirstDocument')}
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
          onPress={() => navigation.navigate('AddDocument')}
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
  searchBar: {
    marginBottom: spacing.md,
  },
  filterRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  filterButton: {
    marginRight: spacing.sm,
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
  documentsContainer: {
    padding: spacing.md,
  },
  documentCard: {
    marginBottom: spacing.md,
  },
  documentHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  documentIcon: {
    alignItems: 'center',
    marginRight: spacing.md,
  },
  iconButton: {
    margin: 0,
  },
  fileExtension: {
    ...typography.caption,
    fontSize: 10,
    fontWeight: 'bold',
    color: colors.textSecondary,
    marginTop: -spacing.xs,
  },
  documentInfo: {
    flex: 1,
  },
  documentTitle: {
    ...typography.subtitle,
    marginBottom: spacing.xs,
  },
  documentChild: {
    ...typography.body,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
  },
  documentMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  typeChip: {
    height: 24,
  },
  chipText: {
    fontSize: 12,
  },
  documentDate: {
    ...typography.caption,
    color: colors.textSecondary,
  },
  documentActions: {
    flexDirection: 'row',
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

export default DocumentsScreen;
