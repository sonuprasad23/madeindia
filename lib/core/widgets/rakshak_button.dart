import 'package:flutter/material.dart';

/// Primary action button used throughout Rakshak.
///
/// Wraps [FilledButton]/[OutlinedButton]/[TextButton] so call sites don't
/// hand-roll button styling — spacing/sizing already comes from
/// [AppTheme], this widget adds the loading-state and icon conventions.
class RakshakButton extends StatelessWidget {
  const RakshakButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = RakshakButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final RakshakButtonVariant variant;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: variant == RakshakButtonVariant.primary
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final effectiveOnPressed = isLoading ? null : onPressed;

    final button = switch (variant) {
      RakshakButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      RakshakButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      RakshakButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      RakshakButtonVariant.destructive => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        onPressed: effectiveOnPressed,
        child: child,
      ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

enum RakshakButtonVariant { primary, secondary, text, destructive }
