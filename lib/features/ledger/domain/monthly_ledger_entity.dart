import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyLedgerEntity {
  final String id;
  final int year;
  final int month;
  final double total;
  final Timestamp createdAt;

  MonthlyLedgerEntity({
    required this.id,
    required this.year,
    required this.month,
    required this.total,
    required this.createdAt,
  });

  factory MonthlyLedgerEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MonthlyLedgerEntity(
      id: doc.id,
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      total: (data['total'] ?? 0).toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
