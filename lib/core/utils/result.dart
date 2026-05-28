/// 通用結果封裝：Success 攜帶值，Failure 攜帶 [AppError]。
///
/// Repository / use case 層回傳 `Result<T, AppError>`，
/// ViewModel 再轉成 [AsyncValue] 或自家 UI state。
sealed class Result<T, E> {
  const Result();

  const factory Result.success(T value) = Success<T, E>;
  const factory Result.failure(E error) = Failure<T, E>;

  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  });

  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) =>
      when(success: onSuccess, failure: onFailure);

  Result<R, E> map<R>(R Function(T value) transform);

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;
}

final class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) =>
      success(value);

  @override
  Result<R, E> map<R>(R Function(T value) transform) =>
      Success<R, E>(transform(value));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class Failure<T, E> extends Result<T, E> {
  final E error;
  const Failure(this.error);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) =>
      failure(error);

  @override
  Result<R, E> map<R>(R Function(T value) transform) => Failure<R, E>(error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> && other.error == error;

  @override
  int get hashCode => error.hashCode;
}

/// Repository / use case 層統一錯誤類型。
///
/// 目前只列出 Phase 1 一定會用到的分類，新分類在實際遇到時再補。
sealed class AppError {
  final String message;
  const AppError(this.message);

  @override
  String toString() => '$runtimeType($message)';
}

/// 網路 / 後端錯誤。`statusCode` 在非 HTTP 失敗（timeout 等）時為 null。
final class NetworkError extends AppError {
  final int? statusCode;
  const NetworkError(super.message, {this.statusCode});
}

/// 資源不存在（404、Hive box 內找不到 key）。
final class NotFoundError extends AppError {
  const NotFoundError([super.message = 'not found']);
}

/// 預期外的內部錯誤（解析失敗、未分類例外）。
final class UnknownError extends AppError {
  const UnknownError(super.message);
}
