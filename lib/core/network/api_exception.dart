import 'package:dio/dio.dart';

/// 後端 / 網路層拋出的例外。Repository 會 catch 後轉成 `Result.failure(NetworkError(...))`。
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Object? cause;

  const ApiException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  /// 從 DioException 建構。對應 04-backend-spec.md 的錯誤格式
  /// （`{"error": "stock_not_found"}` 等）。
  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String message;
    if (data is Map && data['error'] is String) {
      message = data['error'] as String;
    } else {
      message = e.message ?? e.type.name;
    }
    return ApiException(statusCode: status, message: message, cause: e);
  }

  @override
  String toString() => 'ApiException(${statusCode ?? '-'}): $message';
}
