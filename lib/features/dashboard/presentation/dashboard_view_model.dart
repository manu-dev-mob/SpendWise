import 'dart:async';
import 'dart:core';
import 'package:expense_web/features/ledger/data/ledger_repository.dart';
import 'package:flutter/material.dart';
import '../../expenses/data/expense_repository.dart';
import '../../expenses/domain/expense_entity.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this.repo) {
    _subscribe();
  }
  final ExpenseRepository repo;
  StreamSubscription<List<ExpensesEntity>>? _sub;
  List<ExpensesEntity> _allExpenses = [];
  final LedgerRepository _ledgerRepository = LedgerRepository();

  List<ExpensesEntity> get monthlyExpenses => _monthlyExpenses;
  double get overallTotal => _overallTotal;
  double get monthlyTotal => _monthlyTotal;
  int get categoriesCount => _categoriesCount;
  int get billsCount => _billsCount;
  Map<int, double> get dailyTotals => _dailyTotals;
  Map<String, double> get categoryTotals => _categoryTotals;
  List<ExpensesEntity> get recentExpenses => _recentExpenses;

  List<ExpensesEntity> _monthlyExpenses = [];
  double _overallTotal = 0;
  double _monthlyTotal = 0;
  int _categoriesCount = 0;
  int _billsCount = 0;
  Map<int, double> _dailyTotals = {};
  Map<String, double> _categoryTotals = {};
  List<ExpensesEntity> _recentExpenses = [];

  void _subscribe() {
    _savePreviousMonthLedger();
    // final now =DateTime.now();
    _sub = repo.watchExpenses().listen((expenses) {
      _allExpenses = expenses;
      _recalculate();
    });
  }

  void _recalculate() {
    final now = DateTime.now();
    _monthlyExpenses = _allExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
    _overallTotal = _monthlyExpenses.fold(0, (sum, e) => sum + e.amount);
    _monthlyTotal = _monthlyExpenses.fold(0, (sum, e) => sum + e.amount);
    _billsCount = _monthlyExpenses.length;
    _categoriesCount = _monthlyExpenses.map((e) => e.categoryId).toSet().length;
    _dailyTotals = {};
    _categoryTotals = {};
    for (final e in _monthlyExpenses) {
      final day = e.date.day;
      _dailyTotals[day] = (_dailyTotals[day] ?? 0) + e.amount;
      _categoryTotals[e.categoryId] =
          (_categoryTotals[e.categoryId] ?? 0) + e.amount;
    }
    _recentExpenses = _monthlyExpenses.take(5).toList();
    _savePreviousMonthLedger();
    notifyListeners();
  }

  Future<void> _savePreviousMonthLedger() async {
    final now = DateTime.now();
    int previousMonth = now.month - 1;
    int year = now.year;
    if (previousMonth == 0) {
      previousMonth = 12;
      year--;
    }
    final previousMonthExpenses = _allExpenses.where((e) {
      return e.date.year == year && e.date.month == previousMonth;
    }).toList();
    final previousMonthTotal = previousMonthExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    if (previousMonthTotal <= 0) return;
    await _ledgerRepository.saveMonthlyLedger(
      year: year,
      month: previousMonth,
      total: previousMonthTotal,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
