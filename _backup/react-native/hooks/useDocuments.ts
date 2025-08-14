import { useState, useEffect, useCallback } from 'react';
import { Document, DocumentCategory } from '../types/database';
import {
  DocumentsService,
  CreateDocumentData,
  UpdateDocumentData,
} from '../services/documentsService';
import { useAuth } from './useAuth';
import * as DocumentPicker from 'expo-document-picker';

interface UseDocumentsReturn {
  documents: Document[];
  loading: boolean;
  error: string | null;
  refreshDocuments: () => Promise<void>;
  addDocument: (
    documentData: CreateDocumentData,
    file: DocumentPicker.DocumentPickerResult
  ) => Promise<{ success: boolean; error?: string }>;
  editDocument: (
    id: string,
    updates: Partial<CreateDocumentData>
  ) => Promise<{ success: boolean; error?: string }>;
  removeDocument: (id: string) => Promise<{ success: boolean; error?: string }>;
  downloadDocument: (
    id: string
  ) => Promise<{ success: boolean; url?: string; error?: string }>;
  getDocumentsByCategory: (category: DocumentCategory) => Promise<Document[]>;
  getDocumentsByChild: (childId: string) => Promise<Document[]>;
  getDocumentsStats: () => Promise<{
    total: number;
    byCategory: Record<DocumentCategory, number>;
  }>;
}

/**
 * Hook pour gérer les documents
 */
export const useDocuments = (): UseDocumentsReturn => {
  const { user } = useAuth();
  const [documents, setDocuments] = useState<Document[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refreshDocuments = useCallback(async () => {
    if (!user) {
      setDocuments([]);
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      const documentsData = await DocumentsService.getDocuments(user.id);
      setDocuments(documentsData || []);
    } catch (err) {
      setError('Erreur lors du chargement des documents');
    } finally {
      setLoading(false);
    }
  }, [user]);

  const addDocument = useCallback(
    async (
      documentData: CreateDocumentData,
      file: DocumentPicker.DocumentPickerResult
    ) => {
      if (!user) {
        return { success: false, error: 'Utilisateur non connecté' };
      }

      try {
        await DocumentsService.uploadDocument(user.id, documentData, file);
        await refreshDocuments();
        return { success: true };
      } catch (err) {
        return { success: false, error: "Erreur lors de l'ajout du document" };
      }
    },
    [refreshDocuments, user]
  );

  const editDocument = useCallback(
    async (id: string, updates: Partial<CreateDocumentData>) => {
      try {
        await DocumentsService.updateDocument({ id, ...updates });
        await refreshDocuments();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: 'Erreur lors de la mise à jour du document',
        };
      }
    },
    [refreshDocuments]
  );

  const removeDocument = useCallback(
    async (id: string) => {
      try {
        await DocumentsService.deleteDocument(id);
        await refreshDocuments();
        return { success: true };
      } catch (err) {
        return {
          success: false,
          error: 'Erreur lors de la suppression du document',
        };
      }
    },
    [refreshDocuments]
  );

  const downloadDocument = useCallback(
    async (id: string) => {
      try {
        const document = documents.find(d => d.id === id);
        if (!document) {
          return { success: false, error: 'Document non trouvé' };
        }
        const url = await DocumentsService.downloadDocument(document);
        return { success: true, url };
      } catch (err) {
        return {
          success: false,
          error: 'Erreur lors du téléchargement du document',
        };
      }
    },
    [documents]
  );

  const getDocumentsByCategory = useCallback(
    async (category: DocumentCategory): Promise<Document[]> => {
      if (!user) {
        return [];
      }

      try {
        const result = await DocumentsService.getDocumentsByCategory(
          user.id,
          category
        );
        return result || [];
      } catch (err) {
        return [];
      }
    },
    [user]
  );

  const getDocumentsByChild = useCallback(
    async (childId: string): Promise<Document[]> => {
      try {
        const result = await DocumentsService.getDocumentsByChild(childId);
        return result || [];
      } catch (err) {
        return [];
      }
    },
    []
  );

  const getDocumentsStats = useCallback(async () => {
    if (!user) {
      return { total: 0, byCategory: {} as Record<DocumentCategory, number> };
    }

    try {
      const stats = await DocumentsService.getDocumentStats(user.id);
      return (
        stats || {
          total: 0,
          byCategory: {} as Record<DocumentCategory, number>,
        }
      );
    } catch (err) {
      return { total: 0, byCategory: {} as Record<DocumentCategory, number> };
    }
  }, [user]);

  useEffect(() => {
    refreshDocuments();
  }, [refreshDocuments]);

  return {
    documents,
    loading,
    error,
    refreshDocuments,
    addDocument,
    editDocument,
    removeDocument,
    downloadDocument,
    getDocumentsByCategory,
    getDocumentsByChild,
    getDocumentsStats,
  };
};

/**
 * Hook pour obtenir un document spécifique par ID
 */
export const useDocument = (documentId: string | null) => {
  const { documents, loading } = useDocuments();
  const document = documents.find(d => d.id === documentId) || null;

  return {
    document,
    loading: loading && !!documentId,
  };
};

/**
 * Hook pour obtenir les documents récents
 */
export const useRecentDocuments = (limit: number = 5) => {
  const { documents } = useDocuments();

  const recentDocuments = documents
    .sort(
      (a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    )
    .slice(0, limit);

  return {
    recentDocuments,
  };
};
