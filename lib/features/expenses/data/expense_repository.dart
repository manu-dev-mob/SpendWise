import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/expense_entity.dart';

class ExpenseRepository {
  ExpenseRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

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
      return "Expense Added Successfully";
    } catch (e) {
      return "Failed to add expense";
    }
  }

  Future<String> updateExpense(ExpensesEntity expense) async {
    try {
      await _expensesRef.doc(expense.id).update({
        'amount': expense.amount,
        'categoryId': expense.categoryId,
        'date': Timestamp.fromDate(expense.date),
        'description': expense.description,
        'createdBy': expense.createdBy,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return "Expense updated Successfully";
    } catch (e) {
      return "Failed to update expense";
    }
  }

  Future<String> deleteExpense(String expenseId) async {
    try {
      await _expensesRef.doc(expenseId).delete();
      return "Expense deleted Successfully";
    } catch (e) {
      return "Failed to delete expense";
    }
  }
}
