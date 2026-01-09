import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_view_model.dart';

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    if (vm.dailyTotals.isEmpty) {
      return const Center(child: Text('No expenses this month'));
    }

    final days = vm.dailyTotals.keys.toList()..sort();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          barTouchData: BarTouchData(enabled: true),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true,reservedSize: 40),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups: List.generate(days.length, (index) {
            final day = days[index];
            return BarChartGroupData(
              x: day,
              barRods: [
                BarChartRodData(
                  toY: vm.dailyTotals[day]!,
                  width: 12,
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.blue,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}