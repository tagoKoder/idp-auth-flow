// lib/core/network/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Future<String?> Function({bool forceRefresh}) tokenProvider;
  AuthInterceptor({required this.dio, required this.tokenProvider});

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final isApi = options.path.startsWith('/api') || options.uri.path.startsWith('/api');
    if (isApi && !options.headers.containsKey('Authorization')) {
      final token = await tokenProvider();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si expira: intenta 1 refresh y reintenta la request original
    if (err.response?.statusCode == 401 && err.requestOptions.extra['retried'] != true) {
      try {
        final token = await tokenProvider(forceRefresh: true);
        if (token != null && token.isNotEmpty) {
          final req = err.requestOptions;

          // Actualiza headers y marca que ya reintentamos
          final newHeaders = Map<String, dynamic>.from(req.headers)..['Authorization'] = 'Bearer $token';
          final newExtra   = Map<String, dynamic>.from(req.extra)..['retried'] = true;

          final newOptions = req.copyWith(headers: newHeaders, extra: newExtra);

          // ⚠️ Si envías FormData con streams, quizá debas recrearlo.
          final response = await dio.fetch(newOptions);   // reintento
          return handler.resolve(response);               // devuelve el nuevo OK
        }
      } catch (_) {
        // cae al error original
      }
    }
    handler.next(err);
  }
}
