import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/rakshak_logo.dart';
import 'app_routes.dart';

/// Root shell providing responsive bottom-navigation (phones) or a
/// navigation rail (tablet/desktop widths) across the five primary
/// sections, plus a globally accessible "Ask Rakshak" assistant action.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.currentPath});

  final Widget child;
  final String currentPath;

  static const _destinations = [
    (
      route: AppRoutes.home,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    (
      route: AppRoutes.protect,
      icon: Icons.shield_outlined,
      selectedIcon: Icons.shield_rounded,
      label: 'Protect',
    ),
    (
      route: AppRoutes.report,
      icon: Icons.report_outlined,
      selectedIcon: Icons.report_rounded,
      label: 'Report',
    ),
    (
      route: AppRoutes.cases,
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder_rounded,
      label: 'Cases',
    ),
    (
      route: AppRoutes.profile,
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  int get _selectedIndex {
    for (var i = 0; i < _destinations.length; i++) {
      if (currentPath.startsWith(_destinations[i].route)) return i;
    }
    return 0;
  }

  void _onSelect(BuildContext context, int index) {
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    final selectedIndex = _selectedIndex;

    final fab = FloatingActionButton.extended(
      heroTag: 'ask-rakshak-fab',
      onPressed: () => context.push(AppRoutes.assistant),
      icon: const RakshakLogo(size: 20, variant: RakshakLogoVariant.compact),
      label: const Text('Ask Rakshak'),
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => _onSelect(context, i),
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: RakshakLogo(size: 32),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: fab,
                  ),
                ),
              ),
              destinations: _destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      floatingActionButton: fab,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _onSelect(context, i),
        destinations: _destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
