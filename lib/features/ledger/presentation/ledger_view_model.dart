import 'package:expense_web/features/ledger/data/ledger_repository.dart';
import 'package:expense_web/features/ledger/domain/monthly_ledger_entity.dart';
import 'package:flutter/material.dart';

class LedgerViewModel extends ChangeNotifier{
  final LedgerRepository _repository =LedgerRepository();
  int selectedYear =DateTime.now().year;
  bool loading = false;
  List<MonthlyLedgerEntity> ledgerList = [];

  Future<void> loadLedger() async {
    loading = true;
    notifyListeners();
    ledgerList =await _repository.fetchLedgerByYear(selectedYear);
    loading = false;
    notifyListeners();
  }
  void changeYear(int year){
    selectedYear = year;
    loadLedger();
  }
}