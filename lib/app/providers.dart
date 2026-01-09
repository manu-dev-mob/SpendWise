import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import '../features/dashboard/presentation/dashboard_view_model.dart';
import '../features/expenses/data/expense_repository.dart';

final appProviders = [
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
];
