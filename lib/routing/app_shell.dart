import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/constants/app_constants.dart';

/// Responsive App Shell
/// - Mobile: Bottom Navigation Bar
/// - Tablet: Navigation Rail
/// - Desktop: Navigation Drawer (Sidebar)
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _destinations = [
    _NavDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      path: '/dashboard',
    ),
    _NavDestination(
      icon: Icons.local_florist_outlined,
      selectedIcon: Icons.local_florist,
      label: 'Sorten',
      path: '/sorten',
    ),
    _NavDestination(
      icon: Icons.house_outlined,
      selectedIcon: Icons.house,
      label: 'Zelte',
      path: '/zelte',
    ),
    _NavDestination(
      icon: Icons.eco_outlined,
      selectedIcon: Icons.eco,
      label: 'Grows',
      path: '/grows',
    ),
    _NavDestination(
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note,
      label: 'Logs',
      path: '/logs',
    ),
    _NavDestination(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Inventar',
      path: '/inventar',
    ),
    _NavDestination(
      icon: Icons.bug_report_outlined,
      selectedIcon: Icons.bug_report,
      label: 'Schädlinge',
      path: '/schaedlinge',
    ),
    _NavDestination(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      label: 'Kalender',
      path: '/kalender',
    ),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) return i;
    }
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    context.go(_destinations[index].path);
  }

  static Future<void> _abmelden(BuildContext context) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abmelden'),
        content: const Text('Möchtest du dich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );
    if (bestaetigt == true) {
      await Supabase.instance.client.auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Desktop: Sidebar
    if (width >= AppConstants.breakpointMedium) {
      return _DesktopLayout(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (i) => _onDestinationSelected(context, i),
        child: child,
      );
    }

    // Tablet: Navigation Rail
    if (width >= AppConstants.breakpointCompact) {
      return _TabletLayout(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (i) => _onDestinationSelected(context, i),
        child: child,
      );
    }

    // Mobile: Bottom Navigation
    return _MobileLayout(
      selectedIndex: _selectedIndex(context),
      onDestinationSelected: (i) => _onDestinationSelected(context, i),
      child: child,
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const _MobileLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index < AppShell._destinations.length) {
            onDestinationSelected(index);
          } else {
            AppShell._abmelden(context);
          }
        },
        destinations: [
          ...AppShell._destinations.map((d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              )),
          const NavigationDestination(
            icon: Icon(Icons.logout),
            label: 'Abmelden',
          ),
        ],
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const _TabletLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Abmelden',
                    onPressed: () => AppShell._abmelden(context),
                  ),
                ),
              ),
            ),
            destinations: AppShell._destinations
                .map((d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ))
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const _DesktopLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: Column(
              children: [
                // App Header
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: theme.colorScheme.primary,
                  child: Row(
                    children: [
                      Icon(
                        Icons.eco,
                        color: theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'GrowApp',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: List.generate(
                      AppShell._destinations.length,
                      (index) {
                        final dest = AppShell._destinations[index];
                        final isSelected = index == selectedIndex;
                        return ListTile(
                          leading: Icon(
                            isSelected ? dest.selectedIcon : dest.icon,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          title: Text(
                            dest.label,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor:
                              theme.colorScheme.primary.withAlpha(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () => onDestinationSelected(index),
                        );
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.logout,
                      color: theme.colorScheme.onSurfaceVariant),
                  title: Text('Abmelden',
                      style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant)),
                  onTap: () => AppShell._abmelden(context),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
  });
}
