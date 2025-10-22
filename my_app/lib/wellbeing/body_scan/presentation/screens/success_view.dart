import 'package:flutter/material.dart';

/// Vista de éxito después de guardar la sesión
class SuccessView extends StatelessWidget {
  final List<bool> emotions;
  final int rating;
  final int durationSeconds;

  const SuccessView({
    super.key,
    required this.emotions,
    required this.rating,
    required this.durationSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final relaxedCount = emotions.where((e) => e).length;
    final relaxationPercentage = (relaxedCount / emotions.length * 100).toInt();
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono de éxito
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              '¡Sesión Guardada!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Tu progreso ha sido registrado',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Resumen en cards
            _SummaryCard(
              icon: Icons.timer,
              label: 'Duración',
              value: '${minutes}m ${seconds}s',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

            _SummaryCard(
              icon: Icons.spa,
              label: 'Relajación',
              value: '$relaxationPercentage%',
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            _SummaryCard(
              icon: Icons.star,
              label: 'Calificación',
              value: '$rating/5',
              color: Colors.amber,
            ),
            const SizedBox(height: 32),

            // Botones
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Finalizar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
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
