import 'package:expense_web/features/ledger/presentation/ledger_view_model.dart';
import 'package:expense_web/shared/widgets/web_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final List<int> years = [2025, 2026, 2027, 2028];
  String monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LedgerViewModel>().loadLedger();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      title: "Ledger",
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final double contentWidth = maxWidth > 1200
              ? 1100
              : maxWidth > 900
              ? 900
              : maxWidth;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Consumer<LedgerViewModel>(
                builder: (context, vm, _) {
                  return Column(
                    children: [
                      DropdownButton(
                        value: vm.selectedYear,
                        items: years.map((year) {
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            print(vm);
                            vm.changeYear(value);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: vm.loading
                            ? const Center(child: CircularProgressIndicator())
                            : vm.ledgerList.isEmpty
                            ? const Center(child: Text('No Ledger Data'))
                            : ListView.builder(
                                itemCount: vm.ledgerList.length,
                                itemBuilder: (context, index) {
                                  final item = vm.ledgerList[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text(monthName(item.month)),
                                      subtitle: Text(item.year.toString()),
                                      trailing: Text(
                                        'AED ${item.total.toStringAsFixed(2)}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
