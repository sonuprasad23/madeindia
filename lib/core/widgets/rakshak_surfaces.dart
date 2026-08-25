import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Standard content card. Centralizes padding/radius so screens never
/// hand-roll `Container(decoration: ...)` for basic surfaces.
class RakshakCard extends StatelessWidget {
  const RakshakCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Spacing.lg),
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.lg),
      child: card,
    );
  }
}

/// Section header used to introduce a group of content ("My Cases",
/// "Recent activity", ...) with an optional trailing action.
class RakshakSectionHeader extends StatelessWidget {
  const RakshakSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Avatar for a citizen profile — falls back to initials when no image is
/// available, which is always the case in this demo (no real photo upload
/// flow for profile pictures).
class RakshakAvatar extends StatelessWidget {
  const RakshakAvatar({super.key, required this.name, this.radius = 24});

  final String name;
  final double radius;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.secondaryContainer,
      foregroundColor: scheme.onSecondaryContainer,
      child: Text(
        _initials,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: radius * 0.7),
      ),
    );
  }
}
