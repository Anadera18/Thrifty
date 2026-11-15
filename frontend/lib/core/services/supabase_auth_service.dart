import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseClient get _client => Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) {
    return _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'display_name': displayName.trim(),
        'role': role,
      },
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    return _client
        .from('profiles')
        .select('id, display_name, role, created_at')
        .eq('id', userId)
        .maybeSingle();
  }

  Future<void> signOut() => _client.auth.signOut();
}
