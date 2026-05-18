import 'package:expense_web/features/analytics/presentation/analytics_screen.dart';
import 'package:expense_web/features/dashboard/presentation/dashboard_screen.dart';
import 'package:expense_web/features/ledger/presentation/ledger_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/expenses/presentation/expense_screen.dart';
import 'auth_gate.dart';

final GoRouter appRouter = GoRouter(
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoginRoute = state.uri.toString() == '/login';
    if (user == null && !isLoginRoute) {
      return '/login';
    }
    if (user != null && isLoginRoute) {
      return '/dashboard';
    }
    return null;
  },
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
    GoRoute(path: '/login', builder: (context, state) => const AuthScreen(),

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
    GoRoute(
      path: '/ledger',
      name: 'ledger',
      pageBuilder: (context, state) =>
      const NoTransitionPage(child: LedgerScreen()),
    ),
  ],
);
