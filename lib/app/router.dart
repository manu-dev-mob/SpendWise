import 'package:expense_web/features/analytics/presentation/analytics_screen.dart';
import 'package:expense_web/features/dashboard/presentation/dashboard_screen.dart';
import 'package:go_router/go_router.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/expenses/presentation/expense_screen.dart';
import 'auth_gate.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: DashboardScreen()),
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      pageBuilder: (context, state) =>
      const NoTransitionPage(child: CategoriesScreen()),
    ),
    GoRoute(
      path: '/expenses',
      name: 'expenses',
      pageBuilder: (context, state) =>
      const NoTransitionPage(child: ExpensesScreen()),
    ),
    GoRoute(
      path: '/analytics',
      name: 'analytics',
      pageBuilder: (context, state) =>
      const NoTransitionPage(child: AnalyticsScreen()),
    ),
  ],
);
