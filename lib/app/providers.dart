import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_web/features/ledger/presentation/ledger_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import '../features/dashboard/presentation/dashboard_view_model.dart';
import '../features/expenses/data/expense_repository.dart';

final appProviders = [
  ChangeNotifierProvider<ThemeProvider>(
    create: (_) => ThemeProvider(),
  ),
  Provider<ExpenseRepository>(
    create: (_) => ExpenseRepository(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
  ),
  ChangeNotifierProvider<DashboardViewModel>(
    create: (context) =>
        DashboardViewModel(context.read<ExpenseRepository>()),
  ),
  ChangeNotifierProvider(create: (_) => LedgerViewModel())
];
