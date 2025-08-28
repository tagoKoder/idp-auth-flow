import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../utils/platform_info.dart';

class TelemetryInterceptor extends Interceptor {
  final _uuid = const Uuid();
  Map<String, String>? _cachedDevice;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Solo /api
    final isApi = options.path.startsWith('/api') || options.uri.path.startsWith('/api');
    if (isApi) {
      _cachedDevice ??= await PlatformInfo.headers();
      options.headers.addAll({
        'x-correlation-id': _uuid.v4(),
        ...?_cachedDevice,
      });
    }
    handler.next(options);
  }
}
