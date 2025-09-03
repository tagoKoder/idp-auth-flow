// lib/features/profile/presentation/home_screen.dart
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
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { error = null; });
    final auth = ref.read(authServiceProvider);
    final dio = buildDio(
      tokenProvider: ({forceRefresh = false}) =>
          auth.ensureValidAccessToken(forceRefresh: forceRefresh),
    );
    try {
      // 👉 usamos LINK para hacer el upsert JIT y traer los datos frescos
      final w = await IdentityApi(dio, ref.read(tokenStorageProvider)).whoAmI();
      if (!mounted) return;
      setState(() => who = w);
    } catch (e) {
      if (!mounted) return;
      // Si es 401 te manda al login, si no, muestra el error
      setState(() => error = '$e');
      context.go('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget content;
    if (who == null && error == null) {
      content = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      content = Center(child: Text(error!, style: TextStyle(color: cs.error)));
    } else {
      content = Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: cs.onSurface),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bienvenido 👋', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text('Account ID: ${who!.accountId}'),
                const SizedBox(height: 8),
                Text('Person ID:  ${who!.person.id}'),
                Text('Nombre:     ${who!.person.name}'),
                Text('Email:      ${who!.person.email}'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton(onPressed: _load, child: const Text('Actualizar')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Patient'), actions: const [SignOutButton()]),
      body: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }
}
