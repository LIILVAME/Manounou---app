import { useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { UserRole } from '../types';
import { AuthResult } from '../services/authService';

/**
 * Hook personnalisé pour les opérations d'authentification
 * Fournit des méthodes simplifiées et optimisées
 */
export const useAuthOperations = () => {
  const { signIn, signUp, signOut, resetPassword, updateProfile, loading } = useAuth();

  // Connexion avec gestion d'erreurs améliorée
  const handleSignIn = useCallback(
    async (email: string, password: string): Promise<AuthResult> => {
      if (!email || !password) {
        return { error: 'Email et mot de passe requis' };
      }

      if (!email.includes('@')) {
        return { error: 'Format d\'email invalide' };
      }

      if (password.length < 6) {
        return { error: 'Le mot de passe doit contenir au moins 6 caractères' };
      }

      return await signIn(email.toLowerCase().trim(), password);
    },
    [signIn]
  );

  // Inscription avec validation
  const handleSignUp = useCallback(
    async (
      email: string,
      password: string,
      firstName: string,
      lastName: string,
      role: UserRole
    ): Promise<AuthResult> => {
      // Validations
      if (!email || !password || !firstName || !lastName || !role) {
        return { error: 'Tous les champs sont requis' };
      }

      if (!email.includes('@')) {
        return { error: 'Format d\'email invalide' };
      }

      if (password.length < 8) {
        return { error: 'Le mot de passe doit contenir au moins 8 caractères' };
      }

      if (firstName.length < 2 || lastName.length < 2) {
        return { error: 'Le prénom et nom doivent contenir au moins 2 caractères' };
      }

      if (!['parent', 'nounou'].includes(role)) {
        return { error: 'Rôle invalide' };
      }

      return await signUp(
        email.toLowerCase().trim(),
        password,
        firstName.trim(),
        lastName.trim(),
        role
      );
    },
    [signUp]
  );

  // Déconnexion sécurisée
  const handleSignOut = useCallback(async (): Promise<AuthResult> => {
    try {
      return await signOut();
    } catch (error: any) {
      return { error: error?.message || 'Erreur lors de la déconnexion' };
    }
  }, [signOut]);

  // Réinitialisation de mot de passe avec validation
  const handleResetPassword = useCallback(
    async (email: string): Promise<AuthResult> => {
      if (!email) {
        return { error: 'Email requis' };
      }

      if (!email.includes('@')) {
        return { error: 'Format d\'email invalide' };
      }

      return await resetPassword(email.toLowerCase().trim());
    },
    [resetPassword]
  );

  // Mise à jour de profil avec validation
  const handleUpdateProfile = useCallback(
    async (updates: {
      display_name?: string;
      phone?: string;
      address?: string;
      avatar_url?: string;
    }): Promise<AuthResult> => {
      // Validation des données
      if (updates.display_name && updates.display_name.length < 2) {
        return { error: 'Le nom d\'affichage doit contenir au moins 2 caractères' };
      }

      if (updates.phone && !/^[+]?[0-9\s-()]{10,}$/.test(updates.phone)) {
        return { error: 'Format de téléphone invalide' };
      }

      if (updates.address && updates.address.length < 5) {
        return { error: 'L\'adresse doit contenir au moins 5 caractères' };
      }

      return await updateProfile(updates);
    },
    [updateProfile]
  );

  return {
    handleSignIn,
    handleSignUp,
    handleSignOut,
    handleResetPassword,
    handleUpdateProfile,
    loading,
  };
};

export default useAuthOperations;