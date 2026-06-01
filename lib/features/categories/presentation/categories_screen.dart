import 'package:expense_web/shared/widgets/web_scaffold.dart';
import 'package:expense_web/shared/widgets/hover_card.dart';
import 'package:expense_web/shared/widgets/category_badge.dart';
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

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _CategoriesTable(),
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
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Manage Categories',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const _AddCategoryDialog(),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Category'),
        ),
      ],
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _nameController = TextEditingController();
  Color _selectedColor = const Color(0xFF6366F1); // Default to brand primary

  final List<Color> _colorOptions = [
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Orange
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEF4444), // Red
    const Color(0xFF06B6D4), // Cyan
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                prefixIcon: Icon(Icons.label_rounded),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Color Theme',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorOptions.map((color) {
                return _ColorDot(
                  color: color,
                  selected: _selectedColor,
                  onTap: (c) => setState(() => _selectedColor = c),
                );
              }).toList(),
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
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final Color selected;
  final ValueChanged<Color> onTap;

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = color == selected;
    return GestureDetector(
      onTap: () => onTap(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: isSelected ? 8 : 2,
              spreadRadius: isSelected ? 1 : 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 18,
        )
            : null,
      ),
    );
  }
}

class _CategoriesTable extends StatelessWidget {
  const _CategoriesTable();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            _CategoriesTableHeader(),
            const Divider(height: 24, thickness: 1.5),
            Expanded(
              child: ListView(
                children: const [
                  _CategoryRowWidget(name: 'Groceries', color: Color(0xFF10B981)),
                  Divider(height: 12),
                  _CategoryRowWidget(name: 'Bills', color: Color(0xFF8B5CF6)),
                  Divider(height: 12),
                  _CategoryRowWidget(name: 'Entertainment', color: Color(0xFFF59E0B)),
                  Divider(height: 12),
                  _CategoryRowWidget(name: 'Transport', color: Color(0xFF06B6D4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRowWidget extends StatelessWidget {
  final String name;
  final Color color;

  const _CategoryRowWidget({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          // Name / Badge
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerLeft,
              child: CategoryBadge(categoryId: name, fontSize: 13),
            ),
          ),

          // Color Indicator
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Text(
                //   '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}',
                //   style: TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.w500,
                //     color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                //   ),
                // ),
              ],
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
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  child: IconButton(
                    icon: const Icon(Icons.delete_rounded, size: 14, color: Colors.redAccent),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              'Category Name',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13.5),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Color Accent',
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
