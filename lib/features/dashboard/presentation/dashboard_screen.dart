import 'package:expense_web/shared/widgets/web_scaffold.dart';
import 'package:expense_web/shared/widgets/hover_card.dart';
import 'package:expense_web/shared/widgets/category_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_charts_section.dart';
import 'dashboard_view_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WebScaffold(
      title: 'Dashboard',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back !!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is your financial status overview.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            _SummaryCards(vm: vm),
            const SizedBox(height: 24),

            // Charts Card Wrap
            HoverCard(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: const DashboardChartsSection(),
              ),
            ),
            const SizedBox(height: 24),

            const _SectionTitle(title: 'Recent Expenses'),
            const SizedBox(height: 16),

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
    // Generate beautiful responsive summary cards
    final double width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width >= 1200 ? 4 : (width >= 650 ? 2 : 1);

    final cards = [
      _SummaryCard(
        title: 'Total Spent',
        value: 'AED ${vm.overallTotal.toStringAsFixed(2)}',
        icon: Icons.payments_rounded,
        gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)], // Indigo
      ),
      _SummaryCard(
        title: 'This Month',
        value: 'AED ${vm.monthlyTotal.toStringAsFixed(2)}',
        icon: Icons.calendar_month_rounded,
        gradientColors: const [Color(0xFF14B8A6), Color(0xFF0D9488)], // Teal
      ),
      _SummaryCard(
        title: 'Categories',
        value: vm.categoriesCount.toString(),
        icon: Icons.category_rounded,
        gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
      ),
      _SummaryCard(
        title: 'Expenses Count',
        value: vm.recentExpenses.length.toString(),
        icon: Icons.receipt_long_rounded,
        gradientColors: const [Color(0xFFEC4899), Color(0xFFBE185D)], // Magenta
      ),
    ];

    if (crossAxisCount == 4) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: c,
        ))).toList(),
      );
    } else if (crossAxisCount == 2) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: cards[0])),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: cards[2])),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: c,
        )).toList(),
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withOpacity(0.18),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
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
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    );
  }
}

class _RecentExpensesTable extends StatelessWidget {
  final DashboardViewModel vm;
  const _RecentExpensesTable({required this.vm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (vm.recentExpenses.isEmpty) {
      return HoverCard(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: const Center(
            child: Text('No expenses recorded for this month.', style: TextStyle(fontSize: 14)),
          ),
        ),
      );
    }

    return HoverCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width >= 1000 ? 320 : 64),
            ),
            child: DataTable(
              headingRowHeight: 48,
              horizontalMargin: 8,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: vm.recentExpenses.map((e) {
                return DataRow(
                  cells: [
                    DataCell(Text(
                      e.description.isEmpty ? 'Expense' : e.description,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    )),
                    DataCell(CategoryBadge(categoryId: e.categoryId, fontSize: 10.5)),
                    DataCell(Text(
                      '${e.date.day.toString().padLeft(2, '0')}/${e.date.month.toString().padLeft(2, '0')}/${e.date.year}',
                      style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade600, fontSize: 13),
                    )),
                    DataCell(Text(
                      'AED ${e.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.redAccent),
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
