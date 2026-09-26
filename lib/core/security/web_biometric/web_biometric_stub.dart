class WebBiometricService {
  static Future<bool> isSupported() async => false;
  static Future<bool> hasRegisteredCredential() async => false;
  static Future<bool> register() async => false;
  static Future<bool> authenticate() async => false;
  static Future<void> removeCredential() async {}
}
