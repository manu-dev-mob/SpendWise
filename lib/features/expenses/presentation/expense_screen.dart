import 'package:expense_web/features/expenses/domain/expense_entity.dart';
import 'package:expense_web/shared/widgets/web_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/expense_repository.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      title: 'Expenses',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final double contentWidth = maxWidth >= 1400
              ? 1200.0
              : maxWidth >= 1100
              ? maxWidth * 0.85
              : maxWidth;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Header(),
                  SizedBox(height: 24),
                  Expanded(child: _ExpensesTable()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'All Expenses',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        ElevatedButton.icon(
          onPressed: () {
            showAddExpenseDialog(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
        ),
      ],
    );
  }
}

class _ExpensesTable extends StatelessWidget {
  const _ExpensesTable();

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ExpenseRepository>();
    return StreamBuilder<List<ExpensesEntity>>(
      stream: repo.watchExpenses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final expenses = snapshot.data ?? [];
        if (expenses.isEmpty) {
          return const Center(child: Text('No expenses yet'));
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _ExpensesTableHeader(),
              ),
              const Divider(height: 1),
              Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 0, // hide header
                          dataRowHeight: 52,
                          columns: const [
                            DataColumn(label: SizedBox()),
                            DataColumn(label: SizedBox()),
                            DataColumn(label: SizedBox()),
                            DataColumn(label: SizedBox()),
                            DataColumn(label: SizedBox()),
                          ],
                          rows: expenses
                              .map((e) => _ExpenseRow.fromEntity(e, context))
                              .toList(),
                        ))
                  )
              )
            ],
          )
        );
      },
    );
  }
}

class _ExpenseRow extends DataRow {
  _ExpenseRow.fromEntity(ExpensesEntity expense, BuildContext context)
    : super(
        cells: [
          DataCell(
            Text(expense.description.isEmpty ? 'Expense' : expense.description),
          ),
          DataCell(Text(expense.categoryId)),
          DataCell(Text(DateFormat('dd/MM/yyyy').format(expense.date))),
          DataCell(
            Text(
              expense.amount.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () {
                    showAddExpenseDialog(context, expense: expense);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () async {
                    final repo = context.read<ExpenseRepository>();
                    await repo.deleteExpense(expense.id);
                  },
                ),
              ],
            ),
          ),
        ],
      );
}

class _ExpensesTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowHeight: 48,
      dataRowHeight: 0, // 👈 important: no rows
      columns: const [
        DataColumn(label: SizedBox(width: 220,child:Text('Description'))),
        DataColumn(label: SizedBox(width: 140,child:Text('Category'))),
        DataColumn(label: SizedBox(width: 120,child:Text('Date'))),
        DataColumn(label: SizedBox(width: 120,child:Text('Amount'))),
        DataColumn(label: SizedBox(width: 120,child:Text('Actions'))),
      ],
      rows: const [],
    );
  }
}

Future<void> showAddExpenseDialog(BuildContext context, {ExpensesEntity? expense}) async {
  final formKey = GlobalKey<FormState>();
  String? title = expense?.description;
  double? amount = expense?.amount;
  String? category = expense?.categoryId;
  DateTime? date = expense?.date ?? DateTime.now();
  final TextEditingController dateController = TextEditingController(
    text: expense != null ? DateFormat('dd/MM/yyyy').format(expense.date) : '',
  );

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Expense'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter title' : null,
                  onSaved: (val) => title = val,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val == null || double.tryParse(val) == null
                      ? 'Enter valid amount'
                      : null,
                  onSaved: (val) => amount = double.tryParse(val!),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Category'),
                  items: ['Groceries', 'Bills', 'Entertainment', 'Transport']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => category = val,
                  validator: (val) => val == null ? 'Select category' : null,
                ),
                SizedBox.fromSize(size: Size.fromHeight(20)),
                // InputDatePickerFormField(
                //   firstDate: DateTime(2020),
                //   lastDate: DateTime(2100),
                //   initialDate: date!,
                //   onDateSaved: (val) => date = val,
                // ),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Date'),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      dateController.text = DateFormat(
                        'dd/MM/yyyy',
                      ).format(picked);
                      date = picked;
                    }
                  },
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Pick a date' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final expenseRepo = context.read<ExpenseRepository>();
                try {
                  if(expense == null) {
                    await expenseRepo.addExpense(
                      amount: amount!,
                      date: date!,
                      categoryId: category!,
                      description: title!,
                    );
                  }else{
                    final updated =ExpensesEntity(
                        id: expense.id,
                        amount: amount!,
                        categoryId: category!,
                        date: date!,
                        description: title!,
                        createdBy: expense.createdBy,
                        createdAt: expense.createdAt,
                        updatedAt: DateTime.now());
                    await expenseRepo.updateExpense(updated);
                  }
                  Navigator.pop(context);
                } catch (e) {
                  print('failed to add expense: ${e.toString()}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('failed to add expense: ${e.toString()}')),
                  );
                }
                print('Expense Added: $title, $amount, $category, $date');
              }
            },
            child: Text(expense == null ? 'Add' : 'Update'),
          ),
        ],
      );
    },
  );
}
