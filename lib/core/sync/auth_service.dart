import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  try {
    return Supabase.instance.client.auth.onAuthStateChange;
  } catch (_) {
    return const Stream.empty();
  }
});

final currentUserProvider = Provider<User?>((ref) {
  try {
    return Supabase.instance.client.auth.currentUser;
  } catch (_) {
    return null;
  }
});

// ─── AuthService ─────────────────────────────────────────────────────────────

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  /// Sign in with Google via Supabase OAuth.
  /// On web: opens a popup / redirect flow back to current app base path.
  Future<void> signInWithGoogle() async {
    String? redirectUrl;
    if (kIsWeb) {
      final base = Uri.base;
      // Strip search query/hash and ensure trailing slash
      var path = base.path;
      if (!path.endsWith('/')) {
        path = '$path/';
      }
      redirectUrl = '${base.origin}$path';
    } else {
      redirectUrl = 'io.supabase.myfinance://login-callback';
    }

    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
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
