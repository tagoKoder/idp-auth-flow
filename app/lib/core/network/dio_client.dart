// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../config/env.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/telemetry_interceptor.dart';

Dio buildDio({required Future<String?> Function({bool? forceRefresh}) tokenProvider}) {
  final dio = Dio(BaseOptions(baseUrl: Env.apiBase, connectTimeout: const Duration(seconds: 10)));
  dio.interceptors.add(TelemetryInterceptor());
  dio.interceptors.add(AuthInterceptor(dio: dio, tokenProvider: tokenProvider));
  return dio;
}
