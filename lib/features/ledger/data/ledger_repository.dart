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
  }) async {
    final existing = await _ledgerCollection
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .limit(1).get();
    if(existing.docs.isNotEmpty){
      return;
    }
    await _ledgerCollection.add({
      'year': year,
      'month': month,
      'total': total,
      'createdAt': Timestamp.now(),
    });
  }
  Future<List<MonthlyLedgerEntity>> fetchLedgerByYear(int year)async {
    final snapshot =await _ledgerCollection.where('year', isEqualTo: year).
    orderBy('month',descending: true).get();
    return snapshot.docs.map((doc)=> MonthlyLedgerEntity.fromFirestore(doc)).toList();
  }
}