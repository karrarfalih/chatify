class Cache {
  Cache({required this.supportedTypes});

  final List<Type> supportedTypes;

  final Map<String, dynamic> _cache = <String, dynamic>{};

  T? set<T>(String key, T? value) {
    if (!supportedTypes.contains(T) || value == null) {
      return value;
    }
    _cache[key] = value;
    return value;
  }

  T? get<T>(String key) {
    return _cache[key];
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}
