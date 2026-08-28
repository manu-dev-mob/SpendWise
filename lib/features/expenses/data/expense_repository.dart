import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_web/features/expenses/domain/expense_import_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/expense_entity.dart';
import '../../ledger/data/ledger_repository.dart';

class ExpenseRepository {
  ExpenseRepository({FirebaseFirestore? firestore, FirebaseAuth? auth,
    LedgerRepository? ledgerRepository})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance, _ledgerRepository =ledgerRepository ?? LedgerRepository();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LedgerRepository _ledgerRepository;

  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _firestore.collection('expenses');

  bool selected = false;

  Stream<List<ExpensesEntity>> watchExpenses({
    int? year,
    int? month,
    String? category,
  }) {
    return _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final expenses = snapshot.docs
          .map((doc) => ExpensesEntity.fromFirestore(doc))
          .toList();

      return expenses.where((e) {
        final matchYear = year == null || e.date.year == year;
        final matchMonth = month == null || e.date.month == month;
        final matchCategory =
            category == null || category == 'All' ||
                e.categoryId == category;
        return matchYear && matchMonth && matchCategory;
      }).toList();
    });
  }

  Future<void> _recalculateMonthlyLedger({
    required int year,
    required int month,
  }) async {
    final snapshot = await _expensesRef.get();

    double total = 0;
    int expenseCount = 0;

    for (final doc in snapshot.docs) {
      final expense = ExpensesEntity.fromFirestore(doc);

      if (expense.date.year == year && expense.date.month == month) {
        total += expense.amount;
        expenseCount++;
      }
    }

    await _ledgerRepository.saveMonthlyLedger(
      year: year,
      month: month,
      total: total,
      expenseCount: expenseCount,
    );
  }

  Future<String> addExpense({
    required double amount,
    required String categoryId,
    required DateTime date,
    String description = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    final now = DateTime.now();

    try {
      await _expensesRef.add({
        'amount': amount,
        'categoryId': categoryId,
        'date': Timestamp.fromDate(date),
        'description': description,
        'createdBy': user.email,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
      await _recalculateMonthlyLedger(
        year: date.year,
        month: date.month,
      );
      return "Expense Added Successfully";
    } catch (e) {
      return "Failed to add expense";
    }
  }

  Future<String> updateExpense(ExpensesEntity expense) async {
    try {
      final existingDoc = await _expensesRef.doc(expense.id).get();

      DateTime? oldDate;

      if (existingDoc.exists) {
        final existingExpense =
        ExpensesEntity.fromFirestore(existingDoc);

        oldDate = existingExpense.date;
      }
      await _expensesRef.doc(expense.id).update({
        'amount': expense.amount,
        'categoryId': expense.categoryId,
        'date': Timestamp.fromDate(expense.date),
        'description': expense.description,
        'createdBy': expense.createdBy,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      if (oldDate != null &&
          (oldDate.year != expense.date.year ||
              oldDate.month != expense.date.month)) {
        await _recalculateMonthlyLedger(
          year: oldDate.year,
          month: oldDate.month,
        );
      }
      await _recalculateMonthlyLedger(
        year: expense.date.year,
        month: expense.date.month,
      );
      return "Expense updated Successfully";
    } catch (e) {
      return "Failed to update expense";
    }
  }

  Future<String> deleteExpense(String expenseId) async {
    try {
      final existingDoc = await _expensesRef.doc(expenseId).get();

      if (!existingDoc.exists) {
        return "Failed to delete expense";
      }

      final expense = ExpensesEntity.fromFirestore(existingDoc);
      await _expensesRef.doc(expenseId).delete();
      await _recalculateMonthlyLedger(
        year: expense.date.year,
        month: expense.date.month,
      );
      return "Expense deleted Successfully";
    } catch (e) {
      return "Failed to delete expense";
    }
  }
  Future<void> importExpenses(List<ExpenseImportItem> items) async {
    final user = _auth.currentUser;
    if(user == null) {
      throw Exception('User not authenticated');
    }
    final batch = _firestore.batch();
    final now = Timestamp.now();
    for(final item in items){
      final doc = _expensesRef.doc();
      batch.set(doc, {
        'amount': item.amount,
        'categoryId': item.categoryId ?? 'Uncategorized',
        'date': Timestamp.fromDate(item.date),
        'description': item.description,
        'createdBy': user.email,
        'createdAt': now,
        'updatedAt': now,
      });
    }
    await batch.commit();
    final affectedMonths = <String>{};

    for (final item in items) {
      affectedMonths.add('${item.date.year}-${item.date.month}');
    }

    for (final key in affectedMonths) {
      final parts = key.split('-');

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      await _recalculateMonthlyLedger(
        year: year,
        month: month,
      );
    }
  }
}
