import 'package:expense_web/shared/widgets/web_scaffold.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebScaffold(
      title: "Categories",
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final double contentWidth = maxWidth > 1200
              ? 1100
              : maxWidth > 900
              ? 900
              : maxWidth;
          // print('screensize : $maxWidth $contentWidth');
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(),
                  const SizedBox(height: 24),
                  Expanded(child: _CategoriesTable()),
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
  const _Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Manage Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const _AddCategoryDialog(),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Category'),
        ),
      ],
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog({super.key});

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Category'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _ColorDot(
                  color: Colors.green,
                  selected: _selectedColor,
                  onTap: _select,
                ),
                _ColorDot(
                  color: Colors.orange,
                  selected: _selectedColor,
                  onTap: _select,
                ),
                _ColorDot(
                  color: Colors.blue,
                  selected: _selectedColor,
                  onTap: _select,
                ),
                _ColorDot(
                  color: Colors.purple,
                  selected: _selectedColor,
                  onTap: _select,
                ),
                _ColorDot(
                  color: Colors.red,
                  selected: _selectedColor,
                  onTap: _select,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _select(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final Color selected;
  final ValueChanged<Color> onTap;

  const _ColorDot({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = color == selected;
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.black,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _CategoriesTable extends StatelessWidget {
  const _CategoriesTable({super.key});

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
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Color')),
            DataColumn(label: Text('Actions')),
          ],
          rows: [
            _CategoryRow(name: 'Groceries', color: Colors.green),
            _CategoryRow(name: 'Bills', color: Colors.yellow.shade700),
            _CategoryRow(name: 'Entertainment', color: Colors.blue),
            _CategoryRow(name: 'Transport', color: Colors.purpleAccent),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends DataRow {
  _CategoryRow({required String name, required Color color})
    : super(
        cells: [
          DataCell(Text(name)),
          DataCell(
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          DataCell(
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 18),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete, size: 18),
                ),
              ],
            ),
          ),
        ],
      );
}
