import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { Session, User as SupabaseUser } from '@supabase/supabase-js';
import { supabase } from '../config/supabase';
import { AuthUser, User, UserRole } from '../types';
import { signUp as authSignUp, signIn as authSignIn, signOut as authSignOut, resetPassword as authResetPassword, getCurrentUser, updateProfile, AuthResult } from '../services/authService';
import PostHog from '../config/posthog';

// Interface refactorisée avec de meilleurs types
interface AuthContextType {
  user: AuthUser | null;
  session: Session | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<AuthResult>;
  signUp: (
    email: string,
    password: string,
    firstName: string,
    lastName: string,
    role: UserRole
  ) => Promise<AuthResult>;
  signOut: () => Promise<AuthResult>;
  resetPassword: (email: string) => Promise<AuthResult>;
  updateProfile: (updates: Partial<User>) => Promise<AuthResult>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  // Fonction pour charger le profil utilisateur
  const loadUserProfile = useCallback(async (supabaseUser: SupabaseUser) => {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', supabaseUser.id)
        .single();

      if (error) {
        console.warn('Erreur lors du chargement du profil:', error);
        setLoading(false);
        return;
      }

      if (data) {
        setUser({
          id: data.id,
          email: data.email,
          displayName: data.displayName || data.display_name || `${data.first_name} ${data.last_name}`,
          role: data.role,
          plan: data.plan,
          avatarUrl: data.avatarUrl || data.avatar_url,
          phone: data.phone,
          address: data.address,
          onboardingCompleted: data.onboarding_completed,
          createdAt: new Date(data.created_at),
          updatedAt: new Date(data.updated_at),
        });
      }
    } catch (error) {
      console.error('Erreur lors du chargement du profil:', error);
    } finally {
      setLoading(false);
    }
  }, []);

  // Fonction pour rafraîchir les données utilisateur
  const refreshUser = useCallback(async () => {
    if (session?.user) {
      await loadUserProfile(session.user);
    }
  }, [session?.user, loadUserProfile]);

  // Gestion des analytics PostHog
  const handlePostHogAnalytics = useCallback((event: string, user?: SupabaseUser, additionalData?: any) => {
    try {
      if (user) {
        PostHog.identify(user.id, {
          email: user.email || '',
          ...additionalData,
        });
      }
      PostHog.capture(event, additionalData);
    } catch (error) {
      console.warn('Erreur PostHog:', error);
    }
  }, []);

  useEffect(() => {
    // Récupérer la session actuelle
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session?.user) {
        loadUserProfile(session.user);
      } else {
        setLoading(false);
      }
    });

    // Écouter les changements d'authentification
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (event, session) => {
      setSession(session);

      if (session?.user) {
        await loadUserProfile(session.user);
        handlePostHogAnalytics(event === 'SIGNED_IN' ? 'user_signed_in' : 'user_session_updated', session.user);
      } else {
        setUser(null);
        try {
          PostHog.reset();
        } catch (error) {
          console.warn('Erreur PostHog reset:', error);
        }
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, [loadUserProfile, handlePostHogAnalytics]);

  // Méthodes d'authentification refactorisées
  const signIn = useCallback(async (email: string, password: string): Promise<AuthResult> => {
    const result = await authSignIn({ email, password });
    if (!result.error) {
      handlePostHogAnalytics('user_signed_in');
    }
    return result;
  }, [handlePostHogAnalytics]);

  const signUp = useCallback(async (
    email: string,
    password: string,
    firstName: string,
    lastName: string,
    role: UserRole
  ): Promise<AuthResult> => {
    const result = await authSignUp({
      email,
      password,
      firstName,
      lastName,
      role,
    });

    if (!result.error) {
      handlePostHogAnalytics('user_signed_up', undefined, { role, plan: 'free' });
    }

    return result;
  }, [handlePostHogAnalytics]);

  const signOut = useCallback(async (): Promise<AuthResult> => {
    handlePostHogAnalytics('user_signed_out');
    const result = await authSignOut();
    if (!result.error) {
      try {
        PostHog.reset();
      } catch (error) {
        console.warn('Erreur PostHog reset:', error);
      }
    }
    return result;
  }, [handlePostHogAnalytics]);

  const resetPassword = useCallback(async (email: string): Promise<AuthResult> => {
    return await authResetPassword(email);
  }, []);

  const updateProfile = useCallback(async (updates: Partial<User>): Promise<AuthResult> => {
    if (!user) {
      return { error: 'Utilisateur non connecté' };
    }

    try {
      const { error } = await supabase
        .from('users')
        .update({
          phone: updates.phone,
          address: updates.address,
          updated_at: new Date().toISOString(),
        })
        .eq('id', user.id);

      if (error) {
        return { error: error.message };
      }

      // Rafraîchir le profil
      await refreshUser();

      return { data: true };
    } catch (error: any) {
      return { error: error?.message || 'Une erreur inattendue s\'est produite' };
    }
  }, [user, refreshUser]);

  const value: AuthContextType = {
    user,
    session,
    loading,
    signIn,
    signUp,
    signOut,
    resetPassword: authResetPassword,
    updateProfile,
    refreshUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export default AuthContext;
