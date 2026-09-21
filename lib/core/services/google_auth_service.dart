import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
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

  Future<GoogleAuthUser?> signIn() async {
    if (isSupportedPlatform) {
      try {
        _account = await _googleSignIn.signIn();
        if (_account != null) {
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
