import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import 'rakshak_button.dart';

/// Shown when a list/screen genuinely has no content yet, with a clear
/// next action instead of a bare "No data" message.
class RakshakEmptyState extends StatelessWidget {
  const RakshakEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.xxl,
        horizontal: Spacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: Spacing.lg),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: Spacing.lg),
            RakshakButton(
              label: actionLabel!,
              onPressed: onAction,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown when an operation fails, with a retry affordance and no raw
/// exception text surfaced to the user.
class RakshakErrorState extends StatelessWidget {
  const RakshakErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.xxl,
        horizontal: Spacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: Spacing.lg),
            RakshakButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-content skeleton/loading placeholder.
class RakshakLoadingState extends StatelessWidget {
  const RakshakLoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: Spacing.lg),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Simple shimmering skeleton block for list-item loading placeholders.
class RakshakSkeleton extends StatefulWidget {
  const RakshakSkeleton({super.key, this.height = 16, this.width});

  final double height;
  final double? width;

  @override
  State<RakshakSkeleton> createState() => _RakshakSkeletonState();
}

class _RakshakSkeletonState extends State<RakshakSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: base.withValues(alpha: 0.5 + _controller.value * 0.3),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
        );
      },
    );
  }
}
