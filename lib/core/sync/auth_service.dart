import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

// ─── AuthService ─────────────────────────────────────────────────────────────

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  /// Sign in with Google via Supabase OAuth.
  /// On web: opens a popup / redirect flow.
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.myfinance://login-callback',
      authScreenLaunchMode: LaunchMode.platformDefault,
    );
  }

  /// Sign out from Supabase (clears local session).
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Returns true if the current session is valid.
  Future<bool> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return response.session != null;
    } catch (_) {
      return false;
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});
