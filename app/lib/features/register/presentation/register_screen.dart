import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/enrollment_service.dart';
import '../../../theme/widgets/brand_header.dart';
import '../../../theme/widgets/app_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool opening = false;
  String? error;

  Future<void> _openEnrollment() async {
    setState(() { opening = true; error = null; });
    try {
      final dio = buildDio(tokenProvider: () async => null); // público
      await EnrollmentService(dio).openPatientEnrollment();
    } catch (e) {
      setState(() { error = '$e'; });
    } finally {
      setState(() { opening = false; });
    }
  }

  Future<void> _goLogin() async {
    if (mounted) context.go('/signin');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const BrandHeader(title: 'Crear cuenta', subtitle: 'Regístrate como paciente'),
              Text(
                'Te llevaremos a una página segura para completar tu registro. '
                'Al finalizar, vuelve a la app y presiona “Ya me registré” para iniciar sesión.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (error != null) Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(error!, style: TextStyle(color: cs.error)),
              ),
              Row(children: [
                AppButton(text: 'Ir al registro', onPressed: _openEnrollment, loading: opening),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: _goLogin, child: const Text('Ya me registré')),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
