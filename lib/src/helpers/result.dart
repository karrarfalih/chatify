import 'package:flutter/foundation.dart';

typedef FutureResult<T> = Future<Result<T>>;

final class Result<T> {
  final String? error;
  final bool isLoading;
  final T? data;

  const Result._({
    this.error,
    this.isLoading = false,
    this.data,
  });

  bool get isSuccess => (data != null || error == null) && !isLoading;
  bool get hasError => error != null;

  const Result.loading() : this._(isLoading: true);

  const Result.success(T data) : this._(data: data);

  const Result.failure(String error) : this._(error: error);

  static Future<void> Function(String error)? errorHandler;

  Future<Result<T>> when({
    Function()? onStart,
    required Function(T value)? onSuccess,
    required Function(String error)? onError,
  }) async {
    if (isLoading && onStart != null) {
      await onStart();
    } else if (isSuccess) {
      await onSuccess?.call(data as T);
    } else {
      await onError?.call(error!);
    }
    return this;
  }

  whenSync({
    Function()? onStart,
    required Function(T value)? onSuccess,
    required Function(String error)? onError,
  }) {
    if (isLoading && onStart != null) {
      return onStart();
    } else if (isSuccess) {
      return onSuccess?.call(data as T);
    } else {
      return onError?.call(error!);
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Result<T> &&
        other.error == error &&
        other.isLoading == isLoading &&
        other.data == data;
  }

  @override
  int get hashCode => error.hashCode ^ isLoading.hashCode ^ data.hashCode;

  @override
  String toString() {
    if (isLoading) {
      return 'Result.loading()';
    } else if (isSuccess) {
      return 'Result.success($data)';
    } else {
      return 'Result.failure($error)';
    }
  }

  Result<T> copyWith({
    String? error,
    bool? isLoading,
    T? data,
  }) {
    return Result._(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
    );
  }

  Result<R> map<R>(R? Function(T? value) map) => Result._(
        error: error,
        isLoading: isLoading,
        data: map(data),
      );
}

extension ResultX<S> on Future<Result<S>> {
  Future whenSuccess(Function(S value) onSuccess) async {
    (await this).when(
      onSuccess: onSuccess,
      onError: null,
    );
  }

  Future whenFailure(Function(String error) onError) async {
    (await this).when(
      onSuccess: null,
      onError: onError,
    );
  }

  Future<Result<S>> when({
    Function()? onStart,
    required Function(S value)? onSuccess,
    Function(String error)? onError,
    Function()? onDone,
    Function(bool isLoading)? onLoading,
  }) async {
    try {
    await onStart?.call();
    await onLoading?.call(true);
    final result = await (await this).when(
      onSuccess: (value) async => await onSuccess?.call(value),
      onError: (error) async => await (onError != null
          ? onError(error)
          : Result.errorHandler?.call(error)),
    );
    await onDone?.call();
    await onLoading?.call(false);
    return result;
    } catch (e) {
      await onLoading?.call(false);
      await (onError != null
          ? onError('Something went wrong')
          : Result.errorHandler?.call('Something went wrong'));
      if (kDebugMode) {
        rethrow;
      }
      return Result.failure('Something went wrong');
    }
  }

  Future<Result<S>> linkWithState(
    Function(Result<S> e) onData, {
    Function(S e)? onSuccess,
    Function(String error)? onError,
  }) async {
    Result<S> result = const Result.loading();
    await this.when(
      onStart: () => onData(const Result.loading()),
      onSuccess: (value) async {
        result = Result.success(value);
        onData(result);
        await onSuccess?.call(value);
      },
      onError: (error) {
        result = Result.failure(error);
        onData(result);
        onError?.call(error);
      },
    );
    return result;
  }
}
