import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/widgets/rakshak_logo.dart';
import '../auth/admin_auth_controller.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child, required this.currentPath});

  final Widget child;
  final String currentPath;

  static const _destinations = [
    (
      route: AppRoutes.adminDashboard,
      icon: Icons.dashboard_outlined,
      label: 'Overview',
    ),
    (
      route: AppRoutes.adminUsers,
      icon: Icons.people_outline_rounded,
      label: 'Users',
    ),
    (
      route: AppRoutes.adminCases,
      icon: Icons.folder_copy_outlined,
      label: 'Cases',
    ),
    (
      route: AppRoutes.adminLinks,
      icon: Icons.link_rounded,
      label: 'Threat Intelligence',
    ),
    (
      route: AppRoutes.adminContent,
      icon: Icons.menu_book_outlined,
      label: 'Content',
    ),
    (
      route: AppRoutes.adminSettings,
      icon: Icons.settings_outlined,
      label: 'Settings',
    ),
  ];

  int get _selectedIndex {
    for (var i = 0; i < _destinations.length; i++) {
      if (currentPath.startsWith(_destinations[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    final nav = NavigationRail(
      extended: isWide,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => context.go(_destinations[i].route),
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: RakshakLogo(size: 28),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await ref.read(adminAuthProvider.notifier).signOut();
                if (context.mounted) context.go(AppRoutes.adminLogin);
              },
            ),
          ),
        ),
      ),
      destinations: _destinations
          .map(
            (d) => NavigationRailDestination(
              icon: Icon(d.icon),
              label: Text(d.label),
            ),
          )
          .toList(),
    );

    return Scaffold(
      body: Row(
        children: [
          nav,
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
