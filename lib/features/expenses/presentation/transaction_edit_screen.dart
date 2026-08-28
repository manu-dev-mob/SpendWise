import 'package:expense_web/features/expenses/data/expense_repository.dart';
import 'package:expense_web/features/expenses/domain/expense_import_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionEditScreen extends StatefulWidget {
  final List<ExpenseImportItem> transactions;
  const TransactionEditScreen({super.key, required this.transactions});
  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  final ExpenseRepository _repository = ExpenseRepository();
  late List<ExpenseImportItem> _transactions;
  final categories = [
    'Groceries',
    'Bills',
    'Entertainment',
    'Transport',
    'Other',
  ];
  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.transactions);
  }

  Future<void> _editDescription(
    BuildContext context,
    ExpenseImportItem item,
  ) async {
    final controller = TextEditingController(text: item.description);
    final value = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Description'),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      setState(() {
        item.description = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Transactions'),
        actions: [
          TextButton(
            onPressed: () async{
              try {
                await _repository.importExpenses(_transactions);
                if(!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Transactions Imported Successfully')));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Import Failed $e')));
                await Future.delayed(const Duration(milliseconds: 500));
                Navigator.of(context).popUntil((route) {
                  return route.settings.name == '/expenses';
                });
              }
            },
            child: const Text('IMPORT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _transactions[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(item.date),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  InkWell(
                    onTap: () => _editDescription(context, item),
                    child: Row(
                      children: [
                        const Icon(Icons.description),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            item.description.isEmpty
                                ? 'No description'
                                : item.description,
                          ),
                        ),
                        const Icon(Icons.edit),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  DropdownButtonFormField<String>(
                    value: item.categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        item.categoryId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
