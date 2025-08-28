import 'package:dio/dio.dart';

class WhoAmI {
  final int personId;
  final String email;
  final String role;
  final List<String> groups;
  WhoAmI({required this.personId, required this.email, required this.role, required this.groups});

  factory WhoAmI.fromJson(Map<String, dynamic> j) => WhoAmI(
    personId: j['personId'] ?? 0,
    email: j['email'] ?? '',
    role: j['role'] ?? '',
    groups: (j['groups'] as List?)?.cast<String>() ?? const [],
  );
}

class IdentityApi {
  final Dio dio;
  IdentityApi(this.dio);

  Future<WhoAmI> whoAmI() async {
    final r = await dio.get('/api/v1/patient-app/identity/whoami');
    return WhoAmI.fromJson(r.data as Map<String, dynamic>);
  }
}
