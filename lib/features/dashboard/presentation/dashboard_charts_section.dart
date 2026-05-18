import 'package:flutter/material.dart';
import 'dashboard_monthly_bar_chart.dart';

class DashboardChartsSection extends StatelessWidget {
  const DashboardChartsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Monthly Spending',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16),
        MonthlyBarChart(),
      ],
    );
  }
}