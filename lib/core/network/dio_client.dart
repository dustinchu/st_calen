import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/app_constants.dart';

/// 全域 dio instance：base URL 從 `--dart-define=STOCK_API_BASE` 注入，
/// timeouts 依 04-backend-spec.md：connect 3s / receive 5s。
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kStockApiBaseUrl,
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 5),
      responseType: ResponseType.json,
      headers: const {'Accept': 'application/json'},
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  return dio;
});
