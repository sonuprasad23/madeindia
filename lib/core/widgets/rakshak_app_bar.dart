import 'package:flutter/material.dart';

/// Standard app bar used across feature screens. Kept as a thin wrapper so
/// every screen gets identical elevation/back-button/action conventions.
class RakshakAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RakshakAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.bottom,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      bottom: bottom,
    );
  }
}
