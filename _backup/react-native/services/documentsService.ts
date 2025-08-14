import { supabase } from '../config/supabase';
import { Document, DocumentCategory } from '../types/database';
import * as DocumentPicker from 'expo-document-picker';
import * as FileSystem from 'expo-file-system';

export interface CreateDocumentData {
  title: string;
  category: DocumentCategory;
  child_id?: string;
  description?: string;
}

export interface UpdateDocumentData extends Partial<CreateDocumentData> {
  id: string;
}

export interface DocumentFilters {
  category?: DocumentCategory;
  childId?: string;
  searchTerm?: string;
}

export class DocumentsService {
  static async getDocuments(
    userId: string,
    filters?: DocumentFilters
  ): Promise<Document[]> {
    let query = supabase
      .from('documents')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('user_id', userId);

    // Appliquer les filtres
    if (filters?.category) {
      query = query.eq('category', filters.category);
    }
    if (filters?.childId) {
      query = query.eq('child_id', filters.childId);
    }
    if (filters?.searchTerm) {
      query = query.or(
        `title.ilike.%${filters.searchTerm}%,description.ilike.%${filters.searchTerm}%`
      );
    }

    const { data, error } = await query.order('created_at', {
      ascending: false,
    });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  static async getDocumentById(documentId: string): Promise<Document | null> {
    const { data, error } = await supabase
      .from('documents')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('id', documentId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null; // Document non trouvé
      }
      throw new Error(error.message);
    }

    return data;
  }

  static async uploadDocument(
    userId: string,
    documentData: CreateDocumentData,
    file: DocumentPicker.DocumentPickerResult
  ): Promise<Document> {
    if (file.canceled || !file.assets || file.assets.length === 0) {
      throw new Error('Aucun fichier sélectionné');
    }

    const asset = file.assets[0];
    const fileExtension = asset.name.split('.').pop();
    const fileName = `${Date.now()}_${Math.random()
      .toString(36)
      .substring(7)}.${fileExtension}`;
    const filePath = `documents/${userId}/${fileName}`;

    try {
      // Lire le fichier
      const fileInfo = await FileSystem.getInfoAsync(asset.uri);
      if (!fileInfo.exists) {
        throw new Error("Le fichier n'existe pas");
      }

      // Convertir en base64 pour l'upload
      const base64 = await FileSystem.readAsStringAsync(asset.uri, {
        encoding: FileSystem.EncodingType.Base64,
      });

      // Upload vers Supabase Storage
      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('documents')
        .upload(filePath, decode(base64), {
          contentType: asset.mimeType || 'application/octet-stream',
          upsert: false,
        });

      if (uploadError) {
        throw new Error(`Erreur d'upload: ${uploadError.message}`);
      }

      // Obtenir l'URL publique
      const { data: urlData } = supabase.storage
        .from('documents')
        .getPublicUrl(filePath);

      // Créer l'enregistrement en base
      const { data, error } = await supabase
        .from('documents')
        .insert({
          user_id: userId,
          title: documentData.title,
          category: documentData.category,
          child_id: documentData.child_id || null,
          description: documentData.description || null,
          file_url: urlData.publicUrl,
          file_type: asset.mimeType || 'application/octet-stream',
          file_size: asset.size || 0,
          uploaded_by: userId,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .select(
          `
          *,
          child:children(first_name, last_name)
        `
        )
        .single();

      if (error) {
        // Supprimer le fichier uploadé en cas d'erreur
        await supabase.storage.from('documents').remove([filePath]);
        throw new Error(error.message);
      }

      return data;
    } catch (error) {
      throw new Error(`Erreur lors de l'upload: ${error}`);
    }
  }

  static async updateDocument(
    documentData: UpdateDocumentData
  ): Promise<Document> {
    const { id, ...updates } = documentData;

    const { data, error } = await supabase
      .from('documents')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  static async deleteDocument(documentId: string): Promise<void> {
    // Récupérer les informations du document
    const document = await this.getDocumentById(documentId);
    if (!document) {
      throw new Error('Document non trouvé');
    }

    // Supprimer le fichier du storage
    if (document.file_url) {
      // Extraire le chemin du fichier depuis l'URL
      const urlParts = document.file_url.split('/');
      const filePath = urlParts.slice(-3).join('/'); // documents/userId/fileName

      const { error: storageError } = await supabase.storage
        .from('documents')
        .remove([filePath]);

      if (storageError) {
        console.error(
          'Erreur lors de la suppression du fichier:',
          storageError
        );
      }
    }

    // Supprimer l'enregistrement de la base
    const { error } = await supabase
      .from('documents')
      .delete()
      .eq('id', documentId);

    if (error) {
      throw new Error(error.message);
    }
  }

  static async getDocumentsByChild(childId: string): Promise<Document[]> {
    const { data, error } = await supabase
      .from('documents')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('child_id', childId)
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  static async getDocumentsByCategory(
    userId: string,
    category: DocumentCategory
  ): Promise<Document[]> {
    const { data, error } = await supabase
      .from('documents')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('user_id', userId)
      .eq('category', category)
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }

  static async downloadDocument(document: Document): Promise<string> {
    if (!document.file_url) {
      throw new Error('URL du fichier non disponible');
    }

    try {
      const downloadDir = FileSystem.documentDirectory + 'downloads/';

      // Créer le dossier de téléchargement s'il n'existe pas
      const dirInfo = await FileSystem.getInfoAsync(downloadDir);
      if (!dirInfo.exists) {
        await FileSystem.makeDirectoryAsync(downloadDir, {
          intermediates: true,
        });
      }

      const fileName = document.file_url.split('/').pop() || 'document';
      const localUri = downloadDir + fileName;

      // Télécharger le fichier
      const downloadResult = await FileSystem.downloadAsync(
        document.file_url,
        localUri
      );

      return downloadResult.uri;
    } catch (error) {
      throw new Error(`Erreur lors du téléchargement: ${error}`);
    }
  }

  static async getDocumentStats(userId: string) {
    const { data, error } = await supabase
      .from('documents')
      .select('category, file_size')
      .eq('user_id', userId);

    if (error) {
      throw new Error(error.message);
    }

    const stats = {
      total: data?.length || 0,
      totalSize: 0,
      byCategory: {} as Record<DocumentCategory, number>,
    };

    data?.forEach(doc => {
      stats.totalSize += doc.file_size || 0;
      const category = doc.category as DocumentCategory;
      stats.byCategory[category] = (stats.byCategory[category] || 0) + 1;
    });

    return stats;
  }

  static async searchDocuments(
    userId: string,
    searchTerm: string
  ): Promise<Document[]> {
    const { data, error } = await supabase
      .from('documents')
      .select(
        `
        *,
        child:children(first_name, last_name)
      `
      )
      .eq('user_id', userId)
      .or(`title.ilike.%${searchTerm}%,description.ilike.%${searchTerm}%`)
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(error.message);
    }

    return data || [];
  }
}

// Fonction utilitaire pour décoder base64
function decode(base64: string): Uint8Array {
  const binaryString = atob(base64);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}
