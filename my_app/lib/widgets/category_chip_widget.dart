import 'package:flutter/material.dart';

class CategoryChipWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoryChipWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Todos', 'icon': Icons.apps, 'color': const Color(0xFF5E35B1)},
      {'name': 'Ficción', 'icon': Icons.auto_stories, 'color': const Color(0xFFD32F2F)},
      {'name': 'Historia', 'icon': Icons.history_edu, 'color': const Color(0xFF7B1FA2)},
      {'name': 'Ciencia', 'icon': Icons.science, 'color': const Color(0xFF00796B)},
      {'name': 'Arte', 'icon': Icons.palette, 'color': const Color(0xFFF57C00)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = selectedCategory == category['name'];
              return GestureDetector(
                onTap: () => onCategoryChanged(category['name'] as String),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? category['color'] as Color : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? (category['color'] as Color).withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 15 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color: isSelected ? Colors.white : category['color'] as Color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF2C1810),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}