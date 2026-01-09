import 'package:cloud_firestore/cloud_firestore.dart';

class ExpensesEntity{
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpensesEntity({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
});
  factory ExpensesEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
      ){
    final data = doc.data()!;
    return ExpensesEntity(
      id: doc.id,
      amount: (data['amount']as num).toDouble(),
      categoryId: data['categoryId'],
      date: (data['date'] as Timestamp).toDate(),
      description: data['description']??'',
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'description': description,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}