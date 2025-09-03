import 'package:app/core/storage/token_storage.dart';
import 'package:dio/dio.dart';

class WhoAmI {
  final int accountId;
  final Person person;
  WhoAmI({required this.accountId, required this.person});

  factory WhoAmI.fromJson(Map<String, dynamic> j) => WhoAmI(
    accountId: j['account_id'] ?? 0,
    person: Person.fromJson(j['person'] ?? {}),
  );
}
class Person{
  final int id;
  final String name;
  final String email;
  Person({required this.id, required this.name, required this.email});

  factory Person.fromJson(Map<String, dynamic> j) => Person(
    id: j['id'] ?? 0,
    name: j['name'] ?? '',
    email: j['email'] ?? '',
  );
}

class IdentityApi {
  final Dio dio;
  final TokenStorage storage;
  IdentityApi(this.dio, this.storage);

  Future<WhoAmI> Link() async {
    final idt = await storage.id;
    if (idt == null || idt.isEmpty) {
      throw Exception('Missing ID token');
    }
    final r = await dio.post('/api/v1/end-user-app/identity/link',
    options: Options(headers: {'X-ID-Token': idt})
    );
    return WhoAmI.fromJson(r.data as Map<String, dynamic>);
  }
  Future<WhoAmI> whoAmI() async {
    final r = await dio.get('/api/v1/end-user-app/identity/whoami');
    return WhoAmI.fromJson(r.data as Map<String, dynamic>);
  }
}
