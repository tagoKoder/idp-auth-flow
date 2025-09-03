// lib/core/utils/platform_info.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PlatformInfo {
  static Future<Map<String, String>> headers() async {
    final deviceInfo = DeviceInfoPlugin();
    final pkg = await PackageInfo.fromPlatform();

    String os = 'unknown', osVersion = '', model = '';
    try {
      final android = await deviceInfo.androidInfo;
      os = 'android'; osVersion = '${android.version.release} (${android.version.sdkInt})';
      model = '${android.manufacturer} ${android.model}';
    } catch (_) {
      final ios = await deviceInfo.iosInfo;
      os = 'ios'; osVersion = ios.systemVersion ?? '';
      model = ios.utsname.machine ?? '';
    }

    return {
      'x-device-os': os,
      'x-device-os-version': osVersion,
      'x-device-model': model,
      'x-app-version': '${pkg.version}+${pkg.buildNumber}',
    };
  }
}
