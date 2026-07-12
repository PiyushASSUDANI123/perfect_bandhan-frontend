import re

file_path = '/Users/piyush/Documents/perfectbandhan/shadi_frontend/lib/utils/storage_helper.dart'
new_code = """import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
"""

with open(file_path, 'w') as f:
    f.write(new_code)
print("storage_helper.dart patched successfully for flutter_secure_storage.")
