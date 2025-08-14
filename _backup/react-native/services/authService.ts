// Service d'authentification lean - Version MVP simplifiée
import { supabase } from '../config/supabase';
import { UserRole } from '../types';

export interface SignUpData {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role: UserRole;
}

export interface SignInData {
  email: string;
  password: string;
}

export interface AuthResult<T = any> {
  data?: T;
  error?: string;
}

// Inscription utilisateur
export const signUp = async (data: SignUpData): Promise<AuthResult> => {
  try {
    const { email, password, firstName, lastName, role } = data;

    // Inscription avec Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          first_name: firstName,
          last_name: lastName,
          display_name: `${firstName} ${lastName}`,
          role,
        },
      },
    });

    if (authError) {
      return { error: authError.message };
    }

    return { data: authData };
  } catch (error: any) {
    return { error: error.message || 'Erreur lors de l\'inscription' };
  }
};

// Connexion utilisateur
export const signIn = async (data: SignInData): Promise<AuthResult> => {
  try {
    const { email, password } = data;

    const { data: authData, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      return { error: error.message };
    }

    return { data: authData };
  } catch (error: any) {
    return { error: error.message || 'Erreur lors de la connexion' };
  }
};

// Déconnexion
export const signOut = async (): Promise<AuthResult> => {
  try {
    const { error } = await supabase.auth.signOut();

    if (error) {
      return { error: error.message };
    }

    return { data: { success: true } };
  } catch (error: any) {
    return { error: error.message || 'Erreur lors de la déconnexion' };
  }
};

// Réinitialisation du mot de passe
export const resetPassword = async (email: string): Promise<AuthResult> => {
  try {
    const { error } = await supabase.auth.resetPasswordForEmail(email);

    if (error) {
      return { error: error.message };
    }

    return { data: { success: true } };
  } catch (error: any) {
    return { error: error.message || 'Erreur lors de la réinitialisation' };
  }
};

// Obtenir l'utilisateur actuel
export const getCurrentUser = async (): Promise<AuthResult> => {
  try {
    const { data: { user }, error } = await supabase.auth.getUser();

    if (error) {
      return { error: error.message };
    }

    return { data: user };
  } catch (error: any) {
    return { error: error.message || 'Erreur lors de la récupération utilisateur' };
  }
};

// Mettre à jour le profil utilisateur
export const updateProfile = async (updates: {
  firstName?: string;
  lastName?: string;
  phone?: string;
  address?: string;
}): Promise<AuthResult> => {
  try {
    const { data, error } = await supabase.auth.updateUser({
      data: {
        first_name: updates.firstName,
        last_name: updates.lastName,
        phone: updates.phone,
        address: updates.address,
        display_name: updates.firstName && updates.lastName 
          ? `${updates.firstName} ${updates.lastName}` 
          : undefined,
      },
    });

    if (error) {
      return { error: error.message };
    }

    return { data };
  } catch (error: any) {
    return { error: error.message || 'Erreur lors de la mise à jour' };
  }
};

// Changer le mot de passe
export const changePassword = async (newPassword: string): Promise<AuthResult> => {
  try {
    const { data, error } = await supabase.auth.updateUser({
      password: newPassword,
    });

    if (error) {
      return { error: error.message };
    }

    return { data };
  } catch (error: any) {
    return { error: error.message || 'Erreur lors du changement de mot de passe' };
  }
};

// Vérifier si l'utilisateur est connecté
export const isAuthenticated = async (): Promise<boolean> => {
  try {
    const { data: { session } } = await supabase.auth.getSession();
    return !!session;
  } catch {
    return false;
  }
};

// Obtenir la session actuelle
export const getSession = async () => {
  try {
    const { data: { session }, error } = await supabase.auth.getSession();
    
    if (error) {
      return { error: error.message };
    }

    return { data: session };
  } catch (error: any) {
    return { error: error.message || 'Erreur lors de la récupération de session' };
  }
};

export default {
  signUp,
  signIn,
  signOut,
  resetPassword,
  getCurrentUser,
  updateProfile,
  changePassword,
  isAuthenticated,
  getSession,
};
