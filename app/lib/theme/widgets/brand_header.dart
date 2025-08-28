import 'package:flutter/material.dart';

class BrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const BrandHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cs.primary)),
        const SizedBox(height: 8),
        Text(subtitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 16),
      ],
    );
  }
}
