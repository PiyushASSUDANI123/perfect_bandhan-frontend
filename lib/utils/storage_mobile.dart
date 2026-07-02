import 'dart:convert';
import 'dart:io';

class StorageHelper {
  static Map<String, String>? _cache;

  static Future<void> _init() async {
    if (_cache != null) return;
    try {
      final file = File('.local_storage.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        _cache = Map<String, String>.from(jsonDecode(content));
      } else {
        _cache = {};
      }
    } catch (_) {
      _cache = {};
    }
  }

  static Future<void> setString(String key, String value) async {
    await _init();
    _cache![key] = value;
    try {
      final file = File('.local_storage.json');
      await file.writeAsString(jsonEncode(_cache));
    } catch (_) {}
  }

  static Future<String?> getString(String key) async {
    await _init();
    return _cache![key];
  }

  static Future<void> remove(String key) async {
    await _init();
    _cache!.remove(key);
    try {
      final file = File('.local_storage.json');
      await file.writeAsString(jsonEncode(_cache));
    } catch (_) {}
  }
}
