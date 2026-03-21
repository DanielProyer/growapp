import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase/supabase_client.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/strains/presentation/pages/strains_page.dart';
import '../features/strains/presentation/pages/strain_detail_page.dart';
import '../features/strains/presentation/pages/strain_form_page.dart';
import '../features/grow_tents/presentation/pages/tents_page.dart';
import '../features/grow_tents/presentation/pages/tent_detail_page.dart';
import '../features/grows/presentation/pages/grows_page.dart';
import '../features/grows/presentation/pages/grow_detail_page.dart';
import '../features/daily_logs/presentation/pages/daily_logs_page.dart';
import '../features/daily_logs/presentation/pages/daily_log_form_page.dart';
import '../features/daily_logs/presentation/providers/tages_logs_provider.dart';
import 'route_names.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      // Auth Routen (ohne Shell)
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),

      // Hauptnavigation (mit Shell)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: RouteNames.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/sorten',
            name: RouteNames.strains,
            builder: (context, state) => const StrainsPage(),
            routes: [
              GoRoute(
                path: 'neu',
                name: RouteNames.strainCreate,
                builder: (context, state) => const StrainFormPage(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.strainDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return StrainDetailPage(strainId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/zelte',
            name: RouteNames.growTents,
            builder: (context, state) => const TentsPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.tentDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TentDetailPage(tentId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/grows',
            name: RouteNames.grows,
            builder: (context, state) => const GrowsPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.growDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return GrowDetailPage(growId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/logs',
            name: RouteNames.dailyLogs,
            builder: (context, state) => const DailyLogsPage(),
            routes: [
              GoRoute(
                path: 'neu',
                name: RouteNames.dailyLogCreate,
                builder: (context, state) {
                  final growId = state.uri.queryParameters['grow'];
                  return DailyLogFormPage(
                      vorausgewaehlterDurchgangId: growId);
                },
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.dailyLogDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _DailyLogDetailLoader(logId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Lädt einen einzelnen Log und zeigt das Formular zum Bearbeiten
class _DailyLogDetailLoader extends ConsumerWidget {
  final String logId;
  const _DailyLogDetailLoader({required this.logId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logAsync = ref.watch(tagesLogProvider(logId));

    return logAsync.when(
      data: (log) {
        if (log == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Log')),
            body: const Center(child: Text('Log nicht gefunden')),
          );
        }
        return DailyLogFormPage(log: log);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Fehler')),
        body: Center(child: Text('Fehler: $error')),
      ),
    );
  }
}
