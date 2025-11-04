import 'package:flutter/material.dart';

/// Muestra un BottomSheet con opciones para reportar el estado emocional de la zona corporal.
class EmotionSheet {
  /// @param onSelect: callback con true si el usuario se siente relajado (😌), o false si tenso (😣).
  static void show(BuildContext context, {required Function(bool) onSelect}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9999).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    color: Color(0xFFFF6B6B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Cómo te sientes?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Evalúa esta zona de tu cuerpo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Instrucción
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber[800],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Selecciona cómo se siente esta parte de tu cuerpo en este momento',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Opciones
            Row(
              children: [
                // Opción: Relajado
                Expanded(
                  child: _EmotionOption(
                    emoji: '😌',
                    label: 'Relajado',
                    description: 'Sin tensión\no malestar',
                    color: const Color(0xFFFFAA88),
                    onTap: () {
                      Navigator.pop(context);
                      onSelect(true);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Opción: Tenso
                Expanded(
                  child: _EmotionOption(
                    emoji: '😣',
                    label: 'Tenso',
                    description: 'Con tensión\no malestar',
                    color: const Color(0xFFFF9999),
                    onTap: () {
                      Navigator.pop(context);
                      onSelect(false);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar una opción de emoción
class _EmotionOption extends StatelessWidget {
  final String emoji;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _EmotionOption({
    required this.emoji,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Emoji
            Text(
              emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            // Descripción
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
