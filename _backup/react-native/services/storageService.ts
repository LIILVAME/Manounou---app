// Service de stockage lean - Version MVP simplifiée
import { supabase } from '../config/supabase';

export interface UploadResult {
  success: boolean;
  url?: string;
  error?: string;
}

export interface DownloadResult {
  success: boolean;
  url?: string;
  error?: string;
}

// Upload simple vers Supabase Storage
export const uploadFile = async (
  file: File | Blob,
  bucket: string,
  path: string
): Promise<UploadResult> => {
  try {
    const { data, error } = await supabase.storage
      .from(bucket)
      .upload(path, file, {
        upsert: false,
      });

    if (error) {
      return {
        success: false,
        error: `Erreur upload: ${error.message}`,
      };
    }

    // Obtenir l'URL publique
    const { data: urlData } = supabase.storage
      .from(bucket)
      .getPublicUrl(data.path);

    return {
      success: true,
      url: urlData.publicUrl,
    };
  } catch (error: any) {
    return {
      success: false,
      error: `Erreur inattendue: ${error.message}`,
    };
  }
};

// Upload d'avatar utilisateur
export const uploadAvatar = async (
  file: File | Blob,
  userId: string
): Promise<UploadResult> => {
  const path = `avatars/${userId}-${Date.now()}`;
  return uploadFile(file, 'avatars', path);
};

// Upload de photo d'enfant
export const uploadChildPhoto = async (
  file: File | Blob,
  childId: string
): Promise<UploadResult> => {
  const path = `children/${childId}-${Date.now()}`;
  return uploadFile(file, 'children', path);
};

// Upload de document
export const uploadDocument = async (
  file: File | Blob,
  childId: string,
  documentType: string
): Promise<UploadResult> => {
  const path = `documents/${childId}/${documentType}-${Date.now()}`;
  return uploadFile(file, 'documents', path);
};

// Supprimer un fichier
export const deleteFile = async (
  bucket: string,
  path: string
): Promise<{ success: boolean; error?: string }> => {
  try {
    const { error } = await supabase.storage
      .from(bucket)
      .remove([path]);

    if (error) {
      return {
        success: false,
        error: `Erreur suppression: ${error.message}`,
      };
    }

    return { success: true };
  } catch (error: any) {
    return {
      success: false,
      error: `Erreur inattendue: ${error.message}`,
    };
  }
};

// Obtenir l'URL publique d'un fichier
export const getPublicUrl = (bucket: string, path: string): string => {
  const { data } = supabase.storage
    .from(bucket)
    .getPublicUrl(path);
  
  return data.publicUrl;
};

// Lister les fichiers d'un dossier
export const listFiles = async (
  bucket: string,
  folder?: string
): Promise<{ success: boolean; files?: any[]; error?: string }> => {
  try {
    const { data, error } = await supabase.storage
      .from(bucket)
      .list(folder);

    if (error) {
      return {
        success: false,
        error: `Erreur listage: ${error.message}`,
      };
    }

    return {
      success: true,
      files: data,
    };
  } catch (error: any) {
    return {
      success: false,
      error: `Erreur inattendue: ${error.message}`,
    };
  }
};

// Validation simple de fichier
export const validateFile = (file: File): { valid: boolean; error?: string } => {
  // Taille max 5MB pour MVP
  const maxSize = 5 * 1024 * 1024;
  if (file.size > maxSize) {
    return { valid: false, error: 'Fichier trop volumineux (max 5MB)' };
  }

  // Types autorisés pour MVP
  const allowedTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'application/pdf',
  ];

  if (!allowedTypes.includes(file.type)) {
    return { valid: false, error: 'Type de fichier non autorisé' };
  }

  return { valid: true };
};

export default {
  uploadFile,
  uploadAvatar,
  uploadChildPhoto,
  uploadDocument,
  deleteFile,
  getPublicUrl,
  listFiles,
  validateFile,
};
