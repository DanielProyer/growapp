import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase/supabase_client.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/strains/presentation/pages/strains_page.dart';
import '../features/strains/presentation/pages/strain_detail_page.dart';
import '../features/strains/presentation/pages/strain_form_page.dart';
import '../features/grow_tents/presentation/pages/grow_tents_page.dart';
import '../features/grows/presentation/pages/grows_page.dart';
import '../features/daily_logs/presentation/pages/daily_logs_page.dart';
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
            builder: (context, state) => const GrowTentsPage(),
          ),
          GoRoute(
            path: '/grows',
            name: RouteNames.grows,
            builder: (context, state) => const GrowsPage(),
          ),
          GoRoute(
            path: '/logs',
            name: RouteNames.dailyLogs,
            builder: (context, state) => const DailyLogsPage(),
          ),
        ],
      ),
    ],
  );
});
