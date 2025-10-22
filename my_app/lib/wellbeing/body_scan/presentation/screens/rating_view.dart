import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/body_scan_bloc.dart';
import '../blocs/body_scan_event.dart';

/// Vista para calificar la sesión del 1 al 5
class RatingView extends StatefulWidget {
  final List<bool> emotions;

  const RatingView({super.key, required this.emotions});

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    final relaxedCount = widget.emotions.where((e) => e).length;
    final relaxationPercentage =
        (relaxedCount / widget.emotions.length * 100).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título
            const Icon(
              Icons.celebration,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Sesión Completada!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Resumen rápido
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickStat(
                        icon: Icons.check_circle,
                        label: 'Relajadas',
                        value: '$relaxedCount/${widget.emotions.length}',
                        color: Colors.green,
                      ),
                      _QuickStat(
                        icon: Icons.trending_up,
                        label: 'Relajación',
                        value: '$relaxationPercentage%',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Pregunta de calificación
            const Text(
              '¿Cómo te sentiste en esta sesión?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Estrellas de calificación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = rating;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      rating <= _selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      size: 48,
                      color: rating <= _selectedRating
                          ? Colors.amber
                          : Colors.grey[400],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            // Texto descriptivo de la calificación
            Text(
              _getRatingText(_selectedRating),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 32),

            // Botón para enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedRating > 0
                    ? () {
                        context
                            .read<BodyScanBloc>()
                            .add(SubmitRating(_selectedRating));
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Nada satisfactoria';
      case 2:
        return 'Poco satisfactoria';
      case 3:
        return 'Neutral';
      case 4:
        return 'Satisfactoria';
      case 5:
        return 'Muy satisfactoria';
      default:
        return 'Selecciona una calificación';
    }
  }
}

/// Widget para mostrar estadística rápida
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
