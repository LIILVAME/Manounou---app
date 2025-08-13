// Types lean - Version MVP simplifiée
export * from './database';

// Types utilisateur essentiels
export type UserRole = 'parent' | 'nounou' | 'admin';
export type UserPlan = 'free' | 'starter' | 'full';
export type Language = 'fr' | 'en';

// Interface utilisateur MVP
export interface AuthUser {
  id: string;
  email: string;
  displayName: string;
  role: UserRole;
  plan: UserPlan;
  avatarUrl?: string;
  phone?: string;
  address?: string;
  onboardingCompleted?: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Interface enfant MVP
export interface Child {
  id: string;
  parentId: string;
  firstName: string;
  lastName: string;
  birthDate: Date;
  avatar?: string;
  photo?: string;
  allergies?: string[];
  medicalInfo?: string;
  emergencyContact?: {
    name: string;
    phone: string;
    relation?: string;
  };
  createdAt: Date;
  updatedAt: Date;
}

// Interface document MVP
export interface Document {
  id: string;
  childId: string;
  name: string;
  type: 'medical' | 'authorization' | 'other';
  url: string;
  uploadedBy: string;
  createdAt: Date;
}

// Interface événement MVP
export interface Event {
  id: string;
  childId: string;
  child_id?: string;
  title: string;
  description?: string;
  startTime: Date;
  endTime: Date;
  start_time?: string;
  end_time?: string;
  type: 'garde' | 'activite' | 'medical' | 'repas' | 'autre';
  event_type?: string;
  location?: string;
  all_day?: boolean;
  createdBy: string;
  created_by?: string;
  createdAt: Date;
  created_at?: string;
  updated_at?: string;
}

// Interface relation MVP
export interface Relationship {
  id: string;
  parentId: string;
  nounouId: string;
  status: 'pending' | 'accepted' | 'declined';
  createdAt: Date;
  updatedAt: Date;
}

// Interface notification MVP
export interface Notification {
  id: string;
  userId: string;
  title: string;
  message: string;
  type: 'info' | 'warning' | 'success' | 'error';
  read: boolean;
  createdAt: Date;
}

// Types pour les formulaires
export interface SignUpFormData {
  email: string;
  password: string;
  confirmPassword: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  phone?: string;
}

export interface SignInFormData {
  email: string;
  password: string;
}

export interface ChildFormData {
  firstName: string;
  lastName: string;
  birthDate: Date;
  allergies?: string[];
  emergencyContactName?: string;
  emergencyContactPhone?: string;
}

export interface EventFormData {
  title: string;
  description?: string;
  startTime: Date;
  endTime: Date;
  type: Event['type'];
  childId: string;
}

// Types pour les réponses API
export interface ApiResponse<T = any> {
  data?: T;
  error?: string;
  success: boolean;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  hasMore: boolean;
}

// Types pour les erreurs
export interface ValidationError {
  field: string;
  message: string;
}

export interface FormErrors {
  [key: string]: string;
}

// Types pour les filtres et recherche
export interface SearchFilters {
  query?: string;
  type?: string;
  dateFrom?: Date;
  dateTo?: Date;
}

export interface SortOptions {
  field: string;
  direction: 'asc' | 'desc';
}

// Types pour la navigation
export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
  Onboarding: undefined;
};

export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
};

export type MainTabParamList = {
  Dashboard: undefined;
  Children: undefined;
  Schedule: undefined;
  Documents: undefined;
  Vacations: undefined;
  Profile: undefined;
};

// Interfaces supplémentaires pour compatibilité
export interface Schedule {
  id: string;
  childId: string;
  nounouId?: string;
  date: Date;
  startTime: string;
  endTime: string;
  activities: Activity[];
  notes?: string;
  status: 'planned' | 'confirmed' | 'completed' | 'cancelled';
  createdAt: Date;
  updatedAt: Date;
}

export interface Activity {
  id: string;
  name: string;
  type: 'meal' | 'nap' | 'play' | 'outing' | 'other';
  time: string;
  description?: string;
  completed?: boolean;
}

export interface Vacation {
  id: string;
  userId: string;
  startDate: Date;
  endDate: Date;
  reason?: string;
  status: 'pending' | 'approved' | 'rejected';
  createdAt: Date;
}

export interface Pack {
  id: string;
  name: 'free' | 'starter' | 'full';
  price: number;
  features: string[];
  maxChildren: number;
  maxDocuments: number;
}

// States pour les contextes
export interface AuthState {
  user: AuthUser | null;
  isLoading: boolean;
  isAuthenticated: boolean;
}

export interface I18nState {
  language: Language;
  translations: Record<string, string>;
}

// Alias pour compatibilité
export type User = AuthUser;
