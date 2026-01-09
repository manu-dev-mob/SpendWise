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

  Stream<List<ExpensesEntity>> watchExpenses() {
    return _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpensesEntity.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addExpense({
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

    await _expensesRef.add({
      'amount': amount,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'description': description,
      'createdBy': user.email,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  Future<void> updateExpense(ExpensesEntity expense) async {
    await _expensesRef.doc(expense.id).update({
      'amount': expense.amount,
      'categoryId': expense.categoryId,
      'date': Timestamp.fromDate(expense.date),
      'description': expense.description,
      'createdBy': expense.createdBy,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expensesRef.doc(expenseId).delete();
  }
}
