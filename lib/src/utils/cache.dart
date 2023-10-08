class Cache {
  static Map<String, dynamic> cache = {};

  static T? get<T>(String id) => cache['id'] as T?;
}

extension CacheExt<T> on T {
  T saveToCache() => Cache.cache.putIfAbsent((this as dynamic).id, () => this);
}
