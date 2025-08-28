import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/identity_api.dart';
import '../../auth/presentation/sign_out_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  WhoAmI? who;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = ref.read(authServiceProvider);
    final dio = buildDio(tokenProvider: () => auth.accessToken);
    try {
      final w = await IdentityApi(dio).whoAmI();
      setState(() => who = w);
    } catch (_) {
      if (mounted) context.go('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Paciente'), actions: const [SignOutButton()]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: who == null
            ? const Center(child: CircularProgressIndicator())
            : Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: cs.onSurface),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('¡Hola!', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text('Correo: ${who!.email}'),
                      Text('Rol: ${who!.role}'),
                      const SizedBox(height: 12),
                      Text('Grupos: ${who!.groups.join(', ')}'),
                    ]),
                  ),
                ),
              ),
      ),
    );
  }
}
