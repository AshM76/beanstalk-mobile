import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  writeSecureData(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  readSecureData(String key) async {
    String value = await storage.read(key: key) ?? 'No secure storage data found!';
    print('Data read from secure storage: $value');
  }

  deleteSecureData(String key) async {
    await storage.delete(key: key);
  }

  static const _keyEmail = 'login_email';
  static const _keyPassword = 'login_password';

  Future<void> setSecureEmail(String email) async => await storage.write(key: _keyEmail, value: email);
  Future<void> setSecurePassword(String pass) async => await storage.write(key: _keyPassword, value: pass);

  Future<String?> getSecureEmail() async => await storage.read(key: _keyEmail);
  Future<String?> getSecurePassword() async => await storage.read(key: _keyPassword);
}
