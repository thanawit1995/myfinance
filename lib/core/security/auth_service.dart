import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'web_biometric/web_biometric_helper.dart';

class AuthService {
  static const _pinHashKey = 'user_pin_hash';
  static const _pinSaltKey = 'user_pin_salt';
  static const _pinLockEnabledKey = 'pref_pin_lock_enabled';
  static const _biometricEnabledKey = 'pref_biometric_enabled';
  static const _sessionTimeoutKey = 'pref_session_timeout_minutes';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  DateTime? _unlockedUntil;

  AuthService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  bool get isSessionUnlocked {
    if (_unlockedUntil == null) return false;
    return DateTime.now().isBefore(_unlockedUntil!);
  }

  Future<int> getSessionTimeoutMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionTimeoutKey) ?? 15;
  }

  Future<void> setSessionTimeoutMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionTimeoutKey, minutes);
  }

  Future<void> unlockSession([int? timeoutMinutes]) async {
    final minutes = timeoutMinutes ?? await getSessionTimeoutMinutes();
    _unlockedUntil = DateTime.now().add(Duration(minutes: minutes));
  }

  void lockSession() {
    _unlockedUntil = null;
  }

  Future<bool> isPinConfigured() async {
    try {
      final hash = await _secureStorage.read(key: _pinHashKey);
      return hash != null && hash.isNotEmpty;
    } catch (e) {
      debugPrint('Error reading secure storage: $e');
      return false;
    }
  }

  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  bool get isLockedOut => _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);
  int get remainingLockoutSeconds => _lockedUntil == null ? 0 : _lockedUntil!.difference(DateTime.now()).inSeconds.clamp(0, 300);

  Future<bool> isPinLockEnabled() async {
    final configured = await isPinConfigured();
    if (!configured) return false;
    
    // Read from secure storage first
    try {
      final secVal = await _secureStorage.read(key: _pinLockEnabledKey);
      if (secVal != null) {
        return secVal == 'true';
      }
    } catch (_) {}

    // Fallback migration from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final prefVal = prefs.getBool(_pinLockEnabledKey) ?? true;
    try {
      await _secureStorage.write(key: _pinLockEnabledKey, value: prefVal.toString());
    } catch (_) {}
    return prefVal;
  }

  Future<void> setPinLockEnabled(bool enabled) async {
    try {
      await _secureStorage.write(key: _pinLockEnabledKey, value: enabled.toString());
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinLockEnabledKey, enabled);
  }

  Future<bool> setPin(String pin) async {
    if (pin.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(pin)) {
      throw ArgumentError('PIN must be 6 digits');
    }

    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final salt = base64Encode(saltBytes);

    final hash = _hashPin(pin, salt);
    await _secureStorage.write(key: _pinSaltKey, value: salt);
    await _secureStorage.write(key: _pinHashKey, value: hash);
    await setPinLockEnabled(true);

    _failedAttempts = 0;
    _lockedUntil = null;
    await unlockSession();
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    if (isLockedOut) return false;

    final storedHash = await _secureStorage.read(key: _pinHashKey);
    final storedSalt = await _secureStorage.read(key: _pinSaltKey);

    if (storedHash == null || storedSalt == null) {
      return false;
    }

    final computedHash = _hashPin(pin, storedSalt);
    if (computedHash == storedHash) {
      _failedAttempts = 0;
      _lockedUntil = null;
      await unlockSession();
      return true;
    }

    _failedAttempts++;
    if (_failedAttempts >= 5) {
      _lockedUntil = DateTime.now().add(const Duration(seconds: 30));
    }
    return false;
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    final verified = await verifyPin(oldPin);
    if (!verified) return false;
    return setPin(newPin);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin:$salt');
    return sha256.convert(bytes).toString();
  }

  Future<bool> isBiometricsSupported() async {
    if (kIsWeb) {
      return WebBiometricService.isSupported();
    }
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricsEnabled() async {
    try {
      final secVal = await _secureStorage.read(key: _biometricEnabledKey);
      if (secVal != null) {
        return secVal == 'true';
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final prefVal = prefs.getBool(_biometricEnabledKey) ?? false;
    try {
      await _secureStorage.write(key: _biometricEnabledKey, value: prefVal.toString());
    } catch (_) {}
    return prefVal;
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    if (kIsWeb && enabled) {
      final hasCred = await WebBiometricService.hasRegisteredCredential();
      if (!hasCred) {
        final registered = await WebBiometricService.register();
        if (!registered) {
          throw Exception('เบราว์เซอร์ไม่สามารถลงทะเบียนระบบสแกนลายนิ้วมือ/ใบหน้าได้');
        }
      }
    } else if (kIsWeb && !enabled) {
      await WebBiometricService.removeCredential();
    }

    try {
      await _secureStorage.write(key: _biometricEnabledKey, value: enabled.toString());
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> authenticateBiometric({String reason = 'ปลดล็อก MyFinance'}) async {
    try {
      final enabled = await isBiometricsEnabled();
      if (!enabled) return false;

      if (kIsWeb) {
        final authenticated = await WebBiometricService.authenticate();
        if (authenticated) {
          await unlockSession();
        }
        return authenticated;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        await unlockSession();
      }
      return authenticated;
    } catch (e) {
      debugPrint('Biometric error: $e');
      return false;
    }
  }
}
