import 'package:shared_preferences/shared_preferences.dart';

class MemoryCache {
  static Map<String, dynamic> cache = {};

  static T? get<T>(String id) => cache['id'] as T?;
}

extension CacheExt<T> on T {
  T saveToCache() =>
      MemoryCache.cache.putIfAbsent((this as dynamic).id, () => this);
}

class Cache {
  static late final SharedPreferences instance;
  static init() async {
    instance = await SharedPreferences.getInstance();
  }
}
