import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import pour debugPrint

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Session? get currentSession => _supabase.auth.currentSession;

  // Sign Up avec Email/Password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
        emailRedirectTo: null, // Pas de redirection email pour MVP
      );
      
      if (response.user != null) {
        notifyListeners();
      }
      
      return response;
    } catch (e) {
      debugPrint('Erreur signUp: $e');
      rethrow;
    }
  }

  // Sign In avec Email/Password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user != null) {
        notifyListeners();
      }
      
      return response;
    } catch (e) {
      debugPrint('Erreur signIn: $e');
      debugPrint('Email tenté: ${email.trim()}');
      rethrow;
    }
  }

  // Sign In with Apple
  Future<bool> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.manounou://login-callback/',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }

  // Écouter les changements d'authentification
  void listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }
}

