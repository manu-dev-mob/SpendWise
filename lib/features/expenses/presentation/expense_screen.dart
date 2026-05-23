import 'package:expense_web/core/constants/app_constants.dart';
import 'package:expense_web/features/expenses/domain/expense_entity.dart';
import 'package:expense_web/shared/widgets/web_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/expense_repository.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  int? selectedYear;
  int? selectedMonth;
  String selectedCategory = 'All';
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
                children: [
                  _Header(
                    selectedYear: selectedYear,
                    selectedMonth: selectedMonth,
                    selectedCategory: selectedCategory,
                    onYearChanged: (v) => setState(() => selectedYear = v),
                    onMonthChanged: (v) => setState(() => selectedMonth = v),
                    onCategoryChanged: (v) =>
                        setState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _ExpensesTable(
                      selectedYear: selectedYear,
                      selectedMonth: selectedMonth,
                      selectedCategory: selectedCategory,
                    ),
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

class _Header extends StatelessWidget {
  final int? selectedYear;
  final int? selectedMonth;
  final String selectedCategory;
  final Function(int?) onYearChanged;
  final Function(int?) onMonthChanged;
  final Function(String?) onCategoryChanged;
  const _Header({
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedCategory,
    required this.onYearChanged,
    required this.onMonthChanged,
    required this.onCategoryChanged,
  });
  static const months = [
    'January',
    'February',
    'March', 'April', 'May',
    'June', 'July', 'August',
    'September', 'October', 'November',
    'December',];
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'All Expenses',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        DropdownButton<int?>(
          value: selectedYear,
          hint: const Text('year'),
          items: [2025, 2026, 2027]
              .map((y) => DropdownMenuItem<int?>(value: y, child: Text('$y')))
              .toList(),
          onChanged: onYearChanged,
        ),
        DropdownButton<int?>(
          value: selectedMonth,
          hint: const Text("Month"),
          items: List.generate(
            12,
                (i) => DropdownMenuItem(
              value: i + 1,
              child: Text(months[i]),
            ),
          ),

          // items: List.generate(
          //   12,
          //   (i) => i + 1,
          // ).map((m) => DropdownMenuItem(value: m, child: Text("$m"))).toList(),

          onChanged: onMonthChanged,
        ),
        DropdownButton<String>(
          value: selectedCategory,
          items: [
            "All",
            "Groceries",
            "Bills",
            "Entertainment",
          ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: onCategoryChanged,
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
  final int? selectedYear;
  final int? selectedMonth;
  final String selectedCategory;
  const _ExpensesTable({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedCategory,
  });
  @override
  Widget build(BuildContext context) {
    final repo = context.read<ExpenseRepository>();
    return StreamBuilder<List<ExpensesEntity>>(
      stream: repo.watchExpenses(
        year: selectedYear,
        month: selectedMonth,
        category: selectedCategory,
      ),
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
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                    final message = await repo.deleteExpense(expense.id);
                    if (!context.mounted) return;
                    AppConstants.showSnackBar(
                      context: context,
                      message: message,
                    );
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
        DataColumn(label: SizedBox(width: 220, child: Text('Description'))),
        DataColumn(label: SizedBox(width: 140, child: Text('Category'))),
        DataColumn(label: SizedBox(width: 120, child: Text('Date'))),
        DataColumn(label: SizedBox(width: 120, child: Text('Amount'))),
        DataColumn(label: SizedBox(width: 120, child: Text('Actions'))),
      ],
      rows: const [],
    );
  }
}

Future<void> showAddExpenseDialog(
  BuildContext context, {
  ExpensesEntity? expense,
}) async {
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
                  if (expense == null) {
                    final message = await expenseRepo.addExpense(
                      amount: amount!,
                      date: date!,
                      categoryId: category!,
                      description: title!,
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  } else {
                    final updated = ExpensesEntity(
                      id: expense.id,
                      amount: amount!,
                      categoryId: category!,
                      date: date!,
                      description: title!,
                      createdBy: expense.createdBy,
                      createdAt: expense.createdAt,
                      updatedAt: DateTime.now(),
                    );
                    final message = await expenseRepo.updateExpense(updated);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('failed to add expense: ${e.toString()}'),
                    ),
                  );
                }
              }
            },
            child: Text(expense == null ? 'Add' : 'Update'),
          ),
        ],
      );
    },
  );
}
