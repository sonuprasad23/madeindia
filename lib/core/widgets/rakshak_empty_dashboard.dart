import 'package:flutter/material.dart';

import 'rakshak_surfaces.dart';

/// Compact inline empty-state hint for dashboard sections — smaller than
/// [RakshakEmptyState], which is meant for full-screen empty states.
class RakshakEmptyDashboardHint extends StatelessWidget {
  const RakshakEmptyDashboardHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RakshakCard(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
