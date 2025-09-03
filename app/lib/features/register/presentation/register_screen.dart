import 'package:app/core/config/env.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/enrollment_service.dart';
import '../../../theme/widgets/brand_header.dart';
import '../../../theme/widgets/app_button.dart';
import 'package:url_launcher/url_launcher.dart';

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
      final dio = buildDio(tokenProvider: ({forceRefresh = false}) async => null); // público
      //await EnrollmentService(dio).openPatientEnrollment();
      final ok = await launchUrl(Uri.parse(Env.enrollmentRedirectUrl), mode: LaunchMode.externalApplication);
    if (!ok) { throw Exception('Could not open browser'); }
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
                const BrandHeader(title: 'Create Account', subtitle: 'Register as a patient'),
                Text(
                'We will take you to a secure page to complete your registration. '
                'When you finish, return to the app and press “I have already registered” to sign in.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (error != null) Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(error!, style: TextStyle(color: cs.error)),
              ),
              Row(children: [
                AppButton(text: 'Go to Registration', onPressed: _openEnrollment, loading: opening),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: _goLogin, child: const Text('I have already registered')),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
