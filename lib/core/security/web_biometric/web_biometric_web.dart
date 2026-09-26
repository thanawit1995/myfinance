// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js_interop';

@JS('MyFinanceWebAuthn')
external _MyFinanceWebAuthn? get _webAuthn;

extension type _MyFinanceWebAuthn._(JSObject _) implements JSObject {
  external JSPromise<JSBoolean> isSupported();
  external JSBoolean hasRegisteredCredential();
  external JSPromise<JSBoolean> register();
  external JSPromise<JSBoolean> authenticate();
  external void removeCredential();
}

class WebBiometricService {
  static Future<bool> isSupported() async {
    try {
      final helper = _webAuthn;
      if (helper == null) return false;
      final result = await helper.isSupported().toDart;
      return result.toDart;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> hasRegisteredCredential() async {
    try {
      final helper = _webAuthn;
      if (helper == null) return false;
      return helper.hasRegisteredCredential().toDart;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> register() async {
    try {
      final helper = _webAuthn;
      if (helper == null) return false;
      final result = await helper.register().toDart;
      return result.toDart;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      final helper = _webAuthn;
      if (helper == null) return false;
      final result = await helper.authenticate().toDart;
      return result.toDart;
    } catch (_) {
      return false;
    }
  }

  static Future<void> removeCredential() async {
    try {
      _webAuthn?.removeCredential();
    } catch (_) {}
  }
}
