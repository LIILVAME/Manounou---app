import { useState, useCallback, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useChildren } from './useChildren';
import { useEvents } from './useEvents';
import { useDocuments } from './useDocuments';
import { useRelationships } from './useRelationships';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface SearchResult {
  id: string;
  type: 'child' | 'event' | 'document' | 'relationship';
  title: string;
  subtitle?: string;
  description?: string;
  date?: string;
  relevanceScore: number;
  data: any;
}

export interface SearchOptions {
  types?: ('child' | 'event' | 'document' | 'relationship')[];
  sortBy?: 'relevance' | 'date' | 'alphabetical';
  sortOrder?: 'asc' | 'desc';
  limit?: number;
  filters?: {
    types?: ('child' | 'event' | 'document' | 'relationship')[];
    dateRange?: {
      start: Date;
      end: Date;
    };
  };
}

const RECENT_SEARCHES_KEY = 'recent_searches';
const MAX_RECENT_SEARCHES = 10;

export const useSearch = () => {
  const { user } = useAuth();
  const { searchChildrenByName } = useChildren();
  const { searchEvents } = useEvents();
  const { documents } = useDocuments();
  const { relationships } = useRelationships();

  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [recentSearches, setRecentSearches] = useState<string[]>([]);
  const [totalResults, setTotalResults] = useState(0);
  const [hasMore, setHasMore] = useState(false);
  const [offset, setOffset] = useState(0);
  const [currentOptions, setCurrentOptions] = useState<SearchOptions>({});

  // Charger les recherches récentes
  useEffect(() => {
    loadRecentSearches();
  }, []);

  const loadRecentSearches = async () => {
    try {
      const stored = await AsyncStorage.getItem(RECENT_SEARCHES_KEY);
      if (stored) {
        setRecentSearches(JSON.parse(stored));
      }
    } catch (error) {
      console.error('Erreur lors du chargement des recherches récentes:', error);
    }
  };

  const addToRecentSearches = async (searchQuery: string) => {
    try {
      const trimmedQuery = searchQuery.trim();
      if (trimmedQuery.length < 2) return;

      const updated = [trimmedQuery, ...recentSearches.filter(q => q !== trimmedQuery)]
        .slice(0, MAX_RECENT_SEARCHES);
      
      setRecentSearches(updated);
      await AsyncStorage.setItem(RECENT_SEARCHES_KEY, JSON.stringify(updated));
    } catch (error) {
      console.error('Erreur lors de la sauvegarde des recherches récentes:', error);
    }
  };

  const clearRecentSearches = async () => {
    try {
      setRecentSearches([]);
      await AsyncStorage.removeItem(RECENT_SEARCHES_KEY);
    } catch (error) {
      console.error('Erreur lors de la suppression des recherches récentes:', error);
    }
  };

  // Calculer la pertinence d'un résultat
  const calculateRelevance = (searchQuery: string, fields: string[]): number => {
    const query = searchQuery.toLowerCase();
    let score = 0;

    fields.forEach(field => {
      const fieldValue = field.toLowerCase();
      if (fieldValue.includes(query)) {
        // Score plus élevé si le terme apparaît au début
        if (fieldValue.startsWith(query)) {
          score += 10;
        } else {
          score += 5;
        }
        // Bonus pour les correspondances exactes
        if (fieldValue === query) {
          score += 15;
        }
      }
    });

    return score;
  };

  // Trier les résultats
  const sortResults = (results: SearchResult[], options: SearchOptions): SearchResult[] => {
    const { sortBy = 'relevance', sortOrder = 'desc' } = options;

    return results.sort((a, b) => {
      let comparison = 0;

      switch (sortBy) {
        case 'relevance':
          comparison = a.relevanceScore - b.relevanceScore;
          break;
        case 'date':
          const dateA = a.date ? new Date(a.date).getTime() : 0;
          const dateB = b.date ? new Date(b.date).getTime() : 0;
          comparison = dateA - dateB;
          break;
        case 'alphabetical':
          comparison = a.title.localeCompare(b.title);
          break;
      }

      return sortOrder === 'asc' ? comparison : -comparison;
    });
  };

  const search = useCallback(
    async (searchQuery: string, options: SearchOptions = {}) => {
      if (!searchQuery.trim() || !user) {
        setResults([]);
        setTotalResults(0);
        setHasMore(false);
        return;
      }

      setLoading(true);
      setError(null);
      setCurrentOptions(options);
      setOffset(0);

      const { limit = 50, filters } = options;
      const searchResults: SearchResult[] = [];

      try {
        // Recherche dans les enfants
        if (!filters?.types || filters.types.includes('child')) {
          const children = await searchChildrenByName(searchQuery);
          children.forEach(child => {
            const relevanceScore = calculateRelevance(searchQuery, [
              child.firstName,
              child.lastName,
              child.medicalInfo || '',
            ]);

            searchResults.push({
              id: child.id,
              type: 'child',
              title: `${child.firstName} ${child.lastName}`,
              subtitle: child.medicalInfo ? `Info médicale: ${child.medicalInfo}` : undefined,
              description: `Né(e) le ${new Date(child.birthDate).toLocaleDateString()}`,
              date: child.createdAt.toISOString(),
              relevanceScore,
              data: child,
            });
          });
        }

        // Recherche dans les événements
        if (!filters?.types || filters.types.includes('event')) {
          const events = await searchEvents(searchQuery);
          events.forEach(event => {
            const relevanceScore = calculateRelevance(searchQuery, [
              event.title,
              event.description || '',
              event.location || '',
            ]);

            searchResults.push({
              id: event.id,
              type: 'event',
              title: event.title,
              subtitle: `${event.event_type || event.type} - ${new Date(event.start_time || event.startTime || new Date()).toLocaleDateString()}`,
              description: event.description,
              date: event.start_time || (event.startTime ? event.startTime.toISOString() : undefined),
              relevanceScore,
              data: event,
            });
          });
        }

        // Recherche dans les documents
        if (!filters?.types || filters.types.includes('document')) {
          const filteredDocs = documents.filter(doc =>
            doc.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
            doc.description?.toLowerCase().includes(searchQuery.toLowerCase())
          );

          filteredDocs.forEach(doc => {
            const relevanceScore = calculateRelevance(searchQuery, [
              doc.title,
              doc.description || '',
            ]);

            searchResults.push({
              id: doc.id,
              type: 'document',
              title: doc.title,
              subtitle: `${doc.category} - ${doc.file_type}`,
              description: doc.description,
              date: doc.created_at,
              relevanceScore,
              data: doc,
            });
          });
        }

        // Recherche dans les relations
        if (!filters?.types || filters.types.includes('relationship')) {
          const filteredRelationships = relationships.filter(
            (relationship: any) => {
              const otherUser =
                relationship.parent_id === user.id
                  ? relationship.nounou
                  : relationship.parent;
              return (
                otherUser &&
                (otherUser.first_name
                  ?.toLowerCase()
                  .includes(searchQuery.toLowerCase()) ||
                  otherUser.last_name
                    ?.toLowerCase()
                    .includes(searchQuery.toLowerCase()) ||
                  otherUser.email
                    ?.toLowerCase()
                    .includes(searchQuery.toLowerCase()))
              );
            }
          );

          filteredRelationships.forEach((relationship: any) => {
            const otherUser =
              relationship.parent_id === user.id
                ? relationship.nounou
                : relationship.parent;
            if (otherUser) {
              const relevanceScore = calculateRelevance(searchQuery, [
                otherUser.first_name || '',
                otherUser.last_name || '',
                otherUser.email || '',
              ]);

              searchResults.push({
                id: relationship.id,
                type: 'relationship',
                title: `${otherUser.first_name} ${otherUser.last_name}`,
                subtitle: `${
                  relationship.parent_id === user.id ? 'Nounou' : 'Parent'
                } - ${relationship.status}`,
                description: otherUser.email,
                date: relationship.created_at,
                relevanceScore,
                data: relationship,
              });
            }
          });
        }

        // Tri des résultats
        const sortedResults = sortResults(searchResults, options);

        // Application de la limite
        const limitedResults = sortedResults.slice(0, limit);

        setResults(limitedResults);
        setTotalResults(sortedResults.length);
        setHasMore(sortedResults.length > limit);

        // Ajouter à l'historique de recherche
        addToRecentSearches(searchQuery);

      } catch (err) {
        setError('Erreur lors de la recherche');
        console.error('Search error:', err);
      } finally {
        setLoading(false);
      }
    },
    [user, searchChildrenByName, searchEvents, documents, relationships]
  );

  const loadMore = useCallback(async () => {
    if (!hasMore || loading || !query) {
      return;
    }

    const newOffset = offset + (currentOptions.limit || 50);
    setOffset(newOffset);

    // Pour simplifier, on relance la recherche avec une limite plus élevée
    const newLimit = (currentOptions.limit || 50) + newOffset;
    await search(query, { ...currentOptions, limit: newLimit });
  }, [hasMore, loading, query, offset, currentOptions, search]);

  const clearResults = useCallback(() => {
    setResults([]);
    setQuery('');
    setError(null);
    setTotalResults(0);
    setHasMore(false);
    setOffset(0);
  }, []);

  const searchByType = useCallback(
    async (searchQuery: string, type: 'child' | 'event' | 'document' | 'relationship') => {
      await search(searchQuery, { types: [type] });
    },
    [search]
  );

  const getResultsByType = useCallback(
    (type: 'child' | 'event' | 'document' | 'relationship') => {
      return results.filter(result => result.type === type);
    },
    [results]
  );

  const getTopResults = useCallback(
    (count: number = 5) => {
      return results.slice(0, count);
    },
    [results]
  );

  const hasResults = results.length > 0;
  const isEmpty = !loading && !hasResults && query.length > 0;

  return {
    // État
    query,
    results,
    loading,
    error,
    recentSearches,
    totalResults,
    hasMore,
    hasResults,
    isEmpty,

    // Actions
    search,
    loadMore,
    clearResults,
    searchByType,
    setQuery,

    // Utilitaires
    getResultsByType,
    getTopResults,
    clearRecentSearches,
  };
};

export default useSearch;
