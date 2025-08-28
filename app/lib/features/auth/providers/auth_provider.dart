import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_service.dart';

final tokenStorageProvider = Provider((_) => TokenStorage());
final authServiceProvider = Provider((ref) => AuthService(ref.read(tokenStorageProvider)));

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final token = await ref.read(authServiceProvider).accessToken;
  return token != null && token.isNotEmpty;
});
