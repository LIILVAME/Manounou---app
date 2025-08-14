import 'react-native-url-polyfill/auto';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Configuration Supabase avec variables d'environnement
const supabaseUrl =
  process.env.EXPO_PUBLIC_SUPABASE_URL || 'https://placeholder.supabase.co';
const supabaseAnonKey =
  process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || 'placeholder-anon-key';

// Vérification si nous sommes en mode développement sans vraie configuration Supabase
const isDevelopmentMode =
  supabaseUrl.includes('placeholder') ||
  supabaseAnonKey.includes('placeholder');

let supabaseClient: SupabaseClient;

if (isDevelopmentMode) {
  // Mode développement - créer un client avec des URLs de test
  console.warn(
    '⚠️ Mode développement Supabase - Utilisation de configuration de test'
  );
  supabaseClient = createClient('https://test.supabase.co', 'test-anon-key', {
    auth: {
      storage: AsyncStorage,
      autoRefreshToken: false,
      persistSession: false,
      detectSessionInUrl: false,
    },
  });
} else {
  // Mode production - utiliser le vrai client Supabase
  supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
    auth: {
      storage: AsyncStorage,
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false,
    },
  });
}

export const supabase = supabaseClient;

export default supabase;
