import 'package:bank_statement_parser/bank_statement_parser.dart';

class ExpenseImportItem {
  DateTime date;
  String description;
  double amount;
  String? categoryId;

  ExpenseImportItem({
    required this.date,
    required this.description,
    required this.amount,
    required this.categoryId,
  });
  factory ExpenseImportItem.fromParsedTransaction(
      ParsedTransaction transaction,
      ){
    return ExpenseImportItem(
        date: transaction.date,
        description: transaction.description,
        amount: transaction.debit ?? 0,
        categoryId: null);
  }
}
