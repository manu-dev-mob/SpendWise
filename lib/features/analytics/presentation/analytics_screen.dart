import 'package:expense_web/features/expenses/data/expense_repository.dart';
import 'package:expense_web/features/expenses/domain/expense_entity.dart';
import 'package:expense_web/shared/widgets/web_scaffold.dart';
import 'package:expense_web/shared/widgets/hover_card.dart';
import 'package:expense_web/shared/widgets/category_badge.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ExpenseRepository>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WebScaffold(
      title: 'Analytics',
      body: StreamBuilder<List<ExpensesEntity>>(
        stream: repo.watchExpenses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data!;
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No expenses recorded yet for analytics.', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

          // Calculate category totals
          final byCategory = <String, double>{};
          for (var e in expenses) {
            byCategory[e.categoryId] = (byCategory[e.categoryId] ?? 0) + e.amount;
          }

          // Calculate monthly category totals
          final Map<String, Map<String, double>> monthlyCategoryTotals = {};
          for (final e in expenses) {
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

          final List<Color> palette = [
            const Color(0xFF6366F1), // Indigo
            const Color(0xFF10B981), // Emerald/Green
            const Color(0xFFF59E0B), // Amber/Orange
            const Color(0xFF06B6D4), // Cyan/Teal
            const Color(0xFFEC4899), // Pink
            const Color(0xFF8B5CF6), // Purple
            const Color(0xFFEF4444), // Red
          ];

          final Map<String, Color> categoryColors = {
            for (int i = 0; i < categories.length; i++)
              categories[i]: palette[i % palette.length]
          };

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Summary Dashboard Banner
                HoverCard(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [const Color(0xFF6366F1).withOpacity(0.06), const Color(0xFF6366F1).withOpacity(0.01)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Portfolio Value',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AED ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isLarge = constraints.maxWidth >= 900;
                    return Column(
                      children: [
                        if (isLarge) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: _buildMonthlyChart(months, categories, monthlyCategoryTotals, categoryColors, isDark),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 3,
                                child: _buildCategoryPieChart(byCategory, categoryColors, isDark),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildMonthlyChart(months, categories, monthlyCategoryTotals, categoryColors, isDark),
                          const SizedBox(height: 24),
                          _buildCategoryPieChart(byCategory, categoryColors, isDark),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthlyChart(
      List<String> months,
      List<String> categories,
      Map<String, Map<String, double>> monthlyCategoryTotals,
      Map<String, Color> categoryColors,
      bool isDark,
      ) {
    return HoverCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Spending Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 320,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(monthlyCategoryTotals) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => isDark ? const Color(0xFF1E293B) : Colors.white,
                      tooltipRoundedRadius: 8,
                      tooltipBorder: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final catName = categories[rodIndex];
                        return BarTooltipItem(
                          '$catName\nAED ${rod.toY.toStringAsFixed(2)}',
                          TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double index, meta) {
                          if (index.toInt() >= months.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[index.toInt()],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'AED ${value.toInt()}',
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.4),
                      strokeWidth: 1,
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
                        return BarChartRodData(
                          toY: value,
                          width: 8,
                          gradient: LinearGradient(
                            colors: [
                              categoryColors[category]!,
                              categoryColors[category]!.withOpacity(0.6),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Legends
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: categories.map((category) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: categoryColors[category],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(Map<String, double> byCategory, Map<String, Color> categoryColors, bool isDark) {
    final double totalAmount = byCategory.values.fold(0, (sum, val) => sum + val);

    final pieSections = byCategory.entries.map((entry) {
      final isTouched = byCategory.keys.toList().indexOf(entry.key) == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 90.0 : 80.0;
      final percentage = (entry.value / totalAmount * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: categoryColors[entry.key],
        value: entry.value,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
      );
    }).toList();

    return HoverCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expenses by Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  sections: pieSections,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: byCategory.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: categoryColors[e.key],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CategoryBadge(categoryId: e.key, fontSize: 10),
                        ],
                      ),
                      Text(
                        'AED ${e.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(Map<String, Map<String, double>> monthlyCategoryTotals) {
    double maxVal = 100.0;
    for (final monthData in monthlyCategoryTotals.values) {
      double monthSum = 0;
      for (final value in monthData.values) {
        monthSum += value;
      }
      if (monthSum > maxVal) {
        maxVal = monthSum;
      }
    }
    return maxVal;
  }
}