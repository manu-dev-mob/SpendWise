import 'package:expense_web/features/expenses/data/expense_repository.dart';
import 'package:expense_web/features/expenses/domain/expense_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ExpenseRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: StreamBuilder<List<ExpensesEntity>>(
          stream: repo.watchExpenses(),
          builder: (context, snapshot){
            if(!snapshot.hasData)return const Center(child: CircularProgressIndicator());
            final expenses = snapshot.data!;
            final total = expenses.fold<double>(0, (sum,e) => sum + e.amount);
            final byCategory = <String, double>{};
            for (var e in expenses){
              byCategory[e.categoryId] = (byCategory[e.categoryId]?? 0) + e.amount;  
            }

            final Map<String, Map<String, double>> monthlyCategoryTotals = {};

            for(final e in expenses){
              final monthKey = DateFormat('MMM yyyy').format(e.date);
              monthlyCategoryTotals.putIfAbsent(monthKey, () => {});
              monthlyCategoryTotals[monthKey]![e.categoryId] =
                  (monthlyCategoryTotals[monthKey]![e.categoryId] ?? 0) + e.amount;
            }
            final months = monthlyCategoryTotals.keys.toList()
              ..sort((a, b) => DateFormat('MMM yyyy').parse(a).compareTo(
                DateFormat('MMM yyyy').parse(b),
              ));

            final categories = <String>{
              for (final m in monthlyCategoryTotals.values) ...m.keys
            }.toList();

            // final palette = Colors.primaries;
            final List<Color> palette = [
              const Color(0xFF4F46E5), // Indigo
              const Color(0xFF16A34A), // Green
              const Color(0xFFDC2626), // Red
              const Color(0xFFEA580C), // Orange
              const Color(0xFF0891B2), // Cyan
              const Color(0xFF9333EA), // Purple
              const Color(0xFFCA8A04), // Amber
              const Color(0xFF0F766E), // Teal
            ];
            final Map<String, Color> categoryColors = {
              for (int i = 0; i < categories.length; i++)
                categories[i]: palette[i % palette.length]
            };

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Expenses: AED ${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 24),
                  Text('Expenses by Category:', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  ...byCategory.entries.map(
                        (e) => Text('${e.key}: AED ${e.value.toStringAsFixed(2)}'),
                  ),
                  const SizedBox(height: 32),
                  // Text('Monthly Expenses', style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _ChartCard(
                          title: 'Monthly Expenses',
                          child: SizedBox(
                            height: 320,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: (expenses.isEmpty ? 100 : expenses.map((e) => e.amount).reduce((a, b) =>  a > b ? a : b)) * 1.4,
                                barTouchData: BarTouchData(enabled: true),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double index, meta) {
                                        if (index.toInt() >= months.length) return const SizedBox.shrink();
                                        return Padding(
                                          padding: const EdgeInsets.only(top:8.0),
                                          child: Text(
                                            months[index.toInt()],
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true,reservedSize: 40),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(months.length, (monthIndex) {
                                  final month = months[monthIndex];
                                  final data = monthlyCategoryTotals[month]!;

                                  return BarChartGroupData(
                                    x: monthIndex,
                                    barsSpace: 4,
                                    barRods: List.generate(categories.length, (catIndex) {
                                      final category = categories[catIndex];
                                      final value = data[category] ?? 0;
                                      return BarChartRodData(toY: value,
                                        width: 10,
                                        color: categoryColors[category],
                                        borderRadius: BorderRadius.circular(3),
                                      );
                                    })
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: categories.map((category){
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children:[
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: categoryColors[category],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                ),
                          const SizedBox(width: 6),
                          Text(
                            category,
                            style: const TextStyle(fontSize: 12),
                              )
                            ]
                          );
                        }).toList()
                      ),

                      const SizedBox(height: 24),
                      Expanded(
                        flex: 1,
                        child: _ChartCard(
                          title: 'By Category',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: byCategory.entries.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Text('${e.key}: AED ${e.value.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14),
                                  )
                                )
                            ).toList(),
                          ),
                        )
                      )
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}