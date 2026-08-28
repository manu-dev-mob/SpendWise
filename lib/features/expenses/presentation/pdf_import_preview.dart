import 'package:bank_statement_parser/bank_statement_parser.dart';
import 'package:expense_web/features/expenses/presentation/transaction_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/expense_import_item.dart';

class PdfImportPreviewScreen extends StatefulWidget {
  final List<ParsedTransaction> transactions;
  const PdfImportPreviewScreen({super.key, required this.transactions});

  @override
  State<PdfImportPreviewScreen> createState() => _PdfImportPreviewScreenState();
}

class _PdfImportPreviewScreenState extends State<PdfImportPreviewScreen> {
  late List<bool> _selected;
  @override
  void initState() {
    super.initState();
    _selected = List.generate(widget.transactions.length, (_) => true);
  }

  void _toggleAll(bool value) {
    setState(() {
      for (int i = 0; i < _selected.length; i++) {
        _selected[i] = value;
      }
    });
  }

  void _continueToEdit() {
    final selectedTransactions = <ParsedTransaction>[];
    for (int i = 0; i < widget.transactions.length; i++) {
      if (_selected[i]) {
        selectedTransactions.add(widget.transactions[i]);
      }
    }
    if (selectedTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select atleast one transaction')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionEditScreen(
            transactions: selectedTransactions
            .map(ExpenseImportItem.fromParsedTransaction).
            toList()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = _selected.every((element) => element);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Imported Transactions'),
        actions: [
          TextButton(
            onPressed: _continueToEdit,
            child: const Text(
              'Continue..',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Checkbox(
                  value: allSelected,
                  onChanged: (value) {
                    _toggleAll(value ?? false);
                  },
                ),
                const Text('Select All'),
                const Spacer(),
                Text('${widget.transactions.length} : transactions'),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: widget.transactions.length,
              itemBuilder: (context, index) {
                final transactions = widget.transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: _selected[index],
                      onChanged: (value) {
                        setState(() {
                          _selected[index] = value ?? false;
                        });
                      },
                    ),
                    title: Text(
                      transactions.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      DateFormat("dd/MM/yyyy").format(transactions.date),
                    ),
                    trailing: Text(
                      "Aed -> ${transactions.debit.toStringAsFixed(2) ?? "0.00"}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
