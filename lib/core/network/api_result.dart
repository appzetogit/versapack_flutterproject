import '../errors/failure.dart';

/// Either-style wrapper so repositories never throw across a layer boundary.
sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T value) = Success<T>;
  const factory ApiResult.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        FailureResult<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        FailureResult<T>(:final failure) => failure,
      };

  R fold<R>(R Function(T value) onSuccess, R Function(Failure f) onFailure) =>
      switch (this) {
        Success<T>(:final value) => onSuccess(value),
        FailureResult<T>(:final failure) => onFailure(failure),
      };

  ApiResult<R> map<R>(R Function(T value) transform) => switch (this) {
        Success<T>(:final value) => ApiResult<R>.success(transform(value)),
        FailureResult<T>(:final failure) => ApiResult<R>.failure(failure),
      };

  /// Unwraps or throws — only for call sites that already handled failure.
  T get requireValue => switch (this) {
        Success<T>(:final value) => value,
        FailureResult<T>(:final failure) => throw StateError(failure.message),
      };
}

final class Success<T> extends ApiResult<T> {
  const Success(this.value);
  final T value;
}

final class FailureResult<T> extends ApiResult<T> {
  const FailureResult(this.failure);
  final Failure failure;
}
