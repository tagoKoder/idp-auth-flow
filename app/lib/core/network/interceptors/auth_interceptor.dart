import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Future<String?> Function() tokenProvider;
  AuthInterceptor({required this.tokenProvider});

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
}
