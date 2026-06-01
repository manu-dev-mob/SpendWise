import 'package:expense_web/core/constants/app_constants.dart';
import 'package:expense_web/features/expenses/domain/expense_entity.dart';
import 'package:expense_web/shared/widgets/web_scaffold.dart';
import 'package:expense_web/shared/widgets/hover_card.dart';
import 'package:expense_web/shared/widgets/category_badge.dart';
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
              ? maxWidth * 0.88
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
                    onCategoryChanged: (v) => setState(() => selectedCategory = v!),
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
    'January', 'February', 'March', 'April', 'May',
    'June', 'July', 'August', 'September', 'October',
    'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'All Expenses',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),

        // Filter Controls Wrap
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year filter
            _buildDropdownWrapper(
              context: context,
              child: DropdownButton<int?>(
                value: selectedYear,
                hint: const Text('Year', style: TextStyle(fontSize: 13)),
                underline: const SizedBox(),
                dropdownColor: Theme.of(context).cardColor,
                items: [2025, 2026, 2027, 2028]
                    .map((y) => DropdownMenuItem<int?>(
                  value: y,
                  child: Text('$y', style: const TextStyle(fontSize: 13.5)),
                ))
                    .toList(),
                onChanged: onYearChanged,
              ),
            ),
            const SizedBox(width: 12),

            // Month filter
            _buildDropdownWrapper(
              context: context,
              child: DropdownButton<int?>(
                value: selectedMonth,
                hint: const Text('Month', style: TextStyle(fontSize: 13)),
                underline: const SizedBox(),
                dropdownColor: Theme.of(context).cardColor,
                items: List.generate(
                  12,
                      (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(months[i], style: const TextStyle(fontSize: 13.5)),
                  ),
                ),
                onChanged: onMonthChanged,
              ),
            ),
            const SizedBox(width: 12),

            // Category filter
            _buildDropdownWrapper(
              context: context,
              child: DropdownButton<String>(
                value: selectedCategory,
                underline: const SizedBox(),
                dropdownColor: Theme.of(context).cardColor,
                items: ["All", "Groceries", "Bills", "Entertainment", "Transport"]
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, style: const TextStyle(fontSize: 13.5)),
                ))
                    .toList(),
                onChanged: onCategoryChanged,
              ),
            ),
          ],
        ),

        // Action Button
        ElevatedButton.icon(
          onPressed: () => showAddExpenseDialog(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Expense'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownWrapper({required BuildContext context, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}

class _ExpensesTable extends StatelessWidget {
  final int? selectedYear;
  final int? selectedMonth;
  final String selectedCategory;

  const _ExpensesTable({
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ExpenseRepository>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          return HoverCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: const Center(
                child: Text('No expenses matched your filter criteria.', style: TextStyle(fontSize: 14.5)),
              ),
            ),
          );
        }

        return HoverCard(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                _ExpensesTableHeader(),
                const Divider(height: 24, thickness: 1.5),
                Expanded(
                  child: ListView.separated(
                    itemCount: expenses.length,
                    separatorBuilder: (context, index) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final item = expenses[index];
                      return _ExpenseRowWidget(expense: item);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExpenseRowWidget extends StatelessWidget {
  final ExpensesEntity expense;
  const _ExpenseRowWidget({required this.expense});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Description
              Expanded(
                flex: 4,
                child: Text(
                  expense.description.isEmpty ? 'Expense' : expense.description,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Category
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CategoryBadge(categoryId: expense.categoryId, fontSize: 10),
                ),
              ),

              // Date
              Expanded(
                flex: 2,
                child: Text(
                  DateFormat('dd/MM/yyyy').format(expense.date),
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),

              // Amount
              Expanded(
                flex: 2,
                child: Text(
                  'AED ${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.redAccent,
                  ),
                ),
              ),

              // Actions
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 14, color: Colors.blue),
                        onPressed: () {
                          showAddExpenseDialog(context, expense: expense);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: IconButton(
                        icon: const Icon(Icons.delete_rounded, size: 14, color: Colors.redAccent),
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
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExpensesTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13.5),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13.5),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Date',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13.5),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Amount',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13.5),
            ),
          ),
          const SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
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
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return AlertDialog(
        title: Text(expense == null ? 'Add New Expense' : 'Edit Expense'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(
                      labelText: 'Title / Description',
                      prefixIcon: Icon(Icons.description_rounded, size: 20),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                    onSaved: (val) => title = val,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: amount?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Amount (AED)',
                      prefixIcon: Icon(Icons.attach_money_rounded, size: 20),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                    val == null || double.tryParse(val) == null ? 'Enter valid amount' : null,
                    onSaved: (val) => amount = double.tryParse(val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_rounded, size: 20),
                    ),
                    items: ['Groceries', 'Bills', 'Entertainment', 'Transport']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => category = val,
                    validator: (val) => val == null ? 'Select category' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: date ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        dateController.text = DateFormat('dd/MM/yyyy').format(picked);
                        date = picked;
                      }
                    },
                    validator: (val) => val == null || val.isEmpty ? 'Pick a date' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                  }
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save expense: ${e.toString()}')),
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
