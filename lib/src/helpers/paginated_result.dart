typedef FuturePaginatedResult<T> = Future<PaginatedResult<T>>;

class PaginatedResult<T> {
  static const pageSize = 10;

  final List<T> items;
  final String? error;
  final bool _isLoading;
  final bool isFetched;
  final bool hasReachedEnd;

  bool get isSuccess => error == null && !_isLoading;
  bool get hasError => error != null;
  bool get isLoadingMore => _isLoading && items.isNotEmpty;
  bool get isInitialLoading => _isLoading && items.isEmpty;

  PaginatedResult({
    required this.items,
    required this.error,
    required bool isLoading,
    required this.isFetched,
    required this.hasReachedEnd,
  }) : _isLoading = isLoading;

  const PaginatedResult.loading()
      : items = const [],
        error = null,
        _isLoading = false,
        isFetched = false,
        hasReachedEnd = false;

  const PaginatedResult.success(this.items, this.hasReachedEnd)
      : error = null,
        _isLoading = false,
        isFetched = true;

  const PaginatedResult.failure(this.error)
      : items = const [],
        _isLoading = false,
        hasReachedEnd = false,
        isFetched = true;

  PaginatedResult<R> map<R>(R Function(T) mapper) {
    return PaginatedResult<R>(
      items: items.map(mapper).toList(),
      error: error,
      isLoading: _isLoading,
      hasReachedEnd: hasReachedEnd,
      isFetched: isFetched,
    );
  }

  @override
  String toString() {
    return 'PaginatedResult(hasItems: ${items.isNotEmpty}, error: $error, hasReachedEnd: $hasReachedEnd, isInitialLoading: $isInitialLoading, isLoadingMore: $isLoadingMore)';
  }
}
