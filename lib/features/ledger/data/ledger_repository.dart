import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_web/features/ledger/domain/monthly_ledger_entity.dart';

class LedgerRepository {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference get _ledgerCollection =>
      _firestore.collection('monthly_ledger');

  Future<void> saveMonthlyLedger({
    required int year,
    required int month,
    required double total,
    required int expenseCount,
  }) async {
    const months = [
      '',
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final docId = '${months[month]}${year.toString().substring(2)}';
    await _ledgerCollection.doc(docId).set({
      'year': year,
      'month': month,
      'total': total,
      'expenseCount': expenseCount,
      'createdAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
  Future<bool> ledgerNeedsUpdate({
    required int year,
    required int month,
    required int expenseCount,
}) async {
    const months = [
      '',
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final docId = '${months[month]}${year.toString().substring(2)}';
    final doc = await _ledgerCollection.doc(docId).get();
    if (!doc.exists) {
      return true;
    }
    final data = doc.data() as Map<String, dynamic>;
    final existingCount = data['expenseCount'] ?? 0;
    return existingCount != expenseCount;
  }
  Future<List<MonthlyLedgerEntity>> fetchLedgerByYear(int year)async {
    final snapshot =await _ledgerCollection.where('year', isEqualTo: year).
    orderBy('month',descending: true).get();
    return snapshot.docs.map((doc)=> MonthlyLedgerEntity.fromFirestore(doc)).toList();
  }
}