part of 'pagination_cubit.dart';

@immutable
abstract class PaginationState<T> {}

class PaginationInitial extends PaginationState {}

class PaginationError extends PaginationState {
  final Exception error;
  PaginationError({required this.error});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginationError && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}

class PaginationLoaded<T> extends PaginationState {
  PaginationLoaded({
    required this.documentSnapshots,
    required this.hasReachedEnd,
  });

  final bool hasReachedEnd;
  final List<DocumentSnapshot<T>> documentSnapshots;

  PaginationLoaded copyWith({
    bool? hasReachedEnd,
    List<DocumentSnapshot<T>>? documentSnapshots,
  }) {
    return PaginationLoaded(
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      documentSnapshots: documentSnapshots ?? this.documentSnapshots,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginationLoaded &&
        other.hasReachedEnd == hasReachedEnd &&
        listEquals(other.documentSnapshots, documentSnapshots);
  }

  @override
  int get hashCode => hasReachedEnd.hashCode ^ documentSnapshots.hashCode;
}
