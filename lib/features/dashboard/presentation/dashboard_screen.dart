import 'package:expense_web/shared/widgets/web_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_charts_section.dart';
import 'dashboard_view_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    return WebScaffold(
      title: 'Dashboard',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryCards(vm: vm,),
            SizedBox(height: 32),
            DashboardChartsSection(),
            SizedBox(height: 32),
            _SectionTitle(title: 'Recent Expenses'),
            SizedBox(height: 16),
            _RecentExpensesTable(vm: vm),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final DashboardViewModel vm;
  const _SummaryCards({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _SummaryCard(
          title: 'Total Spent',
          value: 'AED ${vm.overallTotal.toStringAsFixed(2)}',
          icon: Icons.payments,
        ),
         _SummaryCard(
          title: 'This Month',
          value: 'AED ${vm.monthlyTotal.toStringAsFixed(2)}',
          icon: Icons.calendar_month,
        ),
        _SummaryCard(
          title: 'Categories',
          value: vm.categoriesCount.toString(),
          icon: Icons.category,
        ),
        _SummaryCard(
          title: 'Expenses',
          value: vm.recentExpenses.length.toString(),
          icon: Icons.receipt_long,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}

class _RecentExpensesTable extends StatelessWidget {
  final DashboardViewModel vm;
  const _RecentExpensesTable({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Amount')),
          ],
          rows: vm.recentExpenses.map((e){
            return DataRow(cells: [
              DataCell(Text(e.description)),
              DataCell(Text(e.categoryId)),
              DataCell(Text(
                '${e.date.day}/${e.date.month}/${e.date.year}'
              )),
              DataCell(Text('AED ${e.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ))
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _ExpenseRow extends DataRow {
  _ExpenseRow({
    required String title,
    required String category,
    required String date,
    required String amount,
  }) : super(
         cells: [
           DataCell(Text(title)),
           DataCell(Text(category)),
           DataCell(Text(date)),
           DataCell(Text(amount)),
         ],
       );
}
