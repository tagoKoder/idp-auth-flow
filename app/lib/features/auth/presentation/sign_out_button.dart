import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';

class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Cerrar sesión',
      onPressed: () async {
        await ref.read(authServiceProvider).signOut();
        if (context.mounted) context.go('/signin');
      },
      icon: const Icon(Icons.logout),
    );
  }
}
