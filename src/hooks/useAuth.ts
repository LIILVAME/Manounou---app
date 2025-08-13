import { useAuth as useAuthContext } from '../contexts/AuthContext';

/**
 * Hook pour utiliser le contexte d'authentification
 * (Re-export du hook du contexte)
 */
export const useAuth = useAuthContext;

/**
 * Hook pour vérifier si l'utilisateur est connecté
 */
export const useIsAuthenticated = (): boolean => {
  const { user } = useAuth();
  return !!user;
};

/**
 * Hook pour obtenir le rôle de l'utilisateur
 */
export const useUserRole = (): 'parent' | 'nounou' | 'admin' | null => {
  const { user } = useAuth();
  return user?.role || null;
};

/**
 * Hook pour vérifier si l'utilisateur a un rôle spécifique
 */
export const useHasRole = (role: 'parent' | 'nounou' | 'admin'): boolean => {
  const userRole = useUserRole();
  return userRole === role;
};

/**
 * Hook pour obtenir le plan de l'utilisateur
 */
export const useUserPlan = (): 'free' | 'starter' | 'full' | null => {
  const { user } = useAuth();
  return user?.plan || null;
};

/**
 * Hook pour vérifier si l'utilisateur a un plan spécifique ou supérieur
 */
export const useHasPlan = (minPlan: 'free' | 'starter' | 'full'): boolean => {
  const userPlan = useUserPlan();

  if (!userPlan) {
    return false;
  }

  const planHierarchy = { free: 0, starter: 1, full: 2 };
  return planHierarchy[userPlan] >= planHierarchy[minPlan];
};
