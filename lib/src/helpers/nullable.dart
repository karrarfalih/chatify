class Nullable<T> {
  final T? value;

  const Nullable(this.value);

  const Nullable.nl() : value = null;

  bool get isNull => value == null;

  bool get isNotNull => value != null;

  Nullable<T> get copyToNull => const Nullable.nl();

  @override
  String toString() {
    return value.toString();
  }

  @override
  bool operator ==(Object other) {
    if (other is Nullable<T>) {
      return value == other.value;
    }
    return false;
  }
  
  @override
  int get hashCode => value.hashCode;
  
}


extension NullableExtension<T> on T? {
  Nullable<T> get nl => Nullable(this);
}