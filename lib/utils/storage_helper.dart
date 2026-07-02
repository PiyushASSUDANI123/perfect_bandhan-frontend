import 'storage_stub.dart'
    if (dart.library.html) 'storage_web.dart'
    if (dart.library.io) 'storage_mobile.dart';

class AppStorage {
  static Future<void> save(String key, String value) {
    return StorageHelper.setString(key, value);
  }

  static Future<String?> get(String key) {
    return StorageHelper.getString(key);
  }

  static Future<void> delete(String key) {
    return StorageHelper.remove(key);
  }
}
