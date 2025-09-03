// lib/features/auth/presentation/sign_in_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../profile/data/identity_api.dart';
import '../providers/auth_provider.dart';
import '../../../theme/widgets/brand_header.dart';
import '../../../theme/widgets/app_button.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool loading = false;
  String? error;

  Future<void> _login() async {
    setState(() { loading = true; error = null; });

    final auth = ref.read(authServiceProvider);
    final ok = await auth.signIn();
    if (!ok) { setState(() { loading = false; error = 'Could not sign in'; }); return; }

    // Testea whoAmI para asegurar acceso
    final dio = buildDio(tokenProvider: ({forceRefresh = false}) => auth.ensureValidAccessToken());
    try {
      await IdentityApi(dio, ref.read(tokenStorageProvider)).Link();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() { error = 'Error validating session: $e'; });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const BrandHeader(title: 'Welcome', subtitle: 'Sign in to continue'),
              if (error != null) Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              AppButton(text: 'Sign In', onPressed: _login, loading: loading),
              const SizedBox(height: 10),
              TextButton(onPressed: () => context.go('/register'), child: const Text('Don\'t have an account? Register'))
            ]),
          ),
        ),
      ),
    );
  }
}
