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

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:provider/provider.dart';
//
// import 'dashboard_view_model.dart';
//
// class DashboardChartsSection extends StatelessWidget {
//   const DashboardChartsSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<DashboardViewModel>();
//     if(vm.dailyTotals.isEmpty){
//       return const Center(child:Text('No expenses yet'));
//     }
//     final days = vm.dailyTotals.keys.toList()..sort();
//     return Row(
//       children: [
//         Expanded(child: _MonthlySpendingChart()),
//         SizedBox(width: 24),
//         Expanded(child: _CategoryBreakdownChart()),
//       ]
//     );
//   }
// }
// class _MonthlySpendingChart extends StatelessWidget {
//   const _MonthlySpendingChart();
//
//   @override
//   Widget build(BuildContext context) {
//     return _ChartCard(
//       title: 'Monthly Spending',
//       child: LineChart(
//         LineChartData(
//           gridData: FlGridData(show: false),
//           titlesData: FlTitlesData(show: false),
//           borderData: FlBorderData(show: false),
//           lineBarsData: [
//             LineChartBarData(
//                 spots: [
//                   FlSpot(0, 200),
//                   FlSpot(1, 450),
//                   FlSpot(2, 300),
//                   FlSpot(3, 520),
//                   FlSpot(4, 410),
//                   FlSpot(5, 600),
//                 ],
//                 isCurved: true,
//                 barWidth: 3,
//                 dotData: FlDotData(show: false),
//               color: Colors.blue,
//             )
//           ]
//         )
//       ),
//     );
//   }
// }
// class _CategoryBreakdownChart extends StatelessWidget {
//   const _CategoryBreakdownChart();
//
//   @override
//   Widget build(BuildContext context) {
//     return _ChartCard(
//       title: 'By Category',
//       child: PieChart(
//         PieChartData(
//           sectionsSpace: 4,
//           centerSpaceRadius: 40,
//           sections:  [
//             PieChartSectionData(
//               value: 40,
//               title: 'Food',
//               color: Colors.blue,
//             ),
//             PieChartSectionData(
//               value: 25,
//               title: 'Transport',
//               color: Colors.green,
//             ),
//             PieChartSectionData(
//               value: 20,
//               title: 'Bills',
//               color: Colors.orange,
//             ),
//             PieChartSectionData(
//               value: 15,
//               title: 'Other',
//               color: Colors.purple,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// class _ChartCard extends StatelessWidget {
//   final String title;
//   final Widget child;
//
//   const _ChartCard({
//     required this.title,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 320,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Expanded(child: child),
//         ],
//       ),
//     );
//   }
// }