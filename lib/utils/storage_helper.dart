import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  static const _secureStorage = FlutterSecureStorage();

  static Future<void> save(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> get(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }
}
