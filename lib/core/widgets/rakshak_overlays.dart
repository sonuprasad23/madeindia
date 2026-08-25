import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import 'rakshak_button.dart';

/// Shows a standard Rakshak bottom sheet with consistent padding and a
/// drag handle (from [AppTheme.bottomSheetTheme]).
Future<T?> showRakshakBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.lg,
        top: Spacing.lg,
        bottom: Spacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: builder(context),
    ),
  );
}

/// Standard confirmation/info dialog with up to two actions.
class RakshakDialog extends StatelessWidget {
  const RakshakDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryLabel = 'OK',
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData? icon;
  final Color? iconColor;

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => RakshakDialog(
        title: title,
        message: message,
        primaryLabel: confirmLabel,
        onPrimary: () => Navigator.of(context).pop(true),
        secondaryLabel: cancelLabel,
        onSecondary: () => Navigator.of(context).pop(false),
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon != null ? Icon(icon, color: iconColor) : null,
      title: Text(title),
      content: Text(message),
      actions: [
        if (secondaryLabel != null)
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
        RakshakButton(
          label: primaryLabel,
          onPressed: onPrimary ?? () => Navigator.of(context).pop(),
          expand: false,
        ),
      ],
    );
  }
}
