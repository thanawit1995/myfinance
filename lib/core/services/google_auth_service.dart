import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleAuthUser {
  final String email;
  final String? displayName;
  final String? photoUrl;

  const GoogleAuthUser({
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}

class GoogleAuthService {
  static const _keyEmail = 'gdrive_user_email';
  static const _keyName = 'gdrive_user_name';
  static const _keyPhoto = 'gdrive_user_photo';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String driveScope = 'https://www.googleapis.com/auth/drive.file';
  static const String driveFullScope = 'https://www.googleapis.com/auth/drive';
  static const String webClientId = '25761984668-bisj0948pdlu6k6s1hvlpvbmqi9bb2r3.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? webClientId : null,
    serverClientId: null,
    scopes: [
      'email',
      driveScope,
      driveFullScope,
    ],
  );

  GoogleSignInAccount? _account;

  GoogleSignInAccount? get account => _account;

  bool get isSupportedPlatform =>
      kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  Future<GoogleAuthUser?> getCurrentUser() async {
    // 1. Try silent sign-in if supported
    if (isSupportedPlatform) {
      try {
        _account = await _googleSignIn.signInSilently();
        if (_account != null) {
          await _saveUser(_account!.email, _account!.displayName, _account!.photoUrl);
          return GoogleAuthUser(
            email: _account!.email,
            displayName: _account!.displayName,
            photoUrl: _account!.photoUrl,
          );
        }
      } catch (_) {}
    }

    // 2. Check cached in secure storage
    final email = await _storage.read(key: _keyEmail);
    if (email != null && email.isNotEmpty) {
      final name = await _storage.read(key: _keyName);
      final photo = await _storage.read(key: _keyPhoto);
      return GoogleAuthUser(email: email, displayName: name, photoUrl: photo);
    }

    return null;
  }

  /// Returns user info from local cache only — does NOT trigger Google Sign-In.
  /// Use this when you only want to display "who is logged in" without connecting.
  Future<GoogleAuthUser?> getCachedUser() async {
    final email = await _storage.read(key: _keyEmail);
    if (email != null && email.isNotEmpty) {
      final name = await _storage.read(key: _keyName);
      final photo = await _storage.read(key: _keyPhoto);
      return GoogleAuthUser(email: email, displayName: name, photoUrl: photo);
    }
    return null;
  }

  Future<GoogleAuthUser?> signIn() async {
    if (isSupportedPlatform) {
      try {
        _account = await _googleSignIn.signIn();
        if (_account != null) {
          if (kIsWeb) {
            try {
              await requestDriveScopeOnWeb();
            } catch (e) {
              debugPrint('requestScopes error on signIn: $e');
            }
          }
          await _saveUser(_account!.email, _account!.displayName, _account!.photoUrl);
          return GoogleAuthUser(
            email: _account!.email,
            displayName: _account!.displayName,
            photoUrl: _account!.photoUrl,
          );
        }
      } catch (e) {
        debugPrint('Google Sign-In error: $e');
        rethrow;
      }
    }
    return null;
  }

  Future<void> saveManualEmail(String email, {String? displayName}) async {
    await _saveUser(email, displayName, null);
  }

  /// ขอสิทธิ์ Drive scope เพิ่มเติมบน Web (ลองขอทั้ง full scope และ file scope)
  Future<bool> requestDriveScopeOnWeb() async {
    if (!kIsWeb) return true;
    try {
      final granted = await _googleSignIn.requestScopes([driveFullScope, driveScope]);
      if (granted) return true;
    } catch (e) {
      debugPrint('requestDriveScopeOnWeb full scope error: $e, trying driveScope');
    }
    try {
      return await _googleSignIn.requestScopes([driveScope]);
    } catch (e) {
      debugPrint('requestDriveScopeOnWeb error: $e');
      return false;
    }
  }

  /// สร้าง http.Client ที่มี Access Token ของ Google สำหรับคุยกับ Google APIs
  Future<http.Client?> getAuthenticatedClient({bool requestScopesIfNeeded = false}) async {
    if (!isSupportedPlatform) return null;

    if (_account == null) {
      if (requestScopesIfNeeded) {
        try {
          _account = await _googleSignIn.signInSilently();
        } catch (_) {}
      }
    }

    if (_account == null) return null;

    if (kIsWeb) {
      try {
        final canAccessFull = await _googleSignIn.canAccessScopes([driveFullScope]);
        final canAccessFile = await _googleSignIn.canAccessScopes([driveScope]);
        if (!canAccessFull && !canAccessFile) {
          if (requestScopesIfNeeded) {
            final granted = await requestDriveScopeOnWeb();
            if (!granted) {
              debugPrint('Drive scope was not granted by user');
              return null;
            }
          } else {
            return null;
          }
        }
      } catch (e) {
        debugPrint('canAccessScopes check error: $e');
        if (requestScopesIfNeeded) {
          try {
            final granted = await requestDriveScopeOnWeb();
            if (!granted) return null;
          } catch (_) {
            return null;
          }
        } else {
          return null;
        }
      }
    }

    final authHeaders = await _account!.authHeaders;
    return _GoogleAuthClient(authHeaders);
  }

  Future<void> signOut() async {
    if (isSupportedPlatform) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    _account = null;
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyName);
    await _storage.delete(key: _keyPhoto);
  }

  Future<void> _saveUser(String email, String? name, String? photo) async {
    await _storage.write(key: _keyEmail, value: email);
    if (name != null) await _storage.write(key: _keyName, value: name);
    if (photo != null) await _storage.write(key: _keyPhoto, value: photo);
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}
