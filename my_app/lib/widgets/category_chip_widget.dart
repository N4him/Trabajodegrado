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
    const iconColor = const Color.fromARGB(255, 160, 93, 85);
    
    final categories = [
      {'name': 'HOLA', 'icon': Icons.menu_book},
      {'name': 'reading', 'icon': Icons.favorite},
      {'name': 'space', 'icon': Icons.language},
      {'name': 'more', 'icon': Icons.apps},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              final isSelected = selectedCategory == category['name'];
              return GestureDetector(
                onTap: () => onCategoryChanged(category['name'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? iconColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? iconColor.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 15 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color: isSelected ? Colors.white : iconColor,
                        size: 28,
                      ),
                      const SizedBox(height: 0),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
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